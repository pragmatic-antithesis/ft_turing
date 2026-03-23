module Tape where

import Data.Map qualified as Map
import TuringMachine

data Tape = Tape
  { left :: [Symbol],
    current :: Symbol,
    right :: [Symbol]
  }
  deriving (Show, Eq)

initialTape :: String -> Tape
initialTape [] = Tape [] '.' []
initialTape (c : cs) = Tape [] c cs

showTapeWithHead :: Tape -> String
showTapeWithHead (Tape l cur r) =
  "[" ++ reverse l ++ "<" ++ [cur] ++ ">" ++ take 20 r ++ "]"

applyTransition :: Transition -> Tape -> Tape
applyTransition (Transition _ writeSym dir) tape =
  move dir (writeSymbol writeSym tape)
  where
    writeSymbol :: Symbol -> Tape -> Tape
    writeSymbol sym (Tape l _ r) = Tape l sym r

move :: Direction -> Tape -> Tape
move (-1) (Tape (l : ls) cur r) = Tape ls l (cur : r)
move (-1) (Tape [] cur r) = Tape [] '.' (cur : r)
move 1 (Tape l cur (r : rs)) = Tape (cur : l) r rs
move 1 (Tape l cur []) = Tape (cur : l) '.' []
move d _ = error ("Invalid direction: " ++ show d)

stepMachine :: TuringMachine -> State -> Tape -> Maybe (State, Tape)
stepMachine machine state tape = do
  let sym = current tape
  Transition nextState writeSym dir <-
    Map.lookup (state, sym) (transitions machine)
  let newTape = applyTransition (Transition nextState writeSym dir) tape
  return (nextState, newTape)

runMachine :: TuringMachine -> String -> IO (Either String [(State, Tape)])
runMachine machine input = do
  let initial = (initialState machine, initialTape input)
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
