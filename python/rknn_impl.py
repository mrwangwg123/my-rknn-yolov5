from detector_bridge import NN 
from rknn.api import RKNN

# 接收onnx类型的RKNN
class RknnImpl(NN):
    def __init__(self, **params):
        print("RknnImpl -> __init__")
        self.__params = params

    def loadModel(self, model_path):
        print("RknnImpl -> loadModel")
        rknn = RKNN()
        self.rknn = rknn
        # pre-process config
        print('--> Config model')
        # rknn.config(mean_values=[[0.0,0.0, 0.0]], std_values=[[255.0, 255.0, 255.0]], reorder_channel='0 1 2')

        # rknn.config(mean_values=[[0.] * 12], std_values=[[255.0] * 12], reorder_channel='')
        rknn.config(mean_values= self.__params["mean_values"], std_values= self.__params["std_values"], reorder_channel= self.__params["reorder_channel"])

        # Load ONNX model
        print('--> Loading model',  rknn.__dict__)
        ret = rknn.load_onnx(model_path)

        # Build model
        print('--> Building model')
        # target_platform default rk1808.
        # ret = rknn.build(do_quantization=True, dataset='./dataset.txt')
        ret = rknn.build(do_quantization=False)


        # 初始化RKNN运行环境
        print('--> Init runtime  environment')
        # ret = rknn.init_runtime(host='rk3399pro')
        ret = rknn.init_runtime()
        return rknn

    def inference(self, img):
        return self.rknn.inference(img)
