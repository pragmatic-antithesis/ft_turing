module Shared where

import System.Exit
import System.IO (hPutStrLn, stderr)

exit :: String -> IO ()
exit msg = do
  if msg == helpMessage
    then do
      putStrLn msg
      exitSuccess
    else do
      hPutStrLn stderr msg
      exitWith (ExitFailure 1)

showUsage :: String
showUsage = "usage: ft_turing [-h] jsonfile input"

helpMessage :: String
helpMessage = "usage: ft_turing [-h] jsonfile input\n\npositional arguments:\n  jsonfile\tjson description of the machine\n\n  input\t\tinput of the machine\n\noptional arguments:\n  -h, --help\tshow this help message and exit"
