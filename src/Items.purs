module Items where

import Prelude

import Data.Array as A
import Data.Array.Partial as AP
import Data.Generic.Rep (class Generic)
import Data.Generic.Rep.Show (genericShow)
import Data.Map (Map)
import Data.Map as M
import Data.Maybe (Maybe(..))
import Data.Newtype (class Newtype, unwrap)
import Data.String (Pattern(..))
import Data.String as String
import Data.Tuple (Tuple(..))
import Foreign.Class (class Decode, class Encode, decode, encode)
import Foreign.Object as FO
import Indexer.Dir (Dir)
import Indexer.Dir as Dir
import Indexer.File (File(..))
import Indexer.File as File
import Item (Item(..))
import Node.Path (FilePath)
import Partial.Unsafe (unsafePartial)


newtype Items = Items (Map FilePath (Array Item))


fromDir :: Dir -> Items
fromDir dir = Items <<< map (map mkItem) <<< groupFiles <<< ignorePreviewImages $ Dir.filterFiles dir
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
    lookupPreviewImage name = Dir.findFileBy dir (unwrap >>> _.name >>> hasPrefix (Pattern $ "gh-pages-preview-" <> name <> "."))
    hasPrefix p s = String.indexOf p s == Just 0


groupFiles :: Array File -> Map FilePath (Array (Array (File)))
groupFiles = map (groupFilesByBasenameWithoutExt) <<< groupFilesByDirname


groupFilesByDirname :: Array File -> Map FilePath (Array File)
groupFilesByDirname = M.fromFoldableWith A.union <<< map pairDirnameWithFile
  where
    pairDirnameWithFile :: File -> Tuple FilePath (Array File)
    pairDirnameWithFile file@(File {dirname}) = Tuple dirname [file]


groupFilesByBasenameWithoutExt :: Array File -> Array (Array File)
groupFilesByBasenameWithoutExt = A.fromFoldable <<< M.fromFoldableWith A.union <<< map pairBasenameWithFile
  where
    pairBasenameWithFile :: File -> Tuple String (Array File)
    pairBasenameWithFile file = let basename = File.basenameWithoutExt file
                                in Tuple basename [file]



derive instance genericItems :: Generic Items _
derive instance eqItems :: Eq Items
derive instance newtypeItems :: Newtype Items _
instance showItems :: Show Items where show = genericShow

instance encodeItems :: Encode Items where
  encode (Items items) =   encode
                         $ FO.fromFoldable
                         $ toArray items
    where
      toArray :: forall k v. Ord k => Map k v -> Array (Tuple k v)
      toArray = M.toUnfoldable


instance decodeItems :: Decode Items where
  decode = map (Items <<< fromArray <<< FO.toUnfoldable) <<< decode
    where
      fromArray :: forall k v. Ord k => Array (Tuple k v) -> Map k v
      fromArray = M.fromFoldable
