#ifndef WF_DETECTOR_BRIDGE_H_
#define WF_DETECTOR_BRIDGE_H_

#include <opencv2/opencv.hpp>
#include <stdint.h>
#include <string>

#define MAX_OUTPUT_NUM 5

typedef struct Tensor_S
{
  int n;
  int c; // channel
  int h; //矩阵的height
  int w; //矩阵的width
  unsigned char *im;
  float *data;

  //   Tensor_S(int c, int h, int w):c(c), h(h), w(w){
  //     data = new float[c * h * w];
  //   };

  // ~Tensor_S() {
  //   if (data != nullptr)
  //     delete[] data;
  // };

  float *channel(int index)
  {
    return data + index * (sizeof(data) / (4 * c));
  };

} Tensor;

// namespace wave
// 部署框架抽象
// template <typename L>
// 问题：引起了Detector的invalid use of template-name without an argument list
// 解决：暂时没有想到好的解决方案，先注释掉
class NN
{
protected:
  Tensor output_results_[MAX_OUTPUT_NUM];

public:
  NN(){};

  virtual ~NN(){};

  /**
   * 自定义网络层
   */
  // virtual int registerCustomLayer(std::string layer_name, L layer){};

  /**
   * 加载模型
   */
  virtual int loadModel(const char *model_path){
    return 0;
  };

  /**
   * 提取指定网络层输出
   */
  virtual int extract(int blob_name, Tensor &feat){
    return 0;
  };

  /**
   * 进行推理
   */
  virtual int inference(cv::Mat &input){
    return 0;
  };

  /**
   * 获取推理结果
   */
  virtual Tensor getInferenceResult(int index)
  {
    return output_results_[index];
  };

  /**
   * 回收推理结果 
   */
  virtual int clearInferenceResult()
  {
    for(int i=0;i<MAX_OUTPUT_NUM;i++){
      delete &output_results_[i];
    }
    return 0;
  }

  /**
   * 释放资源
   */
  virtual int release(){
    return 0;
  };
};

//算法调用抽象
template <typename P, typename R>
class Detector
{
protected:
  NN *nn;

public:
  Detector(NN *nn)
  {
    this->nn = nn;
  };

  virtual ~Detector()
  {
    this->release();
  };

  virtual int setParams(P *params){};

  virtual int init(const char *model_path)
  {
    return this->nn->loadModel(model_path);
  };

  virtual int detect(
      uint8_t *img,
      int width,
      int height,
      int size,
      R *result)
  {
    return 0;
  };

  virtual int release()
  {
    if (this->nn != nullptr)
    {
      this->nn->release();
      delete this->nn;
      this->nn = nullptr;
    }
    return 0;
  };
};

#endif // WF_DETECTOR_BRIDGE_H_