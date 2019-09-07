module Indexer.FSEntry where

import Prelude

import Data.Generic.Rep (class Generic)
import Data.Generic.Rep.Show (genericShow)
import Data.Maybe (fromMaybe)
import Data.String as S
import Data.Tuple (Tuple(..))
import Foreign (ForeignError(..), fail)
import Foreign.Class (class Decode, class Encode, decode, encode)
import Foreign.Index ((!))
import Foreign.Object as FO
import Indexer.MTime (MTime)
import Node.Path as Path
import Partial.Unsafe (unsafePartial)


type FileRec = { basename :: String, dirname :: String, mtime :: MTime, size :: Number }

data FSEntry =
    Dir { basename :: String, dirname :: String, content :: Array FSEntry }
  | File FileRec


unwrapFile :: Partial => FSEntry -> FileRec
unwrapFile (File fileRec) = fileRec

label :: Partial => FSEntry -> String
label (File{ basename }) = cleanup basename
  where
    cleanup = dropExt >>> dropPreviewPrefix
    dropExt n = Path.basenameWithoutExt n (Path.extname n)
    dropPreviewPrefix n = fromMaybe n $ S.stripPrefix (S.Pattern "gh-pages-preview-") n


derive instance genericFSEntry :: Generic FSEntry _
instance showFSEntry :: Show FSEntry where show x = genericShow x

instance ordFSEntry :: Ord FSEntry where
  compare f1 f2 = compare (toCompare f1) (toCompare f2)
    where toCompare file@(File{ dirname }) = unsafePartial $ Path.concat [ dirname, label file ]
          toCompare (Dir{ basename, dirname }) = Path.concat [ dirname, basename ]

instance eqFSEntry :: Eq FSEntry where

  eq f1@(File{dirname: dirname1}) f2@(File{dirname: dirname2}) =
    dirname1 == dirname2 &&
    (unsafePartial $ label f1 == label f2)

  eq (Dir d1) (Dir d2) = d1 == d2
  eq _ _ = false


instance encodeFile :: Encode FSEntry where
  encode (Dir dir) =
    encode $ FO.fromFoldable
    [ Tuple "type"     $ encode "dir"
    , Tuple "basename" $ encode dir.basename
    , Tuple "dirname"  $ encode dir.dirname
    , Tuple "content"  $ encode dir.content
    ]

  encode (File file) =
    encode $ FO.fromFoldable
    [ Tuple "type"     $ encode "file"
    , Tuple "basename" $ encode file.basename
    , Tuple "dirname"  $ encode file.dirname
    , Tuple "mtime"    $ encode file.mtime
    , Tuple "size"     $ encode file.size
    ]

instance decodeFile :: Decode FSEntry where
  decode  v = do
    t <- v ! "type" >>= decode
    basename <- v ! "basename" >>= decode
    dirname <- v ! "dirname" >>= decode
    case t of
      "dir" -> do
        content <- v ! "content" >>= decode
        pure $ Dir { basename, dirname, content }

      "file" -> do
        mtime <- v ! "mtime" >>= decode
        size <- v ! "size" >>= decode
        pure $ File { basename, dirname, mtime, size }

      _ -> fail (ForeignError $ "invalid type: " <> t)

