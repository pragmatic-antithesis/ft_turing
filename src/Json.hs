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
  parseJSON = withText "Action" $ \a ->
    case a of
      "LEFT" -> pure $ JsonAction TuringMachine.Left
      "RIGHT" -> pure $ JsonAction TuringMachine.Right
      _ -> fail $ "Invalid action: " ++ T.unpack a

instance FromJSON JsonTransition where
  parseJSON = withObject "Transition" $ \t -> do
    readChar <- t .: "read"
    toState <- t .: "to_state"
    writeChar <- t .: "write"
    JsonAction action <- t .: "action"
    pure $
      JsonTransition $
        Transition readChar toState writeChar action

instance FromJSON JsonTuringMachine where
  parseJSON = withObject "TuringMachine" $ \m -> do
    name <- m .: "name"
    alphabet <- m .: "alphabet"
    blank <- m .: "blank"
    states <- m .: "states"
    initial <- m .: "initial"
    finals <- m .: "finals"

    transitionsObj <- (m .: "transitions" :: Parser Aeson.Object)
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
      ts <- Aeson.parseJSON v
      let transitions = [t | JsonTransition t <- ts]
      pure (Key.toText k, transitions)

readTuringMachine :: FilePath -> IO (Either String TuringMachine)
readTuringMachine filePath = do
  jsonData <- B.readFile filePath
  case eitherDecode jsonData of
    Prelude.Left err -> pure $ Prelude.Left err
    Prelude.Right (JsonTuringMachine tm) -> pure $ Prelude.Right tm
