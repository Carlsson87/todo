module Main where

import Control.Applicative (liftA2)
import Data.List (foldl, partition, splitAt, uncons)
import Paths_todo (getDataFileName)
import System.Directory (getHomeDirectory)
import System.Environment (getArgs)
import System.IO (appendFile, readFile)
import Text.Read (readMaybe)

helpInfo :: String
helpInfo =
    let fmt (cmd, desc) = cmd ++ "\t" ++ desc ++ "\n"
    in foldl (++) "" $
       fmap
           fmt
           [ ("add", "Add an item")
           , ("check", "Mark an item as completed")
           , ("purge", "Remove all completed items")
           , ("clear", "Remove all items")
           , ("help", "You're looking at it")
           ]

-- Types
type DoneItem = String

type TodoItem = (Int, String)

type Items = ([TodoItem], [DoneItem])

data Action
    = PrintHelp
    | PrintItems
    | AddItem String
    | CheckItem Int
    | Clear
    | Purge

-- Main
main :: IO ()
main = fmap getAction getArgs >>= performAction

-- Effects
todoPath :: IO String
todoPath = getDataFileName "data.txt"

getItems :: IO Items
getItems = do
    path <- todoPath
    contents <- readFile path
    seq (length contents) (return $ fileToItems contents)

saveItems :: Items -> IO ()
saveItems items =
    let todo = unlines $ fmap snd $ fst items
        did = unlines $ snd items
    in liftA2 writeFile todoPath (return (todo ++ "---\n" ++ did)) >>= id

performAction :: Action -> IO ()
performAction action =
    case action of
        AddItem item -> addItemToList item >> printItems
        PrintItems -> printItems
        PrintHelp -> putStrLn helpInfo
        CheckItem index ->
            fmap (checkItem index) getItems >>= saveItems >> printItems
        Clear -> saveItems ([], []) >> printItems
        Purge ->
            fmap (\(todo, done) -> (todo, [])) getItems >>= saveItems >>
            printItems

addItemToList :: String -> IO ()
addItemToList str = do
    items <- getItems
    saveItems $ addItem str items

printItems :: IO ()
printItems = fmap formatItems getItems >>= putStrLn

-- Functions
getAction :: [String] -> Action
getAction args =
    case args of
        ("add":str:_) -> AddItem str
        ("show":_) -> PrintItems
        ("check":i:_) ->
            case readMaybe i :: Maybe Int of
                Just index -> CheckItem index
                Nothing -> PrintHelp
        ("clear":_) -> Clear
        ("purge":_) -> Purge
        [] -> PrintItems
        _ -> PrintHelp

fileToItems :: String -> Items
fileToItems file =
    let items = lines file
    in ( zip [1 ..] $ takeWhile ((/=) "---") items
       , drop 1 $ dropWhile ((/=) "---") items)

isItemNotDone :: (Int, String) -> Bool
isItemNotDone (_, str) = "X" /= take 1 str

formatItem :: (Int, String) -> String
formatItem (i, str) = show i ++ ". " ++ str

formatDoneItem :: DoneItem -> String
formatDoneItem str = str

formatItems :: Items -> String
formatItems (notDone, done) =
    "TODO:\n\n" ++
    unlines (fmap formatItem notDone) ++
    "\nDONE:\n\n" ++ unlines (fmap formatDoneItem done)

checkItem :: Int -> Items -> Items
checkItem index (todo, did) =
    let (before, after) = splitAt (index - 1) todo
        parts = uncons after
    in case parts of
           Just (head, tail) -> (before ++ tail, snd head : did)
           Nothing -> (todo, did)

addItem :: String -> Items -> Items
addItem str (todo, done) = ((0, str) : todo, done)
