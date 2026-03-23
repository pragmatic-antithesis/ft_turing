module Args where

import Shared qualified

parseArgs :: [String] -> Either String (String, String)
parseArgs [x, y] = Right (x, y)
parseArgs [arg] = singleArg arg
  where
    singleArg a
      | a `elem` ["--help", "-h"] = Left Shared.helpMessage
      | otherwise = Left Shared.showUsage
parseArgs _ = Left Shared.showUsage
