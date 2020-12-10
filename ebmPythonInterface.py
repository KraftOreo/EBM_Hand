import torch
# import numpy as np
# import sys
# sys.path.append('/home/liujian/WorkSpace/EBM_Hand')
from models import FCNet
# from langevin import sample_langevin

##Brief: Given 20DOF value of grasp posture, the ebm model outputs a value to predict how the grasp hand is human-like.
#Author: Jian Liu   
#Input: 
#   dof_value - list(double) in Python
#   model_path - string in Python
#Output:
#   ebm_ener - double
global ebm_ener
def dof_ebm(dof_value, model_path):
    #dof_value = [0, 0.76481, 0.1898, 0.13557, 0, 0.43311, 0.029243, 0.020888, 0, 0.15028, 0.047459, 0.033899, 0,
    #                 0.23049, 0.21495, 0.15354, 0, -0.87266, 0, 0.14549]
    # ebm_ener = 0.65
    global ebm_ener
    #test
    print("===============model path===============", model_path)
    print("===============dof value===============", dof_value)
    model = FCNet(in_dim=20, out_dim=1, l_hidden=(100, 100), activation='relu', out_activation='linear')
    # print("===============model initialized1===============")
    model.load_state_dict(torch.load(model_path))
    # print("===============model initialized2===============")

    model.eval()
    # print("===============model initialized===============")
    ebm_ener = model(torch.tensor(dof_value))
    # print("===============energy calculated===============")
    ebm_ener = ebm_ener.detach().item()
    return ebm_ener

