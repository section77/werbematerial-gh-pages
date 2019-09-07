module ItemsSuite where

import Prelude

import Control.Monad.Free (Free)
import Effect.Class (liftEffect)
import Indexer.FSEntry (FSEntry(..))
import Indexer.MTime (MTime)
import Indexer.MTime as MTime
import Node.Path as Path
import Partial.Unsafe (unsafePartial)
import Test.QuickCheck (quickCheck, (===))
import Test.Unit (TestF, suite, test)



tests :: Free TestF Unit
tests = unsafePartial $ suite "Item" $ do
  test "equality with different ext" $ liftEffect $ quickCheck $ do

    let f1 = File { basename: "name.pdf", dirname: "/a", mtime, size: 0.0 }
        f2 = File { basename: "name.svg", dirname: "/a", mtime, size: 1.0 }
    f1 === f2


  test "equality with 'gh-pages-preview-'" $ liftEffect $ quickCheck $ do

    let f1 = File { basename: "name.pdf", dirname: "/a", mtime, size: 0.0 }
        f2 = File { basename: "gh-pages-preview-name.png", dirname: "/a", mtime, size: 1.0 }
    f1 === f2



mtime :: MTime
mtime = MTime.unixTime



-- genFilesInDir :: NonEmpty Array String -> Gen (Array FSEntry)
-- genFilesInDir = Gen.arrayOf <<< genFileInDir


-- genFileInDir :: NonEmpty Array String -> Gen File
-- genFileInDir dirnames = do
--   file <- arbitrary
--   dirname <- Gen.elements dirnames
--   pure $ over File _ { dirname = dirname } file


exampleListing :: FSEntry
exampleListing = mkDir "/"
       [ mkDir "bilder"
           [ mkFile "/bilder/logo.svg"
           , mkDir "2019"
             [ mkFile "/bilder/2019/event1.pdf"
             , mkFile "/bilder/2019/event1.svg"
             , mkFile "/bilder/2019/gh-pages-preview-event1.png"
             , mkFile "/bilder/2019/event2.png"
             ]
           ]
       , mkFile "/event1.pdf"
       ]

  where mkDir name content = let basename = Path.basename name
                                 dirname = Path.dirname name
                             in Dir { basename, dirname, content }
        mkFile name = let basename = Path.basename name
                          dirname = Path.dirname name
                      in File { basename, dirname, mtime, size: 0.0 }

