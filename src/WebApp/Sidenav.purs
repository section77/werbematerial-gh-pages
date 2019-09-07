module WebApp.Sidenav where

import Prelude

import Data.Array ((:))
import Data.String as S
import Effect (Effect)
import Effect.Console (log)
import Items (Items(..))
import React.Basic (Component, JSX, createComponent, make)
import React.Basic as React
import React.Basic.DOM as R
import React.Basic.DOM.Events (capture_)


foreign import data SidenavInstance :: Type
foreign import initSidenav :: Effect SidenavInstance

type Props =
  { items :: Items
  , onClick :: String -> Effect Unit
  }


component :: Component Props
component = createComponent "Menu"


sidenav :: Props -> JSX
sidenav = make component { initialState: unit, didMount, render }

  where

    didMount self = do
      void initSidenav

    render self =
      React.fragment
       [ R.ul
          { className: "sidenav"
          , id: "slide-out"
          , children: [mkNav 0 self.props.items ]
          }
       , React.element (R.unsafeCreateDOMComponent "a")
          { href: "#"
          , "data-target": "slide-out"
          , className: "sidenav-trigger"
          , style: R.css { display: "inline" }
          , children: [ R.i { className: "material-icons", children: [ R.text "menu" ] } ]
          }
       ]


      where

        mkNav depth (Category{ label, path, items }) =
          R.li
           { style: R.css { marginLeft: (show $ depth * 10) <> "px" }
           , children: R.a
                       { href: "#" <> path
                       , className: "waves-effect sidenav-close"
                       , style: R.css {textTransform: "capitalize" }
                       , children: [R.text $ cleanupName label]
                       , onClick:  capture_  $ do
                         log "onclick"
                         self.props.onClick path
                       } : R.ul_ (map (mkNav $ depth + 1) items) : []
           }

        mkNav _ _ = mempty


-- FIXME: move this in the indexer and create new 'Item' field?
cleanupName :: String -> String
cleanupName = S.replaceAll (S.Pattern "-") (S.Replacement " ") <<< S.replaceAll (S.Pattern "_") (S.Replacement " ")
