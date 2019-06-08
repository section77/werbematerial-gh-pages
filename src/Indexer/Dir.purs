module Indexer.Dir where

import Prelude

import Data.Array as A
import Data.Generic.Rep (class Generic)
import Data.Generic.Rep.Show (genericShow)
import Data.Maybe (Maybe)
import Data.Newtype (class Newtype, unwrap)
import Data.Tuple (Tuple(..))
import Foreign (ForeignError(..), fail)
import Foreign.Class (class Decode, class Encode, decode, encode)
import Foreign.Index ((!))
import Foreign.Object as FO
import Indexer.File (File)


newtype Dir =
  Dir
  { name    :: String
  , dirname :: String
  , content :: Array DirEntry
  }


filterFiles :: Dir -> Array File
filterFiles (Dir { name, content }) = A.concat $ (flip map) content $ case _ of
  (DirEntry dir') -> filterFiles dir'
  (FileEntry file) -> [file]

findFileBy :: Dir -> (File -> Boolean) -> Maybe File
findFileBy dir pred = A.find pred $ filterFiles dir

derive instance genericDir :: Generic Dir _
derive instance newtypeDir :: Newtype Dir _
derive instance eqDir :: Eq Dir
instance showDir :: Show Dir where show = genericShow

instance encodeDir :: Encode Dir where
  encode (Dir dir) =
    encode $ FO.fromFoldable
    [ Tuple "type"    $ encode "dir"
    , Tuple "name"    $ encode dir.name
    , Tuple "dirname" $ encode dir.dirname
    , Tuple "content" $ encode dir.content
    ]

instance decodeDir :: Decode Dir where
   decode v = do
     name <- v ! "name" >>= decode
     dirname <- v ! "dirname" >>= decode
     content <- v ! "content" >>= decode
     pure $ Dir { name, dirname, content }



data DirEntry = FileEntry File | DirEntry Dir

derive instance genericDirEntry :: Generic DirEntry _
derive instance eqDirEntry :: Eq DirEntry
instance showDirEntry :: Show DirEntry where show x = genericShow x

instance encodeDirEntry :: Encode DirEntry where
  encode (DirEntry dir) = encode $ FO.fromFoldable
                              [ Tuple "type"  $ encode "dir"
                              , Tuple "entry" $ encode dir
                              ]
  encode (FileEntry file) = encode $ FO.fromFoldable
                              [ Tuple "type"  $ encode "file"
                              , Tuple "entry" $ encode file
                              ]

instance decodeDirEntry :: Decode DirEntry where
  decode v = do
    t <- v ! "type" >>= decode
    entry <- v ! "entry"
    case t of
      "dir"  -> DirEntry <$> decode entry
      "file" -> FileEntry <$> decode entry
      _      -> fail (ForeignError "invalid entry")

