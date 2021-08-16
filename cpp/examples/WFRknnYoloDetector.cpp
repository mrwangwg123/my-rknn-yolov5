
#include <opencv2/opencv.hpp>
#include "rknn_proxy.h"
#include "yolov5_detector.h"
#include "detector_bridge.h"

int main(int argc, char **argv)
{
  NN *nn = new RKNNProxy();
  YOLOv5Detector *detector = new YOLOv5Detector(nn);

  char model_path[] = "/home/autobuild/wangwengang/my-rknn-yolov5/model/face-model.onnx";
  detector->init(model_path);

  cv::Mat img = cv::imread("/home/autobuild/wangwengang/my-rknn-yolov5/data/images/bus.jpg");

  YOLOv5Result r;
  detector->detect(img.data, img.rows, img.cols, 3* img.rows*img.cols, &r);
  return 0;
}
