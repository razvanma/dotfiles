import code
import sys
import time
from pynput.keyboard import Key, Listener

# colorize Python's exception text
from IPython.core import ultratb
sys.excepthook = ultratb.FormattedTB(mode='Verbose', color_scheme='Linux', call_pdb=False)

from nes_py.wrappers import JoypadSpace
import gym_super_mario_bros
from gym_super_mario_bros.actions import SIMPLE_MOVEMENT

import numpy as np
import torch
import torch.nn as nn
from torch.nn import Conv2d, BatchNorm2d, ReLU, MaxPool2d, Sequential, Linear
from torch.distributions.categorical import Categorical

# Allows breaking into the interpreter on the delete key
pause = False
exit_app = False
def go_interactive(key):
    global pause
    global exit_app
    if key == Key.delete:
        pause = True
    if key == Key.esc:
        exit_app = True


class ExperienceBuffer:
    def __init__(self, state_shape, action_shape, length):
        state_buf_shape = (length, *state_shape)
        self.state_buf = np.zeros(state_buf_shape, np.float32)
        self.state_val_buf = np.zeros(state_buf_shape, np.float32)
        
        if np.isscalar(action_shape):
            action_buf_shape = (length, action_shape)
        else:
            action_buf_shape = (length, *action_shape)
        self.action_buf = np.zeros(action_buf_shape, np.float32)

        self.ptr = 0
        self.length = length

    def record(self, state, action, state_val):
        self.state_buf[self.ptr] = state
        self.action_buf[self.ptr] = action
        self.state_val_buf[self.ptr] = state_val
        self.ptr += 1


class ConvNet(nn.Module):
    def __init__(self, obs_space, num_logits=1):
        super(ConvNet, self).__init__()

        conv_output_channels = 24
        stride = 2
        num_conv_layers = 2
        self.cnn_layers = nn.Sequential(
            # Keep in mind:
            #  - input channels
            #  - output channels = number of features
            #  - kernel_size = image feature size
            #  - stride in combination with padding sizes
            Conv2d(obs_space.shape[2], 6, kernel_size=5, stride=1, padding=2),
            BatchNorm2d(6),
            ReLU(inplace=True),
            MaxPool2d(kernel_size=3, stride=stride, padding=1),

            # Another layerriok
            Conv2d(6, conv_output_channels, kernel_size=5, stride=1, padding=2),
            BatchNorm2d(conv_output_channels),
            ReLU(inplace=True),
            MaxPool2d(kernel_size=3, stride=stride, padding=1),
        )

        h = obs_space.shape[0]
        w = obs_space.shape[1]
        self.linear_layers = Sequential(Linear(
            int(conv_output_channels * h/stride/num_conv_layers * w/stride/num_conv_layers),
            num_logits))

    # Defining the forward pass    
    def forward(self, x):
        x = self.cnn_layers(x)
        x = x.view(x.size(0), -1)
        x = self.linear_layers(x)
        return x

epochs = 50
steps = 5000
exp_buf = None

env = gym_super_mario_bros.make('SuperMarioBros-v0')
env = JoypadSpace(env, SIMPLE_MOVEMENT)
state = env.reset()
exp_buf = ExperienceBuffer(state.shape,
                           (env.action_space.n),
                           steps)

# Define our policy network
pi = ConvNet(env.observation_space, num_logits=env.action_space.n)
val_net = ConvNet(env.observation_space, num_logits=1)

done = False
with Listener(on_press=go_interactive) as listener:
    for step in range(steps):
        # Note that torch doesn't support negative numpy strides
        # Also, we need the inputs to be floats, not Bytes
        state_tensor = torch.from_numpy(np.ascontiguousarray(state)).float()

        # The first dimension must be a batch dimension, create it now.
        state_tensor = state_tensor.unsqueeze(0)

        # The observations are now in NHWC, but we need them in NCHW
        state_tensor = state_tensor.permute(0, 3, 1, 2)

        with torch.no_grad():
            # Compute our CURRENT value and NEXT action
            pi_logits = pi(state_tensor)
            action_model = Categorical(logits=pi_logits)
            action = action_model.sample()
            action_logp = action_model.log_prob(action)
            action = action.item()
            state_val = val_net(state_tensor).squeeze(-1).item()

        # Do our NEXT action
        state, reward, done, info = env.step(action)

        # Record the effect of taking our action
        exp_buf.record(state, action, state_val)

        # Facilitates reasonable x11 viz
        # Make sure to first run 'export DISPLAY=unix:0'
        time.sleep(0.01)
        env.render()

        # Hit delete to drop into the interactive shell
        if pause: code.interact(local=locals()); pause = False
        if exit_app: sys.exit()

env.close()
