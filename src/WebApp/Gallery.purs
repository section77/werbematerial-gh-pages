module WebApp.Gallery where

import Prelude

import Data.Map as M
import Data.Maybe (Maybe(..))
import Data.Newtype (unwrap)
import Data.Tuple (Tuple(..))
import Effect.Uncurried (mkEffectFn1)
import Item (Item)
import Items (Items)
import React.Basic (JSX, createComponent, make)
import React.Basic as React
import React.Basic.DOM as R
import React.Basic.DOM.Events (capture_)
import WebApp.Gallery.Card (card)
import WebApp.Gallery.Frame (frame)
import WebApp.Gallery.ZoomSlider (zoomSlider)


type Props =
  { items :: Items }

type State =
  { cellSize :: Int
  , showFrame :: Maybe Item
  }

type Self = React.Self Props State

gallery :: Props -> JSX
gallery = make (createComponent "Gallery") { initialState, render }
  where

    initialState :: State
    initialState = { cellSize: 200, showFrame: Nothing }

    render :: Self -> JSX
    render self =
      R.div_
      [ zoomSlider { value: self.state.cellSize, min: 200, max: 500
                   , onChange: mkEffectFn1 (\v -> self.setState _ { cellSize = v }) }
      , frame { showFrame: self.state.showFrame
              , onClick: capture_ $ self.setState \s -> s { showFrame = Nothing }
              }
      , renderItems self self.props.items
      ]



renderItems :: Self -> Items -> JSX
renderItems self = R.div_ <<< map render <<< M.toUnfoldable <<< unwrap
  where
    render (Tuple dirname items) =
      R.div
      { style: R.css { display: "flow-root", borderTop: "1px solid black", marginTop: "20px" }
      , children: [
           R.div
           { style: R.css { fontSize: "x-large", textTransform: "capitalize" }
           , children: [R.text dirname]
           }
           , R.div_ $ map (\item ->
                            card { item
                                 , size: self.state.cellSize
                                 , onClick: capture_ $ self.setState \s -> s { showFrame = Just item }
                                 }) items
           ]
      }

