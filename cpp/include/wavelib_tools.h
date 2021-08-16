#ifndef WAVELIB_TOOLS_H_
#define WAVELIB_TOOLS_H_

#include <stdlib.h>
#include <stdint.h>
#include <fstream>
#include <iostream>

/**
 * 部署封装工具类
 */
namespace wavelib_tools{

    struct ModelFile {
        uint8_t *  model_f_data;
        int model_f_size;
    };

    int LoadModel(const char *filename, ModelFile * model_f)
    {
        FILE *fp = fopen(filename, "rb");
        if (fp == nullptr)
        {
            printf("fopen %s fail!\n", filename);
            return -1;
        }
        fseek(fp, 0, SEEK_END);
        int model_len = ftell(fp);
        unsigned char *model = (unsigned char *)malloc(model_len);
        fseek(fp, 0, SEEK_SET);
        if (model_len != fread(model, 1, model_len, fp))
        {
            printf("fread %s fail!\n", filename);
            free(model);
            return -1;
        }
       
        if (fp)
        {
            fclose(fp);
        }

        model_f->model_f_size = model_len;
        model_f-> model_f_data = model;
        return 0;
    };

}

#endif //WAVELIB_TOOLS_H_