"""
	train_energy_based_model.py
"""
import numpy as np
import matplotlib.pyplot as plt
import os
from datetime import datetime
import torch
from torch.optim import Adam
from torch.utils.data import TensorDataset, DataLoader
import argparse
from Data.read_data import DataReader
from models import FCNet, ConvNet
from langevin import sample_langevin
from data import sample_2d_data
import time
from tqdm import tqdm

parser = argparse.ArgumentParser()
parser.add_argument('--dataset', choices=('8gaussians', '2spirals', 'checkerboard', 'rings', 'MNIST'), default='./Data/degree_data.txt')
parser.add_argument('--model', choices=('FCNet', 'ConvNet'), default='FCNet')
parser.add_argument('--lr', type=float, default=1e-3, help='learning rate. default: 1e-3')
parser.add_argument('--stepsize', type=float, default=0.1, help='Langevin dynamics step size. default 0.1')
parser.add_argument('--n_step', type=int, default=100, help='The number of Langevin dynamics steps. default 100')
parser.add_argument('--n_epoch', type=int, default=100, help='The number of training epoches. default 100')
parser.add_argument('--alpha', type=float, default=1., help='Regularizer coefficient. default 100')
parser.add_argument("--save_interval", type=int, default=10, help="The number of epochs to save a model")
args = parser.parse_args()

# load dataset
print("Loading Data...")
data_reader = DataReader(args.dataset)

X_train, X_test = data_reader.training_data, data_reader.test_data
# N_train = 5000
# N_val = 1000
# N_test = 5000

# X_train = sample_2d_data(args.dataset, N_train)
# X_val = sample_2d_data(args.dataset, N_val)
# X_test = sample_2d_data(args.dataset, N_test)

train_dl = DataLoader(TensorDataset(X_train), batch_size=512, shuffle=True, num_workers=10)
test_dl = DataLoader(TensorDataset(X_test), batch_size=512, shuffle=True, num_workers=10)

# build model
print("Initiating Model...")
model = None
if args.model == 'FCNet':
    model = FCNet(in_dim=20, out_dim=1, l_hidden=(100, 100), activation='relu', out_activation='linear')
elif args.model == 'ConvNet':
    model = ConvNet(in_chan=1, out_chan=1)

if torch.cuda.is_available:
    model.cuda()

# model = torch.nn.DataParallel(model, device_ids=[0, 1])
opt = Adam(model.parameters(), lr=args.lr)

# initial log files
now = datetime.now()
date_time_str_dir = now.strftime("%H:%M:%S-%b-%d-%Y")
os.mkdir(f'../EBM_Result/logs/log_{date_time_str_dir}')
# initial model dir
os.mkdir(f'../EBM_Result/models/model_{date_time_str_dir}')

mean_losses = []
test_energy = {}
train_energy = []
train_neg_energy = []
rand_energy = {}
# train loop
print("Start Training...")
start = time.time()
for i_epoch in tqdm(range(args.n_epoch)):
    l_loss = []
    energy = []
    neg_energy = []
    info = f'EPOCH {i_epoch}: '
    for pos_x, in train_dl:

        pos_x = pos_x.cuda()
        # pos_x = pos_x
        
        neg_x = torch.randn_like(pos_x).cuda()
        neg_x = sample_langevin(neg_x, model, args.stepsize, args.n_step, intermediate_samples=False).cuda()
        
        opt.zero_grad()
        pos_out = model(pos_x)
        energy.append(pos_out.mean().item())
        neg_out = model(neg_x)
        neg_energy.append(neg_out.mean().item())    
        

        loss = (pos_out - neg_out) + args.alpha * (pos_out ** 2 + neg_out ** 2)
        loss = loss.mean()
        loss.backward()
        
        torch.nn.utils.clip_grad_norm_(model.parameters(), max_norm=0.1)
        opt.step()
        
        l_loss.append(loss.item())
    
    mean_losses.append(np.mean(l_loss))
    train_energy.append(np.mean(energy))
    train_neg_energy.append(np.mean(neg_energy))
    now = datetime.now()
    date_time_str = now.strftime("%H:%M:%S-%b-%d-%Y")
    result_path = f"../EBM_Result/logs/log_{date_time_str_dir}/log_"+str(i_epoch) + ".txt"
    with open(result_path, "a") as f:
    	for loss in l_loss:
    		f.write(str(loss)+' ')
    	f.write(f"\nMean Loss: {np.mean(l_loss)}")
    info += f'Mean Loss = {np.mean(l_loss) : <14}, '
        
    if i_epoch % args.save_interval == 0:
        # save model
        torch.save(model.state_dict(), f'../EBM_Result/models/model_{date_time_str_dir}/model_{i_epoch}.pkl')

        # test model
        model.eval()
        test_outs = []
        rand_outs = []
        for test_x, in test_dl:
            test_x = pos_x.cuda()    
            test_out = model(test_x)        
            test_outs.append(test_out.mean().item())
            rand = torch.randn_like(pos_x).cuda()
            rand_out = model(rand)
            rand_outs.append(rand_out.mean().item())  

        test_energy[i_epoch] = np.mean(test_outs)
        rand_energy[i_epoch] = np.mean(rand_outs)

        info += f"Train Model Energy: {np.mean(energy) : <14} "
        info += f"Test Model Energy: {np.mean(test_outs) : <14} "
        info += f"Langevin Sampled Energy: {np.mean(neg_energy) : <14} "
        info += f"Random Test Energy: {np.mean(rand_outs) : <14} "

        model.train()
    print(info)
end = time.time()
print("Training time: ", end - start)
# draw samples 
print("Start Plotting...")
fig = plt.figure(1)
plt.plot(mean_losses)
plt.xlabel("Epochs")
plt.ylabel("Loss")
plt.title("EBM Training Loss")
fig.savefig(f"./loss_imgs/loss_{date_time_str_dir}.png", dpi=1200)

energy_fig = plt.figure(2)
plt.plot(train_energy, label='Train Energy')
plt.plot(train_neg_energy, label='Langevin Sampled Energy')
plt.plot([*test_energy.keys()], [*test_energy.values()], label='Test Energy')
plt.plot([*rand_energy.keys()], [*rand_energy.values()], label='Random Energy')
plt.xlabel("Epochs")
plt.ylabel("Energy")
plt.legend()
plt.title("EBM Energy")
energy_fig.savefig(f"./energy_imgs/energy_{date_time_str_dir}.png", dpi=1200)