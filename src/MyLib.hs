module MyLib (someFunc) where

someFunc :: String -> IO Int
someFunc arg = do
  putStrLn arg
  return 0
