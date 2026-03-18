module Main where

import Args qualified (parseArgs)
import Shared qualified
import System.Environment

main :: IO ()
main =
  do
    args <- getArgs
    case Args.parseArgs args of
      Left message -> Shared.exit message
      Right (x, y) -> putStrLn ("1st: " ++ x ++ "\n2nd: " ++ y)

-- https://blog.thomasheartman.com/posts/haskells-maybe-and-either-types
-- https://softwarepatternslexicon.com/haskell/functional-design-patterns/advanced-error-handling-with-either-and-exceptt/

-- type App a = ExceptT ExitCode IO a
-- main = getArgs
--        & liftIO            -- lift IO [String] into App
--        >>= parseArgs
--        >>= openFile
--        >>= parseFile
--        >>= runAnalysis
--        & runExceptT
--        >>= either exitWith (const exitSuccess)
