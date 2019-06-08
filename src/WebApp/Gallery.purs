module WebApp.Gallery where

import Prelude

import WebApp.Gallery.Card (card)
import WebApp.Gallery.Frame (frame)
import WebApp.Gallery.ZoomSlider (zoomSlider)
import Data.Maybe (Maybe(..))
import Effect.Uncurried (mkEffectFn1)
import Item (Item)
import React.Basic (JSX, createComponent, make)
import React.Basic as React
import React.Basic.DOM as R
import React.Basic.DOM.Events (capture_)


type Props =
  { items :: Array Item }

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
      , R.div_ $ map (\item -> card { item
                                   , size: self.state.cellSize
                                   , onClick: capture_ $ self.setState \s -> s { showFrame = Just item }
                                   }) self.props.items
      ]

