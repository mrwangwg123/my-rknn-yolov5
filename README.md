本工程以Yolov5算法为例介绍rknn的使用，流程包含了：转换模型和模型部署（不含训练）。

## 一、工程目录
```text
|-- README.md
|-- commons                         # 帮助工具
|   |-- rknn-convert                # 转换其他框架的模型到rknn,包括(tensorflow、tflite、caffe、onnx)
|   `-- yolov5-torch2rknn-convert   # 将torch框架训练的yolov5的模型转成rknn支持的onnx
|       |-- common.py
|       |-- common_rk_plug_in.py    # rknn 中兼容的网络层
|       |-- experimental.py
|       |-- export.py               # 将torch框架训练的yolov5的模型转成rknn支持的onnx,内部做了兼容
|       |-- yolo.py                 # 自动生成torch下的yolov5网络
|       |-- yolov5l.yaml 
|       |-- yolov5m.yaml
|       |-- yolov5s.yaml
|       `-- yolov5x.yaml
|-- cpp                             # 使用rknn部署的yolov5算法的C++示例
|-- data                            # 数据/测试图片
|-- docs
|-- model                           # 模型文件（待转换的模型、待测试的模型）
|   |-- face-focus-removed.onnx     # python代码中使用的人脸检测测试模型（转换后的）
|   |-- face-model.pt               # 人脸检测训练好的模型，需要使用export.py转换成rknn
|   `-- yolov5s.onnx                # yolov5示例转换好的模型，
|-- packages                        # rknn-toolkit包
|-- python                          # 使用rknn部署的yolov5算法的python示例
|   |-- detector_bridge.py
|   |-- rknn_impl.py
|   |-- test.py                     # 示例程序入口
|   |-- torch_impl.py
|   `-- yolov5_detector_impl.py
`-- runs                            # 运行结果暂存
```

## 二、搭建环境
#### 环境 ：
- python==3.6.13
- torch==1.7.0
- rknn-toolkit==1.6.0

#### 安装 ：
- rknn-toolkit ： 安装包位于工程目录packages下

## 三、使用步骤
#### 1. 将训练好模型转成rknn支持的(tensorflow、tflite、caffe、onnx)
torch转rknn: 
> 目前只是针对yolov5算法的torch模型转rknn,如遇其他算子不支持，可以按照此思路进行兼容

- 工具位置 ： /commons/yolov5-torch2rknn-convert/
- 命令： python models/export.py --weights ./weights/yolov5s.pt --img-size 640 --batch 1 --rknn_mode

其他框架转rknn :
> 针对tensorflow、tflite、caffe、onnx转换rknn，并提供了自定义网络层的示例

- 工具位置 ： /commons/rknn-convert

#### 2. 加载转换好的模型，使用rknn部署
> 目前针对yolov5算法做了部署rknn的示例代码，包括两个工程python和cpp

## 问题 : 
#### 1. 原计划直接使用commons中的export.py将训练好的pytorch模型直接转换为rknn支持的onnx,使用了个人间检测的，转换不成功
- torch版本低，目前是用的项目中使用的torch版本1.7.0

```
(rknn-toolkit) autobuild@ubuntu-server-117:~/wangwengang/my-rknn-yolov5/commons/yolov5-torch2rknn-convert$ python models/export.py --weights /home/autobuild/wangwengang/my-rknn-yolov5/model/face-model.pt --img 640 --rknn_mode
Namespace(batch_size=1, device='cpu', dynamic=False, grid=False, img_size=[640, 640], rknn_mode=False, weights='/home/autobuild/wangwengang/my-rknn-yolov5/model/face-model.pt')
Using torch 1.5.1 CPU

weight :  /home/autobuild/wangwengang/my-rknn-yolov5/model/face-model.pt
Traceback (most recent call last):
  File "models/export.py", line 39, in <module>
    model = attempt_load(opt.weights, map_location=device)  # load FP32 model
  File "/home/autobuild/wangwengang/my-rknn-yolov5/commons/yolov5-torch2rknn-convert/models/experimental.py", line 119, in attempt_load
    ckpt = torch.load(w, map_location=map_location)  # load
  File "/home/autobuild/miniconda3/envs/rknn-toolkit/lib/python3.6/site-packages/torch/serialization.py", line 592, in load
    return _load(opened_zipfile, map_location, pickle_module, **pickle_load_args)
  File "/home/autobuild/miniconda3/envs/rknn-toolkit/lib/python3.6/site-packages/torch/serialization.py", line 852, in _load
    result = unpickler.load()
AttributeError: Can't get attribute 'SiLU' on <module 'torch.nn.modules.activation' from '/home/autobuild/miniconda3/envs/rknn-toolkit/lib/python3.6/site-packages/torch/nn/modules/activation.py'>
```
#### 2. numpy冲突
- 使用conda重新起了环境