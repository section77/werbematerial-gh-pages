module WebApp.App where

import Prelude

import Items (Items)
import React.Basic (JSX, makeStateless, createComponent)
import React.Basic.DOM as R
import WebApp.Gallery (gallery)

app :: Items -> JSX
app items = unit # makeStateless (createComponent "App") \_ ->
  R.div_
  [ gallery { items } ]


