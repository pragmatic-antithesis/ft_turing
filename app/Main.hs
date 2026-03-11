module Main where

import MyLib qualified (someFunc)
import System.Environment
import System.Exit

main :: IO ()
main = do
  args <- getArgs
  exitCode <- runProgram args
  case exitCode of
    0 -> exitSuccess
    n -> exitWith (ExitFailure n)

runProgram :: [String] -> IO Int
runProgram [x] = MyLib.someFunc x
runProgram _ = return 1
