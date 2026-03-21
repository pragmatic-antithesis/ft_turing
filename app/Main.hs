module Main where

import Args (parseArgs)
import Data.Map qualified as Map
import Data.Text qualified as T
import Json (readTuringMachine)
import Shared (exit)
import System.Environment (getArgs)
import TuringMachine

main :: IO ()
main = do
  args <- getArgs
  case parseArgs args of
    Prelude.Left message -> exit message
    Prelude.Right (x, y) -> do
      result <- readTuringMachine x
      case result of
        Prelude.Left err -> putStrLn $ "Error parsing JSON: " ++ err
        Prelude.Right machine -> do
          putStrLn $ "Machine name: " ++ T.unpack (name machine)
          putStrLn $ "Initial state: " ++ T.unpack (initial machine)
          putStrLn $ "Number of transitions: " ++ show (length (transitions machine))

          case Map.lookup (T.pack "scanright") (transitions machine) of
            Nothing -> putStrLn "No transitions for scanright"
            Just transitionsList -> do
              putStrLn "\nTransitions for scanright:"
              mapM_ printTransition transitionsList

printTransition :: Transition -> IO ()
printTransition t =
  putStrLn $
    "  Read: "
      ++ T.unpack (readChar t)
      ++ " -> "
      ++ T.unpack (toState t)
      ++ ", Write: "
      ++ T.unpack (writeChar t)
      ++ ", Action: "
      ++ show (action t)
