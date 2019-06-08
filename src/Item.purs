module Item where

import Prelude

import Data.Array as A
import Data.Foldable (minimum)
import Data.Generic.Rep (class Generic)
import Data.Generic.Rep.Show (genericShow)
import Data.Maybe (Maybe, fromJust)
import Data.Newtype (class Newtype, unwrap)
import Foreign.Class (class Decode, class Encode)
import Foreign.Generic (defaultOptions, genericDecode, genericEncode)
import Indexer.File (File)
import Indexer.File as File
import Indexer.MTime (MTime)
import Node.Path (FilePath)
import Node.Path as Path
import Partial.Unsafe (unsafePartial)
import Test.QuickCheck (class Arbitrary)
import Test.QuickCheck.Arbitrary (genericArbitrary)

type Name = String
type Dirname = String

newtype Item = Item
  { name         :: Name
  , dirname      :: Dirname
  , files        :: Array File
  , previewImage :: Maybe File
  }


updated :: Item -> MTime
updated (Item item) = unsafePartial $ fromJust <<< minimum <<< map (unwrap >>> _.mtime) $ item.files


images :: Item -> Array File
images (Item item) = A.filter (unwrap >>> _.name >>> isImage) item.files
  where
    isImage name = A.elem (Path.extname name) [".png", ".jpeg", ".jpg", ".bmp"]


lookupImage :: Item -> Maybe File
lookupImage = A.last <<< sortBySize <<< images
  where
    sortBySize = A.sortWith (unwrap >>> _.size)

previewImagePath :: Item -> Maybe FilePath
previewImagePath (Item item) = File.path <$> item.previewImage


derive instance genericItem :: Generic Item _
derive instance eqItem :: Eq Item
derive instance newtypeItem :: Newtype Item _
instance showItem :: Show Item where show = genericShow

instance encodeItem :: Encode Item where
  encode = genericEncode $ defaultOptions { unwrapSingleConstructors = true }

instance decodeItem :: Decode Item where
  decode = genericDecode $ defaultOptions { unwrapSingleConstructors = true }

instance arbitraryItem :: Arbitrary Item where arbitrary = genericArbitrary
