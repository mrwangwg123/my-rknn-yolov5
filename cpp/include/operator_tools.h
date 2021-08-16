#ifndef WF_OPERATOR_TOOLS_H_
#define WF_OPERATOR_TOOLS_H_

#include <vector>
#include <opencv2/opencv.hpp>

/**
 * 
 * 算子工具
 * 
 */
#ifdef __cplusplus
extern "C" {
#endif

//    float WF_OPERATOR_sigmoid(float x);

struct Object {
  cv::Rect_<float> rect;
  int label;
  float prob;
};

inline float intersection_area(const Object& a, const Object& b);

void qsort_descent_inplace(std::vector<Object>& faceobjects);

void nms_sorted_bboxes(
    const std::vector<Object>& faceobjects,
    std::vector<int>& picked,
    float nms_threshold);

float sigmoid(float x);


#ifdef __cplusplus
}
#endif

#endif //WF_OPERATOR_TOOLS_H_