module Indexer.MTime where

import Prelude

import Control.Monad.Except (mapExcept)
import Data.DateTime (DateTime)
import Data.DateTime.Gen (genDateTime)
import Data.DateTime.Instant (fromDateTime, instant, toDateTime, unInstant)
import Data.DateTime.Instant as Instant
import Data.Either (Either(..), either)
import Data.Generic.Rep (class Generic)
import Data.Generic.Rep.Show (genericShow)
import Data.Int as Int
import Data.JSDate as JSDate
import Data.List.NonEmpty as NEL
import Data.Maybe (fromJust, maybe)
import Data.Newtype (unwrap)
import Data.Time.Duration (Milliseconds(..))
import Foreign (ForeignError(..), readNumber, tagOf)
import Foreign.Class (class Decode, class Encode, encode)
import Partial.Unsafe (unsafePartial)
import Test.QuickCheck (class Arbitrary)

-- | Represents a modification time of a file
newtype MTime = MTime DateTime

unixTime :: MTime
unixTime =  MTime $ unsafeFromJust dateTime
  where dateTime = jsdate >>= JSDate.toDateTime
        jsdate = JSDate.fromInstant <$> (Instant.instant $ Milliseconds (Int.toNumber 0))
        unsafeFromJust x = unsafePartial $ fromJust x

derive instance genericMTime :: Generic MTime _
instance showMTime :: Show MTime where show = genericShow
derive instance eqMTime :: Eq MTime
derive instance ordMTime :: Ord MTime

instance encodeMTime :: Encode MTime where
  encode (MTime v) = encodeDateTime v
    where
      encodeDateTime = encode <<< unwrap <<< unInstant <<< fromDateTime

instance decodeMTime :: Decode MTime where
  decode = map MTime <<< decodeDateTime
    where decodeDateTime value = mapExcept (either (const error) fromNumber) (readNumber value)
            where error = Left $ NEL.singleton $ TypeMismatch "DateTime" (tagOf value)
                  fromNumber = maybe error pure <<< map toDateTime <<< instant <<< Milliseconds

instance arbitraryMTime :: Arbitrary MTime where arbitrary = MTime <$> genDateTime
