module ItemsSuite where

import Prelude

import Control.Monad.Free (Free)
import Data.Array.Partial as AP
import Data.Newtype (over, unwrap)
import Data.NonEmpty (NonEmpty, (:|))
import Data.Set as S
import Effect.Class (liftEffect)
import Indexer.File (File(..))
import Items as Items
import Partial.Unsafe (unsafePartial)
import Test.QuickCheck (arbitrary, quickCheckGen, (===))
import Test.QuickCheck.Gen (Gen)
import Test.QuickCheck.Gen as Gen
import Test.Unit (TestF, suite, test)



tests :: Free TestF Unit
tests = unsafePartial $ suite "Item" $ do
  test "groupByDirname" $ do

    let dirnames = "/a" :| ["/ab", "/c"]
    liftEffect $ quickCheckGen $ (\files ->  do

        let expected = S.fromFoldable $ map (unwrap >>> _.dirname) files
            groups = Items.groupFilesByDirname files
            actual = S.fromFoldable $ map (AP.head >>> unwrap >>> _.dirname) groups

        expected === actual) <$> genFilesInDir dirnames



genFilesInDir :: NonEmpty Array String -> Gen (Array File)
genFilesInDir = Gen.arrayOf <<< genFileInDir


genFileInDir :: NonEmpty Array String -> Gen File
genFileInDir dirnames = do
  file <- arbitrary
  dirname <- Gen.elements dirnames
  pure $ over File _ { dirname = dirname } file
