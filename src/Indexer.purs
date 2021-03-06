module Indexer where

import Prelude

import Data.Traversable (traverse)
import Effect (Effect)
import Effect.Console (log)
import Foreign.Generic (encodeJSON)
import Indexer.FSEntry (FSEntry(..))
import Indexer.MTime (MTime(..))
import Items as Items
import Node.Encoding as Encoding
import Node.FS.Stats (Stats(..), isFile, modifiedTime)
import Node.FS.Sync as FS
import Node.Path (FilePath)
import Node.Path as Path
import Node.Process (argv)


main :: Effect Unit
main = do
  args <- argv
  case args of
    [_, _, srcDir, outDir ] -> do
      dir <- ls srcDir
      writeDirListingFile (Path.concat [outDir, "dir-listing.json"]) dir
      writeItemsFile (Path.concat [outDir, "items.json"]) dir
    _ -> log "usage: indexer.js <src directory> <out directory>"


writeDirListingFile :: FilePath -> FSEntry -> Effect Unit
writeDirListingFile fp dir = do
  log $ "write directory listing to: " <> fp
  FS.writeTextFile Encoding.UTF8 fp $ encodeJSON dir


writeItemsFile :: FilePath -> FSEntry -> Effect Unit
writeItemsFile fp dir = do
  log $ "write items listing to: " <> fp
  FS.writeTextFile Encoding.UTF8 fp $ encodeJSON $ Items.fromFSEntry dir


ls :: FilePath -> Effect FSEntry
ls path = walk path ""
  where
    walk absPath relPath = FS.readdir absPath >>= mkDir

      where
        mkDir = map (\c -> Dir {basename: Path.basename relPath, dirname: Path.dirname relPath, content: c }) <<< traverse mkFSEntry

        mkFSEntry :: String -> Effect FSEntry
        mkFSEntry basename = do
          stats <- FS.stat $ Path.concat [absPath, basename]
          if (isFile stats) then
            let mtime = MTime $ modifiedTime stats
                Stats { size } = stats
            in pure $ File { basename, dirname: relPath, mtime, size}
            else walk (Path.concat [absPath, basename]) (Path.concat [relPath, basename])
