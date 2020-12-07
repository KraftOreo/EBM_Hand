import numpy as np
import torch


class DataReader:
    def __init__(self, path, shuffle=True, split_percentage=None):
        if split_percentage is None:
            split_percentage = {'train': 0.8, 'test': 0.2}
        self.path = path
        self.shuffle = shuffle
        self.data = self.load_data_torch()
        self.training_data, self.test_data = self.split(split_percentage)

    def load_data_torch(self):
        data = []
        with open(self.path, 'r') as f:
            for line in f:
                data.append([float(i) for i in line.split(',')])
        data = torch.tensor(data)
        if self.shuffle:
            data = data[torch.randperm(data.size()[0])]
        return data

    def split(self, split_percentage):
        size = self.data.size(0)
        split_sizes = [*map(lambda x: int(x * size), split_percentage.values())]
        return torch.split(self.data, split_sizes)


if __name__ == '__main__':
    dataloader = DataReader(r"./degree_data.txt")
    print(dataloader.validation_data)
