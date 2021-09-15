import time
from nes_py.wrappers import JoypadSpace
import gym_super_mario_bros
from gym_super_mario_bros.actions import SIMPLE_MOVEMENT

env = gym_super_mario_bros.make('SuperMarioBros-v0')
env = JoypadSpace(env, SIMPLE_MOVEMENT)

done = True
for step in range(5000):
    if done:
        state = env.reset()

    # Facilitates reasonable x11 viz
    # Make sure to first run 'export DISPLAY=unix:0'
    time.sleep(0.01)

    state, reward, done, info = env.step(env.action_space.sample())
    env.render()

env.close()
