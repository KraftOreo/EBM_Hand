import torch 
import argparse
from ebmPythonInterface import dof_ebm
from models import FCNet
from langevin import sample_langevin

dof_value = torch.randn(100000, 20) * 90

dof_value = torch.cat((torch.tensor([[20.001473227855016, 13.406750435908377, -4.34682104794763, -10.000736613927508, -5.819760320045987e-15, 90.00662952534756, 46.78384021450958, 39.930035914682726, -20.001473227855016, 90.00662952534756, 24.28292942822136, -2.899876125033489, -13.056203165545783, 90.00662952534756, -10.000736613927508, -10.000736613927508, -10.000736613927508, -5.980822769119368, 2.2555621408924305, 0.0]]), dof_value), dim=0)

model_path = r'/root/WorkSpace/EBM_Result/models/model_21:22:48-Nov-30-2020/model_0.pkl'

for i in range(dof_value.shape[0]):
    print(dof_ebm(dof_value=dof_value[i, :], model_path=model_path))
