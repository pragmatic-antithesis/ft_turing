module Tape where

import Data.Map qualified as Map
import TuringMachine

data Tape = Tape
  { left :: [Symbol],
    current :: Symbol,
    right :: [Symbol]
  }
  deriving (Show, Eq)

initialTape :: Symbol -> String -> Tape
initialTape blank [] = Tape [] blank []
initialTape _ (c : cs) = Tape [] c cs

showTapeWithHead :: Tape -> String
showTapeWithHead (Tape l cur r) =
  "[" ++ reverse l ++ "<" ++ [cur] ++ ">" ++ take 20 r ++ "]"

applyTransition :: Symbol -> Transition -> Tape -> Tape
applyTransition blank (Transition _ writeSym dir) (Tape l _ r) =
  move blank dir (Tape l writeSym r)

move :: Symbol -> Direction -> Tape -> Tape
move blank dir (Tape l cur r)
  | dir == -1 = case l of
      (x : xs) -> Tape xs x (cur : r) -- move left
      [] -> Tape [] blank (cur : r) -- extend left with blank
  | dir == 1 = case r of
      (x : xs) -> Tape (cur : l) x xs -- move right
      [] -> Tape (cur : l) blank [] -- extend right with blank
  | otherwise = error ("Invalid direction: " ++ show dir)

stepMachine :: TuringMachine -> State -> Tape -> Maybe (State, Tape)
stepMachine machine state tape = do
  let sym = current tape
  Transition nextState writeSym dir <-
    Map.lookup (state, sym) (transitions machine)
  let newTape = applyTransition (blank machine) (Transition nextState writeSym dir) tape
  return (nextState, newTape)

runMachine :: TuringMachine -> String -> IO (Either String [(State, Tape)])
runMachine machine input = do
  let initial = (initialState machine, initialTape (blank machine) input)
  runSteps initial []
  where
    runSteps :: (State, Tape) -> [(State, Tape)] -> IO (Either String [(State, Tape)])
    runSteps (state, tape) trace
      | state `elem` finalStates machine =
          return $ Right $ reverse ((state, tape) : trace)
    runSteps (state, tape) trace =
      case stepMachine machine state tape of
        Nothing ->
          return $
            Left $
              "Machine blocked at state: "
                ++ state
                ++ ", symbol: "
                ++ [current tape]
        Just (newState, newTape) ->
          runSteps (newState, newTape) ((state, tape) : trace)
