

class NN:
    def __init__(self, **params):
        pass
    
    def loadModel(self, model_path):
        pass

    def inference(self, img):
        pass

    def release(self):
        pass

# 展示这个待加上
class Shower:
    def __init__(self):
        pass

    def show(self, result):
        pass

class Detector:
    _nn=None
    # shower=None
    def __init__(self, nn):
        self._nn = nn
        # self.shower = shower
        pass

    def init(self, model_path):
        pass

    def detect(self, img):
        pass

    def release(self):
        pass

# class DetectorBridge:


