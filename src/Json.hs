{-# LANGUAGE OverloadedStrings #-}

module Json (parseTuringMachine) where

import Data.Aeson
import Data.Aeson qualified as A
import Data.ByteString.Lazy qualified as B
import Data.Map.Strict qualified as Map
import Data.Text qualified as T
import TuringMachine

parseTuringMachine :: FilePath -> IO (Either String TuringMachine)
parseTuringMachine filePath = do
  jsonData <- B.readFile filePath
  pure $ A.eitherDecode jsonData >>= parseMachine

data RawMachine = RawMachine
  { rName :: T.Text,
    rAlphabet :: [T.Text],
    rBlank :: T.Text,
    rStates :: [T.Text],
    rInitial :: T.Text,
    rFinals :: [T.Text],
    rTransitions :: Map.Map T.Text [RawTransition]
  }

data RawTransition = RawTransition
  { rRead :: T.Text,
    rToState :: T.Text,
    rWrite :: T.Text,
    rAction :: T.Text
  }

instance FromJSON RawMachine where
  parseJSON = withObject "TuringMachine" $ \obj ->
    RawMachine
      <$> obj .: "name"
      <*> obj .: "alphabet"
      <*> obj .: "blank"
      <*> obj .: "states"
      <*> obj .: "initial"
      <*> obj .: "finals"
      <*> obj .: "transitions"

instance FromJSON RawTransition where
  parseJSON = withObject "Transition" $ \obj ->
    RawTransition
      <$> obj .: "read"
      <*> obj .: "to_state"
      <*> obj .: "write"
      <*> obj .: "action"

parseMachine :: RawMachine -> Either String TuringMachine
parseMachine raw = do
  let name = T.unpack (rName raw)
  alphabet <- mapM parseChar (rAlphabet raw)
  blank <- parseChar (rBlank raw)
  let states = map T.unpack (rStates raw)
      initial = T.unpack (rInitial raw)
      finals = map T.unpack (rFinals raw)

  transitionsList <- concat <$> mapM parseState (Map.toList (rTransitions raw))

  let transitions = Map.fromList transitionsList

  pure $
    TuringMachine
      { name = name,
        alphabet = alphabet,
        blank = blank,
        states = states,
        initialState = initial,
        finalStates = finals,
        transitions = transitions
      }

parseState ::
  (T.Text, [RawTransition]) ->
  Either String [((State, Symbol), Transition)]
parseState (stateTxt, transitions) = do
  let state = T.unpack stateTxt
  mapM (parseOne state) transitions

parseOne ::
  State ->
  RawTransition ->
  Either String ((State, Symbol), Transition)
parseOne state raw = do
  readSym <- parseChar (rRead raw)
  writeSym <- parseChar (rWrite raw)
  dir <- parseDirection (rAction raw)

  let nextState = T.unpack (rToState raw)

  pure ((state, readSym), Transition nextState writeSym dir)

parseChar :: T.Text -> Either String Char
parseChar t =
  case T.unpack t of
    [c] -> Right c
    _ -> Left $ "Expected single character, got: " ++ T.unpack t

parseDirection :: T.Text -> Either String Direction
parseDirection t =
  case t of
    "RIGHT" -> Right 1
    "LEFT" -> Right (-1)
    _ -> Left $ "Invalid direction: " ++ T.unpack t
