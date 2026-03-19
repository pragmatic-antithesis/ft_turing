{-# LANGUAGE OverloadedStrings #-}

module Json where

import Data.Aeson (FromJSON, eitherDecode, withObject, withText, (.:))
import Data.Aeson qualified as Aeson
import Data.Aeson.Key qualified as Key
import Data.Aeson.KeyMap qualified as KM
import Data.Aeson.Types (Parser)
import Data.ByteString.Lazy qualified as B
import Data.Map qualified as Map
import Data.Text qualified as T
import TuringMachine

newtype JsonAction = JsonAction Action

newtype JsonTransition = JsonTransition Transition

newtype JsonTuringMachine = JsonTuringMachine TuringMachine

instance FromJSON JsonAction where
  parseJSON = withText "Action" $ \t ->
    case t of
      "LEFT" -> pure $ JsonAction TuringMachine.Left
      "RIGHT" -> pure $ JsonAction TuringMachine.Right
      _ -> fail $ "Invalid action: " ++ T.unpack t

instance FromJSON JsonTransition where
  parseJSON = withObject "Transition" $ \v -> do
    readChar <- v .: "read"
    toState <- v .: "to_state"
    writeChar <- v .: "write"
    JsonAction action <- v .: "action"
    pure $
      JsonTransition $
        Transition readChar toState writeChar action

instance FromJSON JsonTuringMachine where
  parseJSON = withObject "TuringMachine" $ \v -> do
    name <- v .: "name"
    alphabet <- v .: "alphabet"
    blank <- v .: "blank"
    states <- v .: "states"
    initial <- v .: "initial"
    finals <- v .: "finals"

    transitionsObj <- (v .: "transitions" :: Parser Aeson.Object)
    transitions <- parseTransitions transitionsObj

    pure $
      JsonTuringMachine $
        TuringMachine name alphabet blank states initial finals transitions

parseTransitions :: Aeson.Object -> Parser (Map.Map T.Text [Transition])
parseTransitions obj = do
  let pairs = KM.toList obj
  parsed <- mapM parsePair pairs
  pure $ Map.fromList parsed
  where
    parsePair (k, v) = do
      ts <- Aeson.parseJSON v -- [JsonTransition]
      let transitions = [t | JsonTransition t <- ts]
      pure (Key.toText k, transitions)

-- File reader
readTuringMachine :: FilePath -> IO (Either String TuringMachine)
readTuringMachine filePath = do
  jsonData <- B.readFile filePath
  case eitherDecode jsonData of
    Prelude.Left err -> pure $ Prelude.Left err
    Prelude.Right (JsonTuringMachine tm) -> pure $ Prelude.Right tm
