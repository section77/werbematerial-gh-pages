module WebApp.Gallery.Frame where

import Item

import Data.Maybe (Maybe(..), maybe)
import Data.Newtype (unwrap)
import Indexer.File as File
import Item as Item
import Prelude (mempty)
import React.Basic (JSX, createComponent, makeStateless)
import React.Basic.DOM as R
import React.Basic.Events (EventHandler)



type Props =
  { showFrame :: Maybe Item
  , onClick :: EventHandler
  }

frame :: Props -> JSX
frame = makeStateless (createComponent "Frame") render

  where

    render :: Props -> JSX
    render props = R.div_ [ maybe mempty (mkModal props.onClick) props.showFrame ]

    mkModal onClick item = R.div
      { children: [ content (unwrap item).name (Item.lookupImage item) ]
      , style: R.css
        { position: "fixed"
        , top: "0"
        , left: "0"
        , width: "100%"
        , height: "100%"
        , backgroundColor: "rgba(0,0,0,0.4)"
        , zIndex: "1000"
        }
      , onClick
      }


    content name Nothing = R.h1 { style: R.css { marginTop: "10%"
                                               , textAlign: "center"
                                               , textTransform: "full-width"
                                               },
                                  children: [R.text "Image missing" ] }
    content name (Just file) =
      R.div
        { children:
          [ R.div
            { children: [R.text name]
            , style: R.css { textAlign: "center", fontSize: "larger" }
            }
          , R.img
            { src: File.path file
            , style: R.css
              { width: "100%"
              , height: "100%"
              , backgroundColor: "white"
              }
            }
          ]
        , style: R.css
          { position: "fixed"
          , top: "50%"
          , left: "50%"
          , transform: "translate(-50%, -50%)"
          , width: "600px"
          , maxWidth: "100%"
          , height: "auto"
          , maxHeight: "100%"
          }
        }
