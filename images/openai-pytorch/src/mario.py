import code
import numpy as np
import sys
import time
from pynput.keyboard import Key, Listener

# colorize Python's exception text
from IPython.core import ultratb
sys.excepthook = ultratb.FormattedTB(mode='Verbose', color_scheme='Linux', call_pdb=False)

from nes_py.wrappers import JoypadSpace
import gym_super_mario_bros
from gym_super_mario_bros.actions import SIMPLE_MOVEMENT

env = gym_super_mario_bros.make('SuperMarioBros-v0')
env = JoypadSpace(env, SIMPLE_MOVEMENT)

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

        if np.isscalar(action_shape):
            action_buf_shape = (length, action_shape)
        else:
            action_buf_shape = (length, *action_shape)
        self.action_buf = np.zeros(action_buf_shape, np.float32)

        self.ptr = 0
        self.length = length

    def record(self, state, action):
        self.state_buf[self.ptr] = state
        self.action_buf[self.ptr] = action
        self.ptr += 1


epochs = 50
steps = 5000
done = True
exp_buf = None

with Listener(on_press=go_interactive) as listener:
    for step in range(steps):
        if done:
            state = env.reset()

        action = env.action_space.sample()
        state, reward, done, info = env.step(action)

        # Initialize our experience buffer
        if not exp_buf:
            exp_buf = ExperienceBuffer(
                    state.shape,
                    (env.action_space.n),
                    steps)
        exp_buf.record(state, action)

        # Facilitates reasonable x11 viz
        # Make sure to first run 'export DISPLAY=unix:0'
        time.sleep(0.01)
        env.render()

        # Hit delete to drop into the interactive shell
        if pause: code.interact(local=locals()); pause = False
        if exit_app: sys.exit()

env.close()
