module Indexer where

import Indexer.Dir

import Data.Traversable (traverse)
import Effect (Effect)
import Effect.Console (log)
import Foreign.Generic (encodeJSON)
import Indexer.File (File(..))
import Indexer.MTime (MTime(..))
import Items as Items
import Node.Encoding as Encoding
import Node.FS.Stats (Stats(..), isFile, modifiedTime)
import Node.FS.Sync as FS
import Node.Path (FilePath)
import Node.Path as Path
import Node.Process (argv)
import Prelude (Unit, bind, discard, flip, pure, ($), (<$>), (<>), (>>=))

main :: Effect Unit
main = do
  args <- argv
  case args of
    [_, _, srcDir, outDir ] -> do
      dir <- ls srcDir
      writeDirListingFile (Path.concat [outDir, "dir-listing.json"]) dir
      writeItemsFile (Path.concat [outDir, "items.json"]) dir
    _ -> log "usage: indexer.js <src directory> <out directory>"


writeDirListingFile :: FilePath -> Dir -> Effect Unit
writeDirListingFile fp dir = do
  log $ "write directory listing to: " <> fp
  FS.writeTextFile Encoding.UTF8 fp $ encodeJSON dir


writeItemsFile :: FilePath -> Dir -> Effect Unit
writeItemsFile fp dir = do
  log $ "write items listing to: " <> fp
  FS.writeTextFile Encoding.UTF8 fp $ encodeJSON $ Items.fromDir dir


ls :: FilePath -> Effect Dir
ls = flip walk "./"
  where
    walk absPath relPath = FS.readdir absPath >>= mkDir

      where
        mkDir files = (\c -> Dir {name: Path.basename absPath, dirname: relPath, content: c }) <$> traverse mkEntry files
        mkEntry name = do
          stats <- FS.stat $ Path.concat [absPath, name]
          if (isFile stats) then
            let mtime = MTime $ modifiedTime stats
                Stats { size } = stats
            in pure $ FileEntry $ File { name, dirname: relPath, mtime, size}
            else
            DirEntry <$> walk (Path.concat [absPath, name]) (Path.concat [relPath, name])
