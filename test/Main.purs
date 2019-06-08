module Test.Main where

import Data.Unit (Unit)
import Effect (Effect)
import ItemFactorySuite as ItemFactorySuite
import Test.Unit.Main (runTest)

main :: Effect Unit
main = runTest do
  ItemFactorySuite.tests
