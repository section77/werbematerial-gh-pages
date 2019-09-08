module WebApp.Gallery.Modal where

import Prelude

import Data.Array as A
import Data.Array.NonEmpty (NonEmptyArray)
import Data.Array.NonEmpty as ANE
import Data.Maybe (Maybe(..), maybe)
import Data.Monoid (guard)
import Indexer.FSEntry (FileRec)
import Node.Path as P
import Node.Path as Path
import React.Basic (JSX, createComponent, make)
import React.Basic.DOM as R
import React.Basic.DOM.Events (capture_)
import React.Basic.Events (EventHandler)
import Web.HTML (window)
import Web.HTML.Location (origin, pathname)
import Web.HTML.Window (location)
import WebApp.Gallery.Clipboard (copyToClipboard)


type Props =
  { showModal :: Maybe { label :: String, files :: NonEmptyArray FileRec }
  , onClick :: EventHandler
  }

type State =
  { copyLinkImg :: String }


modal :: Props -> JSX
modal = make (createComponent "Modal") { initialState, didUpdate, render }

  where

    initialState = { copyLinkImg: "link" }

    didUpdate self prev = do
      guard (self.props.showModal /= prev.prevProps.showModal) self.setState _ { copyLinkImg = "link" }

    render self =

      let mkModal { label, files } =
            R.div
             { style: R.css
               { position: "fixed"
               , top: "0"
               , left: "0"
               , width: "100%"
               , height: "100%"
               , backgroundColor: "rgba(0,0,0,0.4)"
               , zIndex: "1000"
               }
            , onClick: self.props.onClick
            , children: [ content self label $ lookupImage files ]
            }


      in R.div_ [ maybe mempty mkModal self.props.showModal ]



    content _ label  Nothing = R.h1 { style: R.css { marginTop: "10%"
                                                  , textAlign: "center"
                                                  , textTransform: "full-width"
                                                  },
                                     children: [R.text "Image missing" ] }
    content self label (Just file) =
        let path = P.concat [ file.dirname, file.basename ]
        in
        R.div
          { children:
            [ R.div
              { className: "brown"
              , style: R.css { textAlign: "center"
                             , fontSize: "x-large"
                             , marginBottom: "5px"
                             , textTransform: "capitalize"
                             , color: "white"
                             , fontWeight: "800"
                             }
              , children:
                [ R.text label
                , R.a
                  { className: "right"
                  , style: R.css { margin: "6px 10px auto auto", color: "white" }
                  , href: "#"
                  , title: "Copy link to clipboard"
                  , onClick: capture_ $ do
                      base <- do
                        loc <- window >>= location
                        (<>) <$> origin loc <*> pathname loc
                      void $ copyToClipboard (base <> path)
                      self.setState _ { copyLinkImg = "done" }
                  , children: [ R.i { className: "material-icons", children: [R.text self.state.copyLinkImg ] } ]
                  }
                ]
              }
            , R.img
              { src: path
              , style: R.css
                { width: "100%"
                , maxWidth: "100%"
                , maxHeight: "100%"
                , backgroundColor: "white"
                }
              }
            ]
          , style: R.css
            { position: "fixed"
            , top: "50%"
            , left: "50%"
            , transform: "translate(-50%, -50%)"
            , width: "auto"
            , height: "80%"
            , maxWidth: "100%"
            , maxHeight: "100%"
            }
          }


lookupImage :: NonEmptyArray FileRec -> Maybe FileRec
lookupImage = A.last <<< sortBySize <<< images
  where
    sortBySize = A.sortWith (_.size)


images :: NonEmptyArray FileRec -> Array FileRec
images = ANE.filter (_.basename >>> isImage)
  where
    isImage name = A.elem (Path.extname name) [".png", ".jpeg", ".jpg", ".bmp"]


