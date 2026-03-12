module Main where

import Args qualified (parseArgs)
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
runProgram x = Args.parseArgs x
