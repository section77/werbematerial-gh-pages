module WebApp.App where

import Prelude

import WebApp.Gallery (gallery)
import React.Basic (JSX, makeStateless, createComponent)
import React.Basic.DOM as R

import Item (Item)

app :: Array Item -> JSX
app items = unit # makeStateless (createComponent "App") \_ ->
  R.div_
  [ gallery { items } ]


