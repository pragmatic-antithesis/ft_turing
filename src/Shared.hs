module Shared where

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
  putStrLn $ "Alphabet: [ " ++ unwords (map show $ alphabet machine) ++ " ]"
  putStrLn $ "States : [ " ++ unwords (states machine) ++ " ]"
  putStrLn $ "Initial : " ++ initialState machine
  putStrLn $ "Finals : [ " ++ unwords (finalStates machine) ++ " ]"
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

printExecutionTrace :: [(State, Tape)] -> IO ()
printExecutionTrace [] = return ()
printExecutionTrace [(state, tape)] = do
  putStrLn $ "\nMachine halted in state: " ++ state
  putStrLn $ "Final tape: " ++ showTapeWithHead tape
printExecutionTrace ((state, tape) : rest) = do
  putStrLn $ showTapeWithHead tape ++ " (current state: " ++ state ++ ")"
  printExecutionTrace rest
