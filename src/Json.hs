{-# LANGUAGE OverloadedStrings #-}

module Json (parseTuringMachine) where

import Data.Aeson (FromJSON (..), Value (..), withArray, withObject, (.:))
import Data.Aeson qualified as A
import Data.ByteString.Lazy qualified as B
import Data.Map qualified as Map
import Data.Text qualified as T
import Data.Vector qualified as V
import TuringMachine

parseTuringMachine :: FilePath -> IO (Either String TuringMachine)
parseTuringMachine filePath = do
  jsonData <- B.readFile filePath
  pure $ do
    JsonMachine tm <- A.eitherDecode jsonData
    return tm

newtype JsonMachine = JsonMachine TuringMachine

newtype JsonTransition = JsonTransition Transition

instance FromJSON JsonMachine where
  parseJSON = withObject "TuringMachine" $ \obj -> do
    alphaStrings <- obj .: "alphabet"
    stateStrings <- obj .: "states"
    initStateStr <- obj .: "initial"
    finalStateStrs <- obj .: "finals"
    transObj <- obj .: "transitions"

    let statesList = map T.unpack stateStrings
        finalList = map T.unpack finalStateStrs
        initState = T.unpack initStateStr

    alphabetChars <- mapM parseChar alphaStrings

    transList <- mapM parseOne (Map.toList transObj)
    let transMap = Map.fromList transList

    return $
      JsonMachine $
        TuringMachine
          { alphabet = alphabetChars,
            states = statesList,
            initialState = initState,
            finalStates = finalList,
            transitions = transMap
          }
    where
      parseChar (String t) =
        let str = T.unpack t
         in case str of
              [c] -> return c
              _ -> fail $ "Expected single character, got: " ++ str
      parseChar _ = fail "Expected string for alphabet"

      parseOne (key, val) = do
        let (state, sym) = parseKey key
        JsonTransition trans <- parseJSON val
        return ((state, sym), trans)

parseKey :: T.Text -> (State, Symbol)
parseKey t =
  let str = T.unpack t
      (statePart, rest) = break (== ',') str
      symPart = drop 1 rest
      sym = case symPart of
        [] -> '.'
        (c : _) -> c
   in (statePart, sym)

instance FromJSON JsonTransition where
  parseJSON = withArray "Transition" $ \vec -> do
    let arr = V.toList vec
    case arr of
      [nextStateVal, writeCharVal, directionVal] -> do
        nextState <- parseJSON nextStateVal
        writeChar <- parseJSON writeCharVal
        directionStr <- parseJSON directionVal
        dir <- case directionStr of
          "RIGHT" -> return 1
          "LEFT" -> return (-1)
          _ -> fail $ "Invalid direction: " ++ directionStr
        return $ JsonTransition $ Transition nextState writeChar dir
      _ -> fail "Transition must have exactly 3 elements"
