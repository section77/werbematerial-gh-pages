module ItemFactory where

import Prelude

import Data.Array as A
import Data.Array.Partial as AP
import Data.Map as M
import Data.Maybe (Maybe(..))
import Data.Newtype (unwrap)
import Data.String (Pattern(..))
import Data.String as String
import Data.Tuple (Tuple(..))
import Indexer.Dir (Dir)
import Indexer.Dir as Dir
import Indexer.File (File(..))
import Indexer.File as File
import Item (Item(..))
import Node.Path (FilePath)
import Partial.Unsafe (unsafePartial)


fromDir :: Dir -> Array Item
fromDir dir = map mkItem <<< groupFiles <<< ignorePreviewImages $ Dir.filterFiles dir
  where
    mkItem :: Array File -> Item
    mkItem files =  let file = unsafePartial $ AP.head $ files
                        name = File.basenameWithoutExt file
                    in Item
                       { name
                       , dirname: (unwrap >>> _.dirname) file
                       , previewImage: lookupPreviewImage name
                       , files
                       }

    ignorePreviewImages = A.filter (not <<< hasPrefix (Pattern "gh-pages-preview-") <<< _.name <<< unwrap)
    lookupPreviewImage name = Dir.findFileBy dir (unwrap >>> _.name >>> hasPrefix (Pattern $ "gh-pages-preview-" <> name))
    hasPrefix p s = String.indexOf p s == Just 0


groupFiles :: Array File -> Array (Array File)
groupFiles = A.concat <<< map (groupByBasenameWithoutExt) <<< groupByDirname


groupByDirname :: Array File -> Array (Array File)
groupByDirname = A.fromFoldable <<< M.fromFoldableWith A.union <<< map pairDirnameWithFile
  where
    pairDirnameWithFile :: File -> Tuple FilePath (Array File)
    pairDirnameWithFile file@(File {dirname}) = Tuple dirname [file]


groupByBasenameWithoutExt :: Array File -> Array (Array File)
groupByBasenameWithoutExt = A.fromFoldable <<< M.fromFoldableWith A.union <<< map pairBasenameWithFile
  where
    pairBasenameWithFile :: File -> Tuple String (Array File)
    pairBasenameWithFile file = let basename = File.basenameWithoutExt file
                                in Tuple basename [file]

