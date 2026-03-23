module Main where

import Args (parseArgs)
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
        Left err -> S.exit err
        Right machine -> do
          S.printMachineInfo machine

          runner <- runMachine machine input
          case runner of
            Left err -> S.exit err
            Right trace -> S.printExecutionTrace machine trace
