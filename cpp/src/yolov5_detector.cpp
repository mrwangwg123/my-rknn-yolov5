#include "yolov5_detector.h"

#include <math.h>
#include <vector>
#include "operator_tools.h"

void generate_proposals(
    const float* anchors,
    const int& num_anchors,
    const int& stride,
    const cv::Mat& in_pad,
    const Tensor& feat_blob,
    float prob_threshold,
    std::vector<Object>& objects) {
  std::cout << "generate_proposals stride=" << stride
            << " c_h_w : " << feat_blob.c << " , " << feat_blob.h << " , "
            << feat_blob.w << std::endl;

  const int num_grid = feat_blob.h;

  int num_grid_x;
  int num_grid_y;
  if (in_pad.rows > in_pad.cols) {
    num_grid_x = in_pad.rows / stride;
    num_grid_y = num_grid / num_grid_x;
  } else {
    num_grid_y = in_pad.cols / stride;
    num_grid_x = num_grid / num_grid_y;
  }

  const int num_class = feat_blob.w - 5;
  //   const int num_anchors = sizeof(anchors) / 2;

  for (int q = 0; q < num_anchors; q++) {
    const float anchor_w = anchors[q * 2];
    const float anchor_h = anchors[q * 2 + 1];

    float* channel = feat_blob.data + q * feat_blob.w * feat_blob.h;

    int d = 0;

    for (int i = 0; i < num_grid_y; i++) {
      for (int j = 0; j < num_grid_x; j++) {
        const float* featptr = channel + (i * num_grid_x + j) * feat_blob.w;

        //和YOLOv5有关的数据放在了前五位
        // find class index with max class score
        int class_index = 0;
        float class_score = -FLT_MAX;
        for (int k = 0; k < num_class; k++) {
          float score = featptr[5 + k];

          if (score > class_score) {
            class_index = k;
            class_score = score;
          }
        }

        float box_score = featptr[4];

        float confidence = sigmoid(box_score) * sigmoid(class_score);
    
        // if ( i%8==0 && i == j)
        //   std::cout << "featptr["<< i <<"] = " << featptr[i]
        //             << " , box_score = " << box_score << " ,k = " << class_index
        //             << " , confidence = " << confidence << std::endl;

        if (confidence >= prob_threshold) {
          float dx = sigmoid(featptr[0]);
          float dy = sigmoid(featptr[1]);
          float dw = sigmoid(featptr[2]);
          float dh = sigmoid(featptr[3]);

          float pb_cx = (dx * 2.f - 0.5f + j) * stride;
          float pb_cy = (dy * 2.f - 0.5f + i) * stride;

          float pb_w = pow(dw * 2.f, 2) * anchor_w;
          float pb_h = pow(dh * 2.f, 2) * anchor_h;

          float x0 = pb_cx - pb_w * 0.5f;
          float y0 = pb_cy - pb_h * 0.5f;
          float x1 = pb_cx + pb_w * 0.5f;
          float y1 = pb_cy + pb_h * 0.5f;

          Object obj;
          obj.rect.x = x0;
          obj.rect.y = y0;
          obj.rect.width = x1 - x0;
          obj.rect.height = y1 - y0;
          obj.label = class_index;
          obj.prob = confidence;

          objects.push_back(obj);
        }
      }
    }
  }
  std::cout << "objects.size() = " << objects.size() << std::endl;
};

int YOLOv5Detector::setParams(YOLOv5Params* params) {
  //模型输入图的宽高
  this->mParams.target_size[0] = params->target_size[0];
  this->mParams.target_size[1] = params->target_size[1];
  //分类标签名数组
  this->mParams.labels = params->labels;
  //锚点数组
  // this->mParams.anchors = params->anchors;
  // IOU
  this->mParams.iou_thresh = params->iou_thresh;
  //置信度
  this->mParams.conf_thresh = params->conf_thresh;

  return 0;
};

int YOLOv5Detector::detect(
    uint8_t* img,
    int width,
    int height,
    int size,
    YOLOv5Result* result) {
  cv::Mat in(height, width, CV_8UC3, img);
  cv::Mat out;
  float scale = std::min(
      this->mParams.target_size[0] / width,
      this->mParams.target_size[1] / height);

  int ret = 0;
  ret = this->_preInference(in, scale, out);
  ret = this->nn->inference(out);
  ret = this->_afterInference(width, height, out, scale, result);
  ret = this->nn->clearInferenceResult();
  return ret;
};

