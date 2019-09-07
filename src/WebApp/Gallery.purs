module WebApp.Gallery where

import Prelude

import Data.Array as A
import Data.Array.NonEmpty (NonEmptyArray)
import Data.Array.NonEmpty as ANE
import Data.Maybe (Maybe(..), maybe)
import Data.String as S
import Effect.Uncurried (mkEffectFn1)
import Indexer.FSEntry (FileRec)
import Items (Items(..))
import Node.Path as P
import Node.Path as Path
import React.Basic (JSX, createComponent, make)
import React.Basic as React
import React.Basic.DOM as R
import React.Basic.DOM.Events (capture_)
import WebApp.Gallery.Modal (modal)
import WebApp.Gallery.ZoomSlider (zoomSlider)


type Props =
  { items :: Items }

type State =
  { cellSize :: Int
  , showModal :: Maybe { label :: String, files :: NonEmptyArray FileRec }
  }

type Self = React.Self Props State

gallery :: Props -> JSX
gallery = make (createComponent "Gallery") { initialState, render }
  where

    initialState :: State
    initialState = { cellSize: 260, showModal: Nothing }

    render :: Self -> JSX
    render self =
      React.fragment
      [ zoomSlider { value: self.state.cellSize
                   , min: 200
                   , max: 500
                   , onChange: mkEffectFn1 (\v -> self.setState _ { cellSize = v }) }
      , modal { showModal: self.state.showModal
              , onClick: capture_ $ self.setState \s -> s { showModal = Nothing }
              }
      , renderItems self self.props.items
      ]



renderItems :: Self -> Items -> JSX
renderItems self (Category{ label, path, items }) =
  let { yes: items', no: categories } = A.partition isItem items
      sorted = A.concat [items', categories]
  in if A.null items' then
       R.div { className: "row", id: path, children: map (renderItems self) categories }
     else
       React.fragment
       [ R.div { className: "row"}
       , R.div
         { className: "row card-panel brown lighten-5"
         , style: R.css { margin: "15px", borderRadius: "15px" }
         , children:
           [ R.h5 { id: path
                  , className: "brown lighten-1"
                  , style: R.css { textTransform: "capitalize", borderRadius: "5px", padding: "10px" }
                  , children: map (\p -> R.span { className: "breadcrumb", children: [R.text $ cleanupName p] })
                                $ S.split (S.Pattern "/") path}
           , React.fragment $ map (renderItems self) sorted
           ]
         }
       ]
 where
    isItem = case _ of
      Item _ -> true
      Category _ -> false

renderItems self (Item{ label, previewImage, files }) =
  R.div
  { className: "col"
  , children:
    [ R.div
   { className: "card"
   , style: R.css { width: (show self.state.cellSize) <> "px" }
   , children:
     [ R.div
       { className: "card-image"
       , children:
         [ R.img { src: image
                 , title: "Click to enlarge"
                 , onClick: capture_ $ self.setState _ { showModal = Just { label, files } }
                 }
         ]
       }
     , R.div
       { className: "card-content"
       , children:
         [ R.span { className: "card-title"
                  , style: R.css { textTransform: "capitalize", fontSize: "18px" }
                  , children: [R.text $ cleanupName label ] }
         , R.div
           { style: R.css { borderTop: "1px solid black"
                          , marginTop: "15px"
                          , padding: "10px 0px 10px 0"
                          }
           , children: ANE.toArray $ map (\file ->
                          let ext = P.extname file.basename
                          in R.a { className: "col"
                                 , style: R.css { marginLeft: "-.3em"
                                                , marginRight: "-.3em"
                                                , textTransform: "uppercase"
                                                }
                                 , href: P.concat [ file.dirname, file.basename ]
                                 , download: file.basename
                                 , children: [R.text ext]
                                 }) files
           }
         ]
       }
     ]
   }
   ]
    }


  where
    image = maybe emptyImage (\{basename, dirname} -> Path.concat [dirname, basename]) previewImage
    emptyImage = "data:image/svg+xml;charset=UTF-8,%3csvg width='112' height='99' xmlns='http://www.w3.org/2000/svg'%3e%3cg stroke-width='2' stroke='%23CBCBC9' fill='none' fill-rule='evenodd' opacity='.7'%3e%3cpath d='M111 95L80.9997013 43 56 81.1326499 31.0002987 60.3333333 1 95'/%3e%3cpath d='M1 98h110V1H1z'/%3e%3cpath d='M49 33c0 6.6314752-5.3685248 12-12 12-6.62359 0-12-5.3685248-12-12 0-6.62359 5.37641-12 12-12 6.6314752 0 12 5.37641 12 12z'/%3e%3c/g%3e%3c/svg%3e "


-- FIXME: move this in the indexer and create new 'Item' field?
cleanupName :: String -> String
cleanupName = S.replaceAll (S.Pattern "-") (S.Replacement " ") <<< S.replaceAll (S.Pattern "_") (S.Replacement " ")
