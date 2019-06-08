module Indexer.File where


import Prelude

import Data.Generic.Rep (class Generic)
import Data.Generic.Rep.Show (genericShow)
import Data.Maybe (fromMaybe)
import Data.Newtype (class Newtype)
import Data.String (Pattern(..), stripSuffix)
import Data.Tuple (Tuple(..))
import Foreign.Class (class Decode, class Encode, decode, encode)
import Foreign.Index ((!))
import Foreign.Object as FO
import Indexer.MTime (MTime)
import Node.Path (FilePath)
import Node.Path as Path
import Test.QuickCheck (class Arbitrary)
import Test.QuickCheck.Arbitrary (genericArbitrary)

newtype File =
  File
  { name    :: String
  , dirname :: String
  , mtime   :: MTime
  , size    :: Number
  }

path :: File -> FilePath
path (File file) = file.dirname <> "/" <> file.name

extension :: File -> String
extension (File file) = Path.extname file.name

basenameWithoutExt :: File -> String
basenameWithoutExt (File { name }) =
  let basename = Path.basename name
  in fromMaybe basename $ stripSuffix (Pattern $ Path.extname basename) basename




derive instance genericFile :: Generic File _
derive instance newtypeFile :: Newtype File _
derive instance eqFile :: Eq File

instance showFile :: Show File where show = genericShow
instance arbitraryFile :: Arbitrary File where arbitrary = genericArbitrary

instance encodeFile :: Encode File where
  encode (File file) =
    encode $ FO.fromFoldable
    [ Tuple "name"     $ encode file.name
    , Tuple "dirname"  $ encode file.dirname
    , Tuple "mtime"    $ encode file.mtime
    , Tuple "size"     $ encode file.size
    ]

instance decodeFile :: Decode File where
  decode  v = do
    name    <- v ! "name" >>= decode
    dirname <- v ! "dirname" >>= decode
    mtime   <- v ! "mtime" >>= decode
    size    <- v ! "size" >>= decode
    pure $ File { name, dirname, mtime, size }
