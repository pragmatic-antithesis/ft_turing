module TuringMachine where

import Data.Map qualified as Map
import Data.Text qualified as T
import GHC.Generics (Generic)

data TuringMachine = TuringMachine
  {
    name :: T.Text,
    alphabet :: [T.Text],
    blank :: T.Text,
    states :: [T.Text],
    initial :: T.Text,
    finals :: [T.Text],
    transitions :: Map.Map T.Text [Transition]
  }
  deriving (Show, Generic)

data Transition = Transition
  {
    readChar :: T.Text,
    toState :: T.Text,
    writeChar :: T.Text,
    action :: Action
  }
  deriving (Show, Generic)

data Action = Left | Right
  deriving (Show, Eq, Generic)
