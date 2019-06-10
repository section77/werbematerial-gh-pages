module Test.Main where

import Data.Unit (Unit)
import Effect (Effect)
import ItemsSuite as ItemsSuite
import Test.Unit.Main (runTest)

main :: Effect Unit
main = runTest do
  ItemsSuite.tests