int YOLOv5Detector::_preInference(cv::Mat& in, float& scale, cv::Mat& out) {
  int w = scale * in.cols;
  int h = scale * in.rows;

  cv::resize(in, out, cv::Size(w, h));
  cv::Scalar scalar(114, 114, 114);
  int pad_w = abs(this->mParams.target_size[1] - out.cols);
  int pad_h = abs(this->mParams.target_size[0] - out.rows);

  cv::copyMakeBorder(
      out,
      out,
      pad_h / 2,
      pad_h / 2,
      pad_w / 2,
      pad_w / 2,
      cv::BORDER_CONSTANT,
      scalar);
  return 0;
};

int YOLOv5Detector::_afterInference(
    int& img_w,
    int& img_h,
    cv::Mat& in_pad,
    float& scale,
    YOLOv5Result* result) {
  int pad_w = abs(this->mParams.target_size[1] - img_w);
  int pad_h = abs(this->mParams.target_size[0] - img_h);

  float prob_threshold = this->mParams.conf_thresh; //置信度
  float nms_threshold = this->mParams.iou_thresh; // IOU

  std::vector<Object> proposals;
  // 大图对大锚点
  // stride 8
  {
    Tensor out = this->nn->getInferenceResult(0);

    std::vector<Object> objects8;
    generate_proposals(
        this->mParams.anchors[0], 3, 8, in_pad, out, prob_threshold, objects8);
    proposals.insert(proposals.end(), objects8.begin(), objects8.end());
  }

  // stride 16
  {
    Tensor out = this->nn->getInferenceResult(1);

    std::vector<Object> objects16;
    generate_proposals(
        this->mParams.anchors[1],
        3,
        16,
        in_pad,
        out,
        prob_threshold,
        objects16);
    proposals.insert(proposals.end(), objects16.begin(), objects16.end());
  }

  // stride 32
  {
    Tensor out = this->nn->getInferenceResult(2);

    std::vector<Object> objects32;
    generate_proposals(
        this->mParams.anchors[2],
        3,
        32,
        in_pad,
        out,
        prob_threshold,
        objects32);
    proposals.insert(proposals.end(), objects32.begin(), objects32.end());
  }

  std::cout << "--> proposals = " << proposals.size() << std::endl;

  // sort all proposals by score from highest to lowest
  qsort_descent_inplace(proposals);

  // apply nms with nms_threshold
  std::vector<int> picked;
  nms_sorted_bboxes(proposals, picked, nms_threshold);

  int count = picked.size();

  std::vector<Object> objects;
  objects.resize(count);

  //映射原图中的坐标
  for (int i = 0; i < count; i++) {
    objects[i] = proposals[picked[i]];

    // adjust offset to original unpadded
    float x0 = (objects[i].rect.x - (pad_w / 2)) / scale;
    float y0 = (objects[i].rect.y - (pad_h / 2)) / scale;
    float x1 =
        (objects[i].rect.x + objects[i].rect.width - (pad_w / 2)) / scale;
    float y1 =
        (objects[i].rect.y + objects[i].rect.height - (pad_h / 2)) / scale;

    // clip
    x0 = std::max(std::min(x0, (float)(img_w - 1)), 0.f);
    y0 = std::max(std::min(y0, (float)(img_h - 1)), 0.f);
    x1 = std::max(std::min(x1, (float)(img_w - 1)), 0.f);
    y1 = std::max(std::min(y1, (float)(img_h - 1)), 0.f);

    objects[i].rect.x = x0;
    objects[i].rect.y = y0;
    objects[i].rect.width = x1 - x0;
    objects[i].rect.height = y1 - y0;
  }

  // TODO 设置YOLOv5Result
  result->clear();
  for (int i = 0; i < objects.size(); ++i) {
    std::vector<float> obj;
    if (objects[i].label == 0) {
      obj.push_back(float(objects[i].rect.x));
      obj.push_back(float(objects[i].rect.y));
      obj.push_back(float(objects[i].rect.width));
      obj.push_back(float(objects[i].rect.height));
      obj.push_back(objects[i].prob);
      result->push_back(obj);
    }
  }
  return 0;
};