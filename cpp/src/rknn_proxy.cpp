#include "rknn_proxy.h"
#include <stdio.h>
#include <stdlib.h>
#include <fstream>
#include <iostream>
#include "wavelib_tools.h"
#include "rknn_api.h"

int input_num, output_num;

int convertRKNNMat2CVMat(rknn_output &in, Tensor &out){
   memcpy(out.data , in.buf, in.size);

   out.c = 3;
//    out.w = 
    

};

RKNNProxy::RKNNProxy(){

};

RKNNProxy::~RKNNProxy(){

};

int RKNNProxy::loadModel(const char *model_path)
{
    int ret;
    char model_path2[1024];
    memset(model_path2, 0, 1024);

    wavelib_tools::ModelFile mf;
    ret = wavelib_tools::LoadModel(model_path, &mf);
    if (ret < 0)
    {
        printf("load model fail! ret=%d\n", ret);
        return ret;
    }

    this->rknn_proxy = new rknn_context;
    ret = rknn_init((rknn_context *)(this->rknn_proxy), mf.model_f_data, mf.model_f_size, 0);
    if (ret < 0)
    {
        printf("rknn_init fail! ret=%d\n", ret);
        return -1;
    }

    // 1. 查询输入的个数rknn_query
    rknn_input_output_num io_num;
    rknn_query(*(rknn_context *)(this->rknn_proxy), RKNN_QUERY_IN_OUT_NUM, &io_num, sizeof(io_num));
    input_num = io_num.n_input;
    output_num = io_num.n_output;

    return 0;
};

int RKNNProxy::inference(cv::Mat &input)
{
    //2. 设置输入取自this->input_num,但目前只考虑单输入情况
    rknn_input inputs[1];
    inputs[0].index = 0;
    inputs[0].type = RKNN_TENSOR_UINT8;
    // inputs[0].type = RKNN_TENSOR_FLOAT32;   /// comment by zhi
    inputs[0].size = input.size.dims();
    inputs[0].fmt = RKNN_TENSOR_NHWC;
    inputs[0].buf = input.data;

    int ret = rknn_inputs_set(*(rknn_context *)(this->rknn_proxy), 1, inputs);
    if (ret < 0)
    {
        printf("rknn_input_set fail! ret=%d\n", ret);
        return -1;
    }

    //3. 进行一次推理，调用超过3次没有通过rknn_outputs_get取走结果就会阻塞，直到该方法被调用
    ret = rknn_run(*(rknn_context *)(this->rknn_proxy), NULL);
    if (ret < 0)
    {
        printf("rknn_run fail! ret=%d\n", ret);
        return -1;
    }

    //4. 获取推理结果，is_prealloc默认FALSE
    rknn_output outputs[output_num];
    // memset(outputs, 0, sizeof(outputs));
    for (int i = 0; i < 3; i++)
    {
        outputs[i].want_float = 1;
        outputs[i].is_prealloc = 0;
    }

    ret = rknn_outputs_get(*(rknn_context *)(this->rknn_proxy), output_num, outputs, NULL);

    //5. 将结果转换成float * 先删除再赋值，自己设计框架要求
    //5.1 获取outputs中数组长度
    // int convert_size = 0;
    for (int i = 0; i < output_num; i++)
    {
        // convert_size += sizeof(outputs[i].buf);
        Tensor t_mat;
        convertRKNNMat2CVMat(outputs[i], t_mat);
        this->output_results_[1] = t_mat;
        rknn_outputs_release(*(rknn_context *)(this->rknn_proxy), i, outputs);
    }

    //5.2 创建新的数组进行拷贝
    // this->inferenceResult = new float[convert_size];
    // output_results_
    // int index = 0;
    // for (int i = 0; i < this->output_num; i++)
    // {
    //     memcpy(this->inferenceResult+index-1, outputs[i].buf, sizeof(outputs[i].buf));
    //     index += sizeof(outputs[i].buf);
    // }

    //6. 释放
    // rknn_outputs_release((rknn_context)(this->rknn_proxy), 2, outputs);
    if (ret < 0)
    {
        printf("rknn_outputs_get fail! ret=%d\n", ret);
        return -1;
    }
    return ret;
};

int RKNNProxy::release()
{
    return 0;
};
