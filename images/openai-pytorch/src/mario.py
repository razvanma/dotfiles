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

import scipy.signal
import numpy as np

import torch
import torch.nn as nn
from torch.optim import Adam
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


def discount_cumsum(x, discount):
    """
    magic from rllab for computing discounted cumulative sums of vectors.
    input: 
        vector x, 
        [x0, 
         x1, 
         x2]
    output:
        [x0 + discount * x1 + discount^2 * x2,  
         x1 + discount * x2,
         x2]
    """
    return scipy.signal.lfilter([1], [1, float(-discount)], x[::-1], axis=0)[::-1]

class ExperienceBuffer:
    def __init__(self, state_shape, action_shape, max_length, gamma=0.99, lam=0.95):
        self.ptr = 0
        self.max_length = max_length

        state_buf_shape = (max_length, *state_shape)
        self.states = np.zeros(state_buf_shape, np.float32)

        # The loss will be computed from the rewards and the logp(action)
        # under the current policy.
        self.action_logp = np.zeros(max_length, np.float32)

        # The state value will be used in computing the advantage, which is
        # used in computing losses.
        self.state_values = np.zeros(max_length, np.float32)
        self.rewards = np.zeros(max_length, np.float32)

        if np.isscalar(action_shape):
            action_buf_shape = (max_length, action_shape)
        else:
            action_buf_shape = (max_length, *action_shape)
        self.actions = np.zeros(action_buf_shape, np.float32)

        # At the end of a trajectory, we use ptr start to go back and update
        # return-to-go and advantage 
        self.ptr_start = 0

        # Will hold advantage of the actual action taken, relative to the estimated
        # value of the state, computeda at the end of each trajectory.
        self.action_adv = np.zeros(max_length, np.float32) 
        self.rewards_to_go = np.zeros(max_length, np.float32) 

        self.gamma = gamma
        self.lam = lam

    def last_traj_len(self):
        return self.ptr - self.ptr_start

    def record_step(self, state, action, state_value, action_logp, reward):
        self.states[self.ptr] = state
        self.actions[self.ptr] = action
        self.state_values[self.ptr] = state_value
        self.action_logp[self.ptr] = action_logp
        self.rewards[self.ptr] = reward
        self.ptr += 1

    def end_trajectory(self, final_reward_to_go):
        # Note that final_reward_to_go is an estimate of the infinite
        # ctg for after the end of the trajecctory.

        # Use this slice to index and update trajectory values
        traj_slice = slice(self.ptr_start, self.ptr)

        # Temporarily augment ACTUAL rewards with our final ESTIMATED
        # values-to-go for the purpose of computing deltas below.
        rewards = np.append(
                self.rewards[traj_slice],
                final_reward_to_go)
        state_values = np.append(
                self.state_values[traj_slice],
                final_reward_to_go)

        # Compute GAE-Lambda using the discounted deltas
        # Notice that the action_adv compares ACTUAL rewards to
        # rewards-to-go ESTIMATED by our state_values model.
        deltas = (rewards[:-1]
                + self.gamma * state_values[1:]
                - state_values[:-1])

        self.action_adv[traj_slice] = discount_cumsum(
                deltas,
                self.gamma * self.lam)

        # Save all but the final reward.  Rewards-to-go will be used to
        # train our state_value model at the end of the epoch.
        self.rewards_to_go[traj_slice] = discount_cumsum(
                rewards,
                self.gamma
                )[:-1]

        self.ptr_start = self.ptr

    def get_and_reset(self):
        assert self.ptr == self.max_length
        self.ptr, self.ptr_start = 0, 0

        # Normalize the advantage
        self.action_adv -= self.action_adv.mean()
        self.action_adv /= self.action_adv.std()

        # Convert the numpy arrays into pytorch tensors and
        # return them as a dictionary.
        data = dict(
                states=self.states,
                actions=self.actions,
                state_values=self.state_values,
                action_logp=self.action_logp,
                rewards=self.rewards,
                action_adv=self.action_adv)
        return {k: torch.as_tensor(v, dtype=torch.float32) for k,v in data.items()}


