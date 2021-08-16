#ifndef RKNN_RKNN_IMPL_H_
#define RKNN_RKNN_IMPL_H_

#include "detector_bridge.h"
// #include "rknn_api.h"

//rknn部署框架实现
class RKNNProxy : public NN
{
public:
  RKNNProxy();

  ~RKNNProxy();

  /**
     * 加载模型
     */
  virtual int loadModel(const char *model_path);

  /**
     * 提取指定网络层输出
     */
  // virtual int extract(int blob_name, cv::Mat &feat);

  /**
    * 进行推理  
    */
  virtual int inference(cv::Mat &input);

  /**
     * 释放资源 
     */
  virtual int release();

private:
  void *rknn_proxy;
};

#endif //RKNN_RKNN_IMPL_H_