module Main where

import Args qualified (parseArgs)
import System.Environment
import System.Exit

main :: IO ()
main =
  do
    getArgs >>= Args.parseArgs >>= exit

exit :: Int -> IO ()
exit 0 = exitSuccess
exit n = exitWith (ExitFailure n)

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
