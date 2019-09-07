module WebApp.Gallery.ZoomSlider where

import Prelude

import Data.Int (fromString, round, toNumber)
import Data.Maybe (fromJust, fromMaybe)
import Data.Monoid (guard)
import Data.String as S
import Effect.Uncurried (EffectFn1, runEffectFn1)
import Partial.Unsafe (unsafePartial)
import React.Basic (Component, JSX, createComponent, make)
import React.Basic.DOM as R
import React.Basic.DOM.Events (targetValue)
import React.Basic.Events (handler)
import Web.DOM.Element (clientWidth)
import Web.DOM.NonElementParentNode (getElementById)
import Web.HTML (window)
import Web.HTML.HTMLDocument (toNonElementParentNode)
import Web.HTML.Window (document)

type Props =
  { min :: Int
  , max :: Int
  , value :: Int
  , onChange :: EffectFn1 Int Unit
  }

component :: Component Props
component = createComponent "ZoomSlider"


zoomSlider :: Props -> JSX
zoomSlider = make component { initialState, didMount, didUpdate, render }

  where

    initialState = { thumb: { left: 45.0, text: "0" } }

    didMount self = do
      thumb <- xxx self
      self.setState _ { thumb = thumb }

    didUpdate self prev = do
      thumb <- xxx self
      guard (self.state.thumb.left /= thumb.left) $ self.setState _ { thumb = thumb }



    render self =
      R.span
        { className: "col s4 m3 right input-field"
        , style: R.css { height: "30px" }
        , children:
          [ R.i { className: "material-icons prefix", children: [R.text "zoom_in" ] }
          , R.span
             { style: R.css { position: "relative", left: self.state.thumb.left, fontSize: "smaller" }
             , children: [R.text $ self.state.thumb.text <> "%" ]
             }
          , R.input
             { id: "slider"
             , type: "range"
             , style: R.css {top: "-15px"}
             , value: show self.props.value
             , min: show self.props.min
             , max: show self.props.max
             , onChange: handler targetValue \value ->
               let value' = fromMaybe 0 $ fromString =<< value
               in runEffectFn1 self.props.onChange value'
             }
          ]
        }



    -- FIXME: cleanup
    xxx self = do
      slider <- getElementById "slider" =<< (map toNonElementParentNode $ document =<< window)
      let slider' = unsafePartial $ fromJust slider
      width <- clientWidth slider'

      let max = toNumber self.props.max
          min = toNumber self.props.min
          value = toNumber self.props.value
          p = (value - min) / (max - min)
          text = show <<< round $ p * 100.0
          left = (p * (width - toNumber (S.length text * 10))) + 45.0

      pure { text, left }
