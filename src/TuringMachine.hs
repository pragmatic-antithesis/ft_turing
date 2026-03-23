module TuringMachine where

import Data.Map.Strict qualified as Map

type State = String

type Symbol = Char

type Direction = Int

data Transition = Transition State Symbol Direction
  deriving (Show)

data TuringMachine = TuringMachine
  { name :: String,
    alphabet :: [Symbol],
    blank :: Symbol,
    states :: [State],
    initialState :: State,
    finalStates :: [State],
    transitions :: Map.Map (State, Symbol) Transition
  }
  deriving (Show)
