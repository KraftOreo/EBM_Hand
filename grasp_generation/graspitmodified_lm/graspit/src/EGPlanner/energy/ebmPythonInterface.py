#sys.path.append('/home/liujian/WorkSpace/EBM_Hand')
#import torch
#import numpy as np
#import sys
#from models import FCNet

##Brief: Given 20DOF value of grasp posture, the ebm model outputs a value to predict how the grasp hand is human-like.
#Author: Jian Liu   
#Input: 
#   dof_value - list(double) in Python
#   model_path - string in Python
#Output:
#   ebm_ener - double
global ebm_ener
def dof_ebm(dof_value, model_path):
    global ebm_ener
    #dof_value = [0, 0.76481, 0.1898, 0.13557, 0, 0.43311, 0.029243, 0.020888, 0, 0.15028, 0.047459, 0.033899, 0,
    #                 0.23049, 0.21495, 0.15354, 0, -0.87266, 0, 0.14549]
    # ebm_ener = 0.65
    model = FCNet(in_dim=20, out_dim=1, l_hidden=(100, 100), activation='relu', out_activation='linear')
    model.load_state_dict(torch.load(model_path))
    model.eval()
    ebm_ener = model(torch.tensor(dof_value))
    return ebm_ener