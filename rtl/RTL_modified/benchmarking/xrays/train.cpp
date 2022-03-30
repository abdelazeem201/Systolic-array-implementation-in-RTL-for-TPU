// train Tiny DNN to classify chest xray images

#include <iostream>
#include <vector>

// includes for image parsing
#include <opencv2/imgcodecs.hpp>
#include <opencv2/imgproc.hpp>
#include <boost/foreach.hpp>
#include <boost/filesystem.hpp>

#include "tiny_dnn/tiny_dnn.h"
#include "csv.h" // csv parsing

using namespace boost::filesystem;

void randomize_csv(std::string csv_path)
{
    const std::string header_str = "Image Index,Finding Labels,Follow-up #,"
           "Patient ID,Patient Age,Patient Gender,View Position,"
           "OriginalImageWidth,OriginalImageHeight,OriginalImagePixelSpacing_x,"
           "OriginalImagePixelSpacing_y";
    system(("cat '" + csv_path + "' | grep \"^0\" | shuf -o '" + csv_path + "'\n").c_str());
    system(("sed -i '1 i\\" + header_str + "' '" + csv_path + "'\n").c_str());
    system(("chmod ugo+rw '" + csv_path + "'\n").c_str());
}

tiny_dnn::vec_t str_to_labels(std::string label_str)
{     
    tiny_dnn::vec_t label_set(15, 0);
    std::stringstream str_stream(label_str);
    std::string tmp_str;
    std::map<std::string, double> classif_table {
        {"No Finding",          0},
        {"Atelectasis",         1},
        {"Cardiomegaly",        2},
        {"Consolidation",       3},
        {"Edema",               4},
        {"Effusion",            5},
        {"Emphysema",           6},
        {"Fibrosis",            7},
        {"Hernia",              8},
        {"Infiltration",        9},
        {"Mass",               10},
        {"Nodule",             11},
        {"Pleural_Thickening", 12},
        {"Pneumonia",          13},
        {"Pneumothorax",       14}
    };

    while (getline(str_stream, tmp_str, '|')) { 
        if (classif_table.find(tmp_str) == classif_table.end()) {
            std::cerr << "Find Error: Label '"
                      << tmp_str
                      << "' is not a valid classification"
                      << std::endl;
            return { 0 };
        } else {
            label_set[classif_table[tmp_str]] = 1;
        }
    }

    return label_set;
}

// convert image from filename into a vector for processing
void convert_image(const std::string& imagefilename,
                   double scale,
                   int w,
                   int h,
                   std::vector<tiny_dnn::vec_t> &data)
{
    auto img = cv::imread(imagefilename, cv::IMREAD_GRAYSCALE);
    if (img.data == nullptr) return; // cannot open, or it's not an image

    cv::Mat_<uint8_t> resized;
    cv::resize(img, resized, cv::Size(w, h));
    tiny_dnn::vec_t d;

    std::transform(resized.begin(), resized.end(), std::back_inserter(d),
                   [=](uint8_t c) { return c *scale; });

    for (unsigned int i = 0; i < 16384; i++) {
        //d[i] = (d[i] / 128) - 1;
        d[i] /= 255;
    }
    
    data.push_back(d);
}

void populate_vecs(const std::string directory,
                    const std::string csv_path,
                    std::vector<tiny_dnn::vec_t> *training_images,
                    std::vector<tiny_dnn::vec_t> *training_labels,
                    std::vector<tiny_dnn::vec_t> *testing_images,
                    std::vector<tiny_dnn::vec_t> *testing_labels)
{
    io::CSVReader<2> label_csv(csv_path);
    label_csv.read_header(io::ignore_extra_column,
                          "Image Index",
                          "Finding Labels");
    std::string filename;
    std::string classif_str;
    std::string img_path;
    int i = 0; // counter for saving every 10th image for testing

    while (label_csv.read_row(filename, classif_str)){//} && i < 1000) {  // TODO: get rid of i < 1000
        img_path = directory + "/" + filename;
        if (i % 10 == 0) { // save for testing
            convert_image(img_path, 1, 128, 128, *testing_images);
            testing_labels->push_back(str_to_labels(classif_str));
        } else { // use for training
            convert_image(img_path, 1, 128, 128, *training_images);
            training_labels->push_back(str_to_labels(classif_str));
        }
        std::cout << "converting image " << i << "\r";
        i++;
    }
    std::cout << "                                        \r";
}