# TODO: Notice how we're abusing this class for implementing
#       both pi and the value net
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

    def _tensor_from_state(self, state):
        # Note that torch doesn't support negative numpy strides
        # Also, we need the inputs to be floats, not Bytes
        state_tensor = torch.from_numpy(np.ascontiguousarray(state)).float()

        # The first dimension must be a batch dimension, create it now.
        state_tensor = state_tensor.unsqueeze(0)

        # The observations are now in NHWC, but we need them in NCHW
        return state_tensor.permute(0, 3, 1, 2)

    def compute_action(self, state):
        with torch.no_grad():
            state_tensor = self._tensor_from_state(state)
            pi_logits = self(state_tensor)
            action_model = Categorical(logits=pi_logits)

            # Compute log(prob(action)) under our policy model
            action = action_model.sample()
            action_logp = action_model.log_prob(action)

            return action.item(), action_logp

    def compute_state_value(self, state):
        with torch.no_grad():
            # Compute the value of the state BEFORE acting BUGBUG
            state_tensor = self._tensor_from_state(state)
            state_value = self(state_tensor).squeeze(-1).item()
            return state_value

# After each epoch, we train, clear our experience buffer and
# reset the environment.
max_epochs = 50

# Governs number of steps to take between training.
max_steps_per_epoch = 200

# Each individual trajectory  can have a maximum length.  This is to
# prevent trying to learn across piontlessly-long sequences.
max_traj_len = 100

# Random seeds
seed = 12345
torch.manual_seed(seed)
np.random.seed(seed)

# Set up environment
env = gym_super_mario_bros.make('SuperMarioBros-v0')
env = JoypadSpace(env, SIMPLE_MOVEMENT)
state = env.reset()

# Set up buffer for recording states, actions, rewards, advantages, etc.
# Note that our experience buffer holds MULTIPLE trajectories.
# The life of the experience buffer is one epoch, then it should be reset.
exp_buf = ExperienceBuffer(state.shape,
                           (env.action_space.n),
                           max_steps_per_epoch)

# Define our policy network
pi_net = ConvNet(env.observation_space, num_logits=env.action_space.n)

# For estimating discounted rewards-to-go given state
value_net = ConvNet(env.observation_space, num_logits=1)
done = False

# Initialize our optimizers, note the learning reates
pi_optimizer = Adam(pi_net.parameters(), lr=3e-4)
value_optimizer = Adam(value_net.parameters(), lr=1e-3)

# Dummy step to get out a first info state.
_, _, _, info = env.step(0)
last_life = info["life"]

with Listener(on_press=go_interactive) as listener:
    for epoch in range(max_epochs):
        for step in range(max_steps_per_epoch):

            # TODO: note that if we had a dynamics model, we could use
            #       our value function with look-aheads to compute
            #       non-greedy actions.

            # Compute our CURRENT value and NEXT action
            action, action_logp = pi_net.compute_action(state)

            # Calculate state_value, used for computing GAE at the
            # end of the trajectory and logged in the experience
            # buffer for training our value_net to estimate the
            # rewards-to-go at the end of the epoch.
            state_value = value_net.compute_state_value(state)

            # Do our NEXT action
            #
            # Reward = velocity + clock_ticks_penalty + death_penalty
            # Reward is capped between -15 and 15.
            #   See https://pypi.org/project/gym-super-mario-bros/ 
            state, reward, done, info = env.step(action)
            if info["life"] < last_life:
                reward = -15

            # Record the effect of taking our action
            exp_buf.record_step(state, action, state_value, action_logp, reward)

            # TODO: In the future value novelty rather than de-valuing death
            # TODO: Relatedly, consider detecting if we're failing to make
            #       progress for too long and reset.

            # Note that "life" is stored as an unsigned BYTE
            died = info["life"] < last_life or info["life"] == 255

            if (exp_buf.last_traj_len() >= max_traj_len
                    or step == max_steps_per_epoch - 1
                    or died):

                if died:
                    print("Died")
                if exp_buf.last_traj_len() >= max_traj_len:
                    print("Ending long trajectory.")
                if done:
                    print("Done=True")

                # Compute the value of the state AFTER acting
                if died:
                    state_value = -15
                else: # didn't die
                    if done:
                        # success == finished and didn't die
                        state_value = 15
                    else: # bootstrap the reward-to-go
                        state_value = value_net.compute_state_value(state)

                # Start over if done, regardless of whether we won or lost.
                if done:
                    env.reset()

                # Update rewards-to-go and advantage
                exp_buf.end_trajectory(state_value)

            # useful for calculating if we died later.
            last_life = info["life"]

            # Facilitates reasonable x11 viz
            # Make sure to first run 'export DISPLAY=unix:0'
            time.sleep(0.01)
            env.render()

            # Hit delete to drop into the interactive shell
            if pause: code.interact(local=locals()); pause = False
            if exit_app: sys.exit()

        # End of an episode, train on our buffer and reset
        data = exp_buf.get_and_reset()

        # TODO: consider randomly saving and restoring the state
        #       to speed up learning.
        

env.close()
