module Shared where

import Data.List (intercalate)
import Data.Map as Map
import System.Exit
import System.IO (hPutStrLn, stderr)
import Tape
import TuringMachine

exit :: String -> IO ()
exit msg = do
  if msg == helpMessage
    then do
      putStrLn msg
      exitSuccess
    else do
      hPutStrLn stderr msg
      exitWith (ExitFailure 1)

showUsage :: String
showUsage = "usage: ft_turing [-h] jsonfile input"

helpMessage :: String
helpMessage = "usage: ft_turing [-h] jsonfile input\n\npositional arguments:\n  jsonfile\tjson description of the machine\n\n  input\t\tinput of the machine\n\noptional arguments:\n  -h, --help\tshow this help message and exit"

printMachineInfo :: TuringMachine -> IO ()
printMachineInfo machine = do
  putStrLn $ replicate 80 '*'
  putStrLn $ "*" ++ replicate 78 ' ' ++ "*"
  putStrLn $ "* " ++ initialState machine ++ " *"
  putStrLn $ "*" ++ replicate 78 ' ' ++ "*"
  putStrLn $ replicate 80 '*'
  putStrLn $ "Alphabet: [ " ++ intercalate ", " (Prelude.map (: []) (alphabet machine)) ++ " ]"
  putStrLn $ "States : [ " ++ intercalate ", " (states machine) ++ " ]"
  putStrLn $ "Initial : " ++ initialState machine
  putStrLn $ "Finals : [ " ++ intercalate ", " (finalStates machine) ++ " ]"
  mapM_ (uncurry printTransition) (Map.toList (transitions machine))
  putStrLn $ replicate 80 '*'

printTransition :: (State, Symbol) -> Transition -> IO ()
printTransition (state, sym) (Transition nextState writeSym dir) = do
  putStrLn $
    "("
      ++ state
      ++ ", "
      ++ [sym]
      ++ ") -> ("
      ++ nextState
      ++ ", "
      ++ [writeSym]
      ++ ", "
      ++ showDir dir
      ++ ")"
  where
    showDir (-1) = "LEFT"
    showDir 1 = "RIGHT"
    showDir d = "UNKNOWN(" ++ show d ++ ")"

printExecutionTrace :: TuringMachine -> [(State, Tape)] -> IO ()
printExecutionTrace _ [] = return ()
printExecutionTrace _ [(state, tape)] = do
  putStrLn $ "\nMachine halted in state: " ++ state
  putStrLn $ "Final tape: " ++ showTapeWithHead tape
printExecutionTrace machine ((state, tape) : rest) = do
  let sym = current tape

  case Map.lookup (state, sym) (transitions machine) of
    Nothing ->
      putStrLn $ showTapeWithHead tape ++ " (no transition)"
    Just (Transition to write dir) ->
      putStrLn $
        showTapeWithHead tape
          ++ " ("
          ++ state
          ++ ", "
          ++ [sym]
          ++ ") -> ("
          ++ to
          ++ ", "
          ++ [write]
          ++ ", "
          ++ showDir dir
          ++ ")"

  printExecutionTrace machine rest
  where
    showDir (-1) = "LEFT"
    showDir 1 = "RIGHT"
    showDir d = "UNKNOWN(" ++ show d ++ ")"
