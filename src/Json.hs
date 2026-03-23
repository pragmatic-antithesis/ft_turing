{-# LANGUAGE OverloadedStrings #-}

module Json (parseTuringMachine) where

import Data.Aeson
import Data.Aeson qualified as A
import Data.ByteString.Lazy qualified as B
import Data.Map.Strict qualified as Map
import Data.Text qualified as T
import TuringMachine

-- ENTRY POINT -------------------------------------------------------------

parseTuringMachine :: FilePath -> IO (Either String TuringMachine)
parseTuringMachine filePath = do
  jsonData <- B.readFile filePath
  pure $ A.eitherDecode jsonData >>= parseMachine

-- INTERNAL TYPES ----------------------------------------------------------

data RawMachine = RawMachine
  { rAlphabet :: [T.Text],
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

-- FROM JSON INSTANCES -----------------------------------------------------

instance FromJSON RawMachine where
  parseJSON = withObject "TuringMachine" $ \obj ->
    RawMachine
      <$> obj .: "alphabet"
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

-- CONVERSION --------------------------------------------------------------

parseMachine :: RawMachine -> Either String TuringMachine
parseMachine raw = do
  alphabet <- mapM parseChar (rAlphabet raw)

  let states = map T.unpack (rStates raw)
      initial = T.unpack (rInitial raw)
      finals = map T.unpack (rFinals raw)

  transitionsList <- concat <$> mapM parseState (Map.toList (rTransitions raw))

  let transitions = Map.fromList transitionsList

  pure $
    TuringMachine
      { alphabet = alphabet,
        states = states,
        initialState = initial,
        finalStates = finals,
        transitions = transitions
      }

-- PARSE TRANSITIONS -------------------------------------------------------

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

-- HELPERS -----------------------------------------------------------------

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
