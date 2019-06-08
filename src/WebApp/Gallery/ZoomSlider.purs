module WebApp.Gallery.ZoomSlider where

import Prelude

import Data.Int (fromString, round, toNumber)
import Data.Maybe (fromMaybe)
import Effect.Uncurried (EffectFn1, runEffectFn1)
import React.Basic (JSX, createComponent, makeStateless)
import React.Basic.DOM as R
import React.Basic.DOM.Events (targetValue)
import React.Basic.Events (handler)

type Props =
  { min :: Int
  , max :: Int
  , value :: Int
  , onChange :: EffectFn1 Int Unit
  }

zoomSlider :: Props -> JSX
zoomSlider = makeStateless (createComponent "ZoomSlider") render

  where

    render :: Props -> JSX
    render props =
      R.div
      { style: R.css { width: "100%" }
      , children:
        [ R.text <<< show <<< round $ (100.0 / toNumber (props.max - props.min) * toNumber (props.value - props.min))
        , R.text "%"
        , R.input
           { type: "range"
           , value: show props.value
           , min: toNumber props.min
           , max: toNumber props.max
           , onChange: handler targetValue \value ->
               let value' = fromMaybe 0 $ fromString =<< value
               in runEffectFn1 props.onChange value'
           }
        ]
      }

