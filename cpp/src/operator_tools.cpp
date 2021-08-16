#include "operator_tools.h"

inline float intersection_area(const Object& a, const Object& b) {
  cv::Rect_<float> inter = a.rect & b.rect;
  return inter.area();
}

void qsort_descent_inplace(
    std::vector<Object>& faceobjects,
    int left,
    int right) {
  int i = left;
  int j = right;
  float p = faceobjects[(left + right) / 2].prob;

  while (i <= j) {
    while (faceobjects[i].prob > p)
      i++;

    while (faceobjects[j].prob < p)
      j--;

    if (i <= j) {
      // swap
      std::swap(faceobjects[i], faceobjects[j]);

      i++;
      j--;
    }
  }

#pragma omp parallel sections
  {
#pragma omp section
    {
      if (left < j)
        qsort_descent_inplace(faceobjects, left, j);
    }
#pragma omp section
    {
      if (i < right)
        qsort_descent_inplace(faceobjects, i, right);
    }
  }
}

void qsort_descent_inplace(std::vector<Object>& faceobjects) {
  if (faceobjects.empty())
    return;

  qsort_descent_inplace(faceobjects, 0, faceobjects.size() - 1);
}

void nms_sorted_bboxes(
    const std::vector<Object>& faceobjects,
    std::vector<int>& picked,
    float nms_threshold) {
  picked.clear();

  const int n = faceobjects.size();

  std::vector<float> areas(n);
  for (int i = 0; i < n; i++) {
    areas[i] = faceobjects[i].rect.area();
  }

  for (int i = 0; i < n; i++) {
    const Object& a = faceobjects[i];

    int keep = 1;
    for (int j = 0; j < (int)picked.size(); j++) {
      const Object& b = faceobjects[picked[j]];

      // intersection over union
      float inter_area = intersection_area(a, b);
      float union_area = areas[i] + areas[picked[j]] - inter_area;
      // float IoU = inter_area / union_area
      if (inter_area / union_area > nms_threshold)
        keep = 0;
    }

    if (keep)
      picked.push_back(i);
  }
}

float sigmoid(float x) {
  return static_cast<float>(1.f / (1.f + exp(-x)));
}
