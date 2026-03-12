module Args where

parseArgs :: [String] -> IO Int
parseArgs [arg] = singleArg arg
  where
    singleArg a
      | a `elem` ["--help","-h"] = do
          putStrLn helpMessage
          pure 0
      | otherwise = showUsage
parseArgs _ = showUsage


showUsage :: IO Int
showUsage = do
    putStrLn "usage: ft_turing [-h] jsonfile input"
    pure 1

helpMessage :: String
helpMessage = "usage: ft_turing [-h] jsonfile input\n\npositional arguments:\n  jsonfile\tjson description of the machine\n\n  input\t\tinput of the machine\n\noptional arguments:\n  -h, --help\tshow this help message and exit"
