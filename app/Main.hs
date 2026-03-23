module Main where

import Args (parseArgs)
import Data.Map qualified as Map
import Json (parseTuringMachine)
import Shared qualified as S
import System.Environment (getArgs)
import Tape

main :: IO ()
main = do
  args <- getArgs
  case parseArgs args of
    Left message -> S.exit message
    Right (machineCandidate, input) -> do
      result <- parseTuringMachine machineCandidate
      case result of
        Left err -> putStrLn $ "Error parsing JSON: " ++ err
        Right machine -> do
          S.printMachineInfo machine
          putStrLn $ replicate 80 '*'

          -- Map.foldlWithKey (\_ k v -> S.printTransition k v) () (transitions machine)
          -- putStrLn $ replicate 80 '*'

          runner <- runMachine machine input
          case runner of
            Left err -> S.exit err
            Right trace -> S.printExecutionTrace trace
