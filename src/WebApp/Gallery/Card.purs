module WebApp.Gallery.Card where

import Prelude

import Data.Maybe (fromMaybe)
import Data.Newtype (unwrap)
import Indexer.File as File
import Item (Item(..))
import Item as Item
import React.Basic (JSX, createComponent, makeStateless)
import React.Basic.DOM as R
import React.Basic.Events (EventHandler)

type Props =
  { size :: Int
  , item :: Item
  , onClick :: EventHandler
  }

card :: Props -> JSX
card = makeStateless (createComponent "Card") render

  where

    render :: Props -> JSX
    render props = let (Item item) = props.item in
      R.div
        { style: R.css { margin: "5px", border: "1px solid #ccc", float: "left", width: props.size }
        , children:
          [ R.div { style: R.css { padding: "15px", textAlign: "center" }
                  , children: [ R.text item.name ]
                  }
          , R.img { src: fromMaybe defaultImgSrc (Item.previewImagePath props.item)
                  , style: R.css { width: "100%", height: "auto", border: "1px solid black" }
                  , onClick: props.onClick
                  }
          , R.div_ $ map (\file -> R.a
                             { children: [R.text $ File.extension file]
                             , href: File.path file
                             , download: (unwrap >>> _.name) file
                             , style: R.css { margin: "5px" }
                             }) $ (unwrap >>> _.files) props.item
          ]
        }



    defaultImgSrc = "data:image/svg+xml;charset=UTF-8,%3csvg width='112' height='99' xmlns='http://www.w3.org/2000/svg'%3e%3cg stroke-width='2' stroke='%23CBCBC9' fill='none' fill-rule='evenodd' opacity='.7'%3e%3cpath d='M111 95L80.9997013 43 56 81.1326499 31.0002987 60.3333333 1 95'/%3e%3cpath d='M1 98h110V1H1z'/%3e%3cpath d='M49 33c0 6.6314752-5.3685248 12-12 12-6.62359 0-12-5.3685248-12-12 0-6.62359 5.37641-12 12-12 6.6314752 0 12 5.37641 12 12z'/%3e%3c/g%3e%3c/svg%3e "

