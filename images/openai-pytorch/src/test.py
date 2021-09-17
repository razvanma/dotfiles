import gym
import torch  # this confirms that PyTorch is included
import unittest

class TestImage(unittest.TestCase):

  def test_can_make_classic_control_env(self):
    gym.make("CartPole-v1")

  def test_can_make_box2d_env(self):
    gym.make("LunarLander-v2")

  def test_envs_can_be_recorded(self):
    env_to_wrap = gym.make("CartPole-v1")
    env = gym.wrappers.Monitor(env_to_wrap, "tmpFolder")
    env.reset()
    env.step(0)
    env.close()
    env_to_wrap.close()

if __name__ == "__main__":
  unittest.main()
