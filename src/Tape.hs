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
applyTransition blank (Transition _ writeSym dir) tape =
  move blank dir (writeSymbol writeSym tape)
  where
    writeSymbol sym (Tape l _ r) = Tape l sym r

move :: Symbol -> Direction -> Tape -> Tape
move _ (-1) (Tape (l : ls) cur r) = Tape ls l (cur : r)
move blank (-1) (Tape [] cur r) = Tape [] blank (cur : r)
move _ 1 (Tape l cur (r : rs)) = Tape (cur : l) r rs
move blank 1 (Tape l cur []) = Tape (cur : l) blank []
move _ d _ = error ("Invalid direction: " ++ show d)

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
