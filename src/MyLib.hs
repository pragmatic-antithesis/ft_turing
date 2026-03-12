module MyLib (someFunc) where

someFunc :: String -> IO Int
someFunc arg = parseArgs arg
  where
    parseArgs a
      | a `elem` ["--help","-h"] = do
          putStrLn helpMessage
          pure 0
      | otherwise = do
          putStrLn a
          pure 1


helpMessage :: String
helpMessage = "usage: ft_turing [-h] jsonfile input\n\npositional arguments:\n  jsonfile\tjson description of the machine\n\n  input\t\tinput of the machine\n\noptional arguments:\n  -h, --help\tshow this help message and exit"
