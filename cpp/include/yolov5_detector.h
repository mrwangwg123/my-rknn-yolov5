#ifndef WF_YOLOV5_DETECTOR_H_
#define WF_YOLOV5_DETECTOR_H_

#include "detector_bridge.h"
#include <stdint.h>
#include <string>

static char def_labels[] = {'h'};
/**
 * 
 * YOLOv5算法前后处理或部署框架需要的参数
 * 
 */
typedef struct _YOLOv5Params{
    float anchors[3][6] = {{10.f,13.f,16.f,30.f,33.f,23.f},
    {30.f, 61.f, 62.f, 45.f, 59.f, 119.f},
    {116.f, 90.f, 156.f, 198.f, 373.f, 326.f}};  //锚点

    int target_size[2] = {640, 640}; //模型中输入图像的尺寸:高，宽
    char *labels = def_labels;  //分类的名称
    float conf_thresh = 0.5; //置信度阈值
    float iou_thresh = 0.05; //IOU阈值
} YOLOv5Params;

/**
 * 
 * YOLOv5算法返回的结果数据结构
 * 
 */
typedef std::vector<std::vector<float>> YOLOv5Result;

/**
 *
 * YOLOv5算法检测器，处理公用的前后处理
 * 
 */
class YOLOv5Detector: public Detector<YOLOv5Params, YOLOv5Result>
{
public:
    YOLOv5Detector(NN *nn):Detector(nn){
        
    };

    virtual ~YOLOv5Detector(){

    };

    virtual int setParams(YOLOv5Params *params);

    // virtual int init(const char *model_path);

    virtual int detect(uint8_t *img, int width, int height, int size, YOLOv5Result *result);

    // virtual int release();

protected:
    int _preInference(cv::Mat &in, float &scale, cv::Mat &out);

    int _afterInference(int &img_w, int &img_h, cv::Mat &in_pad, float &scale, YOLOv5Result *result);

protected:
    YOLOv5Params mParams;
};

#endif // WF_YOLOV5_DETECTOR_H_