static void construct_net(tiny_dnn::network<tiny_dnn::sequential> &nn,
                          tiny_dnn::core::backend_t backend_type)
{
    // construct nets
    //
    // C : convolution
    // S : sub-sampling
    // F : fully connected
    // clang-format off
    using fc = tiny_dnn::layers::fc;
    using conv = tiny_dnn::layers::conv;
    using ave_pool = tiny_dnn::layers::ave_pool;
    using relu = tiny_dnn::activation::relu;
    using tanh = tiny_dnn::activation::tanh;

    using padding = tiny_dnn::padding;

    nn << conv(128, 128, 5, 1, 6,    // C1, 1@128x128-in, 6@124x124-out
               padding::valid, true, 1, 1, 1, 1, backend_type)
       << tanh()
       << ave_pool(124, 124, 6, 2)   // S2, 6@124x124-in, 6@62x62-out
       << conv(62, 62, 5, 6, 16,     // C3, 6@62x62-in, 16@58x58-out
               padding::valid, true, 1, 1, 1, 1, backend_type)
       << tanh()
       << ave_pool(58, 58, 16, 2)    // S4, 16@58x58-in, 16@29x29-out
       << conv(29, 29, 3, 16, 24,    // C5, 16@29x29-in, 24@27x27-out
               padding::valid, true, 1, 1, 1, 1, backend_type)
       << tanh()
       << ave_pool(27, 27, 24, 3)    // S6, 24@27x27-in, 24@9x9-out
       << tanh()
       << conv(9, 9, 5, 24, 24,    // C7, 24@9x9-in, 24@5x5-out
               padding::valid, true, 1, 1, 1, 1, backend_type)
       << tanh()
       << conv(5, 5, 5, 24, 120,     // C7, 24@5x5-in, 120@1x1-out
               padding::valid, true, 1, 1, 1, 1, backend_type)
       << tanh()
       << fc(120, 15, true, backend_type) // F6, 1250-in, 15-out
       << tanh();
}

static void train_lenet(const std::string &data_dir_path,
                        const std::string &csv_header_path,
                        double learning_rate,
                        const int n_train_epochs,
                        const int n_minibatch,
                        tiny_dnn::core::backend_t backend_type)
{
    // specify loss-function and learning strategy
    tiny_dnn::network<tiny_dnn::sequential> nn;
    tiny_dnn::adagrad optimizer;

    construct_net(nn, backend_type);

    std::cout << "load models..." << std::endl;

    // load MNIST dataset
    std::vector<tiny_dnn::vec_t> train_labels, test_labels;
    std::vector<tiny_dnn::vec_t> train_images, test_images;

    randomize_csv(csv_header_path);
    populate_vecs(data_dir_path,
                   csv_header_path,
                   &train_images,
                   &train_labels,
                   &test_images,
                   &test_labels);

    /*
    for (unsigned int i = 0; i < 4; i++) {
        std::cout << "training image " << i << std::endl;
        
        for (unsigned int j = 0; j < 10; j++) {
            std::cout << train_images[i][j*150] << ", "; 
        }

        std::cout << std::endl;

        for (unsigned int j = 0; j < 15; j++) {
            std::cout << train_labels[i][j] << ", ";
        }

        std::cout << std::endl << std::endl << "testing image " << i << std::endl;

        for (unsigned int j = 0; j < 10; j++) {
            std::cout << test_images[i][j*150] << ", "; 
        }

        std::cout << std::endl;
        
        for (unsigned int j = 0; j < 15; j++) {
            std::cout << test_labels[i][j] << ", ";
        }
        
        std::cout << std::endl << std::endl;
    }
    */

    std::cout << "start training" << std::endl;

    tiny_dnn::progress_display disp(train_images.size());
    tiny_dnn::timer t;

    optimizer.alpha *=
    std::min(tiny_dnn::float_t(4),
             static_cast<tiny_dnn::float_t>(sqrt(n_minibatch) * learning_rate));

    int epoch = 1;
    // create callback

    auto on_enumerate_epoch = [&]() {
        std::cout << std::endl << "Epoch " << epoch << "/" << n_train_epochs
                  << " finished. " << t.elapsed() << "s elapsed." << std::endl;
        ++epoch;

        // show loss
        std::cout << "Loss: "
                  << nn.get_loss<tiny_dnn::mse>(test_images, test_labels)
                  << std::endl;

        train_images.clear();
        train_labels.clear();
        test_images.clear();
        test_labels.clear();

        randomize_csv(csv_header_path);
        populate_vecs(data_dir_path,
                   csv_header_path,
                   &train_images,
                   &train_labels,
                   &test_images,
                   &test_labels);

        disp.restart(train_images.size());
        t.restart();
    };

    auto on_enumerate_minibatch = [&]() { disp += n_minibatch; };

    nn.fit<tiny_dnn::mse>(optimizer, train_images, train_labels, n_minibatch,
                          n_train_epochs, on_enumerate_minibatch,
                          on_enumerate_epoch);

    std::cout << "end training." << std::endl;

    // save network model & trained weights
    nn.save("xray-diagnosis-model");
}

