from detector_bridge import NN 
import torch

class TorchImpl(NN):
    def __init__(self):
        print("TorchImpl -> __init__")

    def loadModel(self, model_path):
        pass

    def inference(self, img):
        pass