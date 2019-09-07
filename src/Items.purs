module Items where

import Prelude

import Data.Array as A
import Data.Array.NonEmpty (NonEmptyArray)
import Data.Array.NonEmpty as ANE
import Data.Generic.Rep (class Generic)
import Data.Generic.Rep.Show (genericShow)
import Data.Maybe (Maybe(..), fromJust)
import Data.String as S
import Data.String.Regex (test) as SR
import Data.String.Regex.Flags (noFlags) as SR
import Data.String.Regex.Unsafe (unsafeRegex) as SR
import Data.Traversable (traverse)
import Data.Tuple (Tuple(..))
import Foreign (F, Foreign, ForeignError(..), fail)
import Foreign.Class (class Decode, class Encode, decode, encode)
import Foreign.Index ((!))
import Foreign.Object as FO
import Indexer.FSEntry (FSEntry(..), FileRec, unwrapFile)
import Indexer.FSEntry as FSEntry
import Node.Path as Path
import Partial.Unsafe (unsafePartial)


data Items =
    Category { label :: String, path :: String, items :: Array Items }
  | Item { label :: String, previewImage :: Maybe FileRec, files :: NonEmptyArray FileRec }


fromFSEntry :: FSEntry -> Items
fromFSEntry entry = unsafePartial $ go entry
  where
    go :: Partial => FSEntry -> Items
    go (Dir{basename, dirname, content}) = let path = Path.concat [ dirname, basename ]
                                               {yes: dirs, no: files } = A.partition isDir content
                                               categories = map go dirs
                                               items = map mkItem $ A.group' files
                                           in Category { label: basename, path, items: A.concat [categories, items]}

    mkItem :: Partial => NonEmptyArray FSEntry -> Items
    mkItem files = let label = unsafePartial $ FSEntry.label $ ANE.head files
                       previewImage = unwrapFile <$> A.find isPreviewImage files
                       files' = unwrapFile <$> ANE.filter (not <<< isPreviewImage) files
                   in Item { label, previewImage, files: fromJust $ ANE.fromArray files' }

    isDir :: FSEntry -> Boolean
    isDir (Dir _) = true
    isDir (File _) = false

    isPreviewImage (File{ basename }) = SR.test (SR.unsafeRegex "^gh-pages-preview-" SR.noFlags) basename
    isPreviewImage _                  = false



derive instance genericItems :: Generic Items _
instance showItems :: Show Items where show x = genericShow x


instance encodeItems :: Encode Items where
  encode (Category{ label, path, items }) =
    encode $ FO.fromFoldable
    [ Tuple "type"   $ encode "category"
    , Tuple "label"   $ encode label
    , Tuple "path" $ encode path
    , Tuple "items"   $ encode items
    ]

  encode (Item{ label, previewImage, files }) =
    encode $ FO.fromFoldable
    [ Tuple "type"         $ encode "item"
    , Tuple "label"        $ encode label
    , Tuple "previewImage" $ encode $ map encodeFileRec previewImage
    , Tuple "files"        $ encode $ map encodeFileRec $ ANE.toArray files
    ]
    where encodeFileRec { basename, dirname, mtime, size } =
            encode $ FO.fromFoldable
            [ Tuple "basename" $ encode basename
            , Tuple "dirname"  $ encode dirname
            , Tuple "mtime"    $ encode mtime
            , Tuple "size"     $ encode size
            ]


instance decodeItems :: Decode Items where
  decode v = do
    t <- v ! "type" >>= decode
    label <- v ! "label" >>= decode
    case t of
      "category" -> do
        path <- v ! "path" >>= decode
        items <- v ! "items" >>= decode
        pure $ Category { label, path, items }

      "item"     -> do
        may <- (v ! "previewImage" >>= decode) :: F (Maybe Foreign)
        previewImage <- case may of
          Nothing -> pure Nothing
          Just w -> Just <$> decodeFileRec w
        arr <- (v ! "files" >>= decode) :: F (Array Foreign)
        files <- (unsafePartial $ fromJust <<< ANE.fromArray) <$> traverse decodeFileRec arr
        pure $ Item { label, previewImage, files }

      _ -> fail (ForeignError $ "invalid type: " <> t)

      where
        decodeFileRec :: Foreign -> F FileRec
        decodeFileRec w = do
          basename <- w ! "basename" >>= decode
          dirname <- w ! "dirname" >>= decode
          mtime <- w ! "mtime" >>= decode
          size <- w ! "size" >>= decode
          pure $ ({ basename, dirname, mtime, size } :: FileRec)