static tiny_dnn::core::backend_t parse_backend_name(const std::string &name)
{
    const std::array<const std::string, 5> names = {{
    "internal", "nnpack", "libdnn", "avx", "opencl",
    }};
    
    for (size_t i = 0; i < names.size(); ++i) {
        if (name.compare(names[i]) == 0) {
            return static_cast<tiny_dnn::core::backend_t>(i);
        }
    }
    
    return tiny_dnn::core::default_engine();
}

static void usage(const char *argv0)
{
    std::cout << "Usage: " << argv0 << " --data_path path_to_dataset_folder"
              << " --learning_rate 1"
              << " --epochs 10"
              << " --minibatch_size 16"
              << " --backend_type internal" << std::endl;
}

int main(int argc, char **argv)
{
    double learning_rate                   = 1;
    int epochs                             = 10;
    std::string data_path                  = "";
    int minibatch_size                     = 16;
    tiny_dnn::core::backend_t backend_type = tiny_dnn::core::default_engine();

    if (argc == 2) {
        std::string argname(argv[1]);
        if (argname == "--help" || argname == "-h") {
            usage(argv[0]);
            return 0;
        }
    }

    for (int count = 1; count + 1 < argc; count += 2) {
        std::string argname(argv[count]);
        if (argname == "--learning_rate") {
            learning_rate = atof(argv[count + 1]);
        } else if (argname == "--epochs") {
            epochs = atoi(argv[count + 1]);
        } else if (argname == "--minibatch_size") {
            minibatch_size = atoi(argv[count + 1]);
        } else if (argname == "--backend_type") {
            backend_type = parse_backend_name(argv[count + 1]);
        } else if (argname == "--data_path") {
            data_path = std::string(argv[count + 1]);
        } else {
            std::cerr << "Invalid parameter specified - \"" << argname << "\""
                      << std::endl;
            usage(argv[0]);
            return -1;
        }
    }

    if (data_path == "") {
        std::cerr << "Data path not specified." << std::endl;
        usage(argv[0]);
        return -1;
    }

    if (learning_rate <= 0) {
        std::cerr
        << "Invalid learning rate. The learning rate must be greater than 0."
        << std::endl;
        return -1;
    }

    if (epochs <= 0) {
        std::cerr << "Invalid number of epochs. The number of epochs must be "
                     "greater than 0."
                  << std::endl;
        return -1;
    }

    if (minibatch_size <= 0 || minibatch_size > 60000) {
        std::cerr
        << "Invalid minibatch size. The minibatch size must be greater than 0"
           " and less than dataset size (60000)."
        << std::endl;
    return -1;
    }

    std::cout << "Running with the following parameters:" << std::endl
              << "Data path: " << data_path << std::endl
              << "Learning rate: " << learning_rate << std::endl
              << "Minibatch size: " << minibatch_size << std::endl
              << "Number of epochs: " << epochs << std::endl
              << "Backend type: " << backend_type << std::endl
              << std::endl;
    try {
        train_lenet(data_path, data_path + "/../sample_labels.csv", learning_rate,
                    epochs, minibatch_size, backend_type);
    } catch (tiny_dnn::nn_error &err) {
        std::cerr << "Exception: " << err.what() << std::endl;
    }

    return 0;
}
