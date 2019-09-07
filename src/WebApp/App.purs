module WebApp.App where

import Prelude
import Effect (Effect)
import Items (Items)
import React.Basic (Component, JSX, createComponent, makeStateless)
import React.Basic as React
import React.Basic.DOM as R
import WebApp.Gallery (gallery)
import WebApp.Sidenav (sidenav)

foreign import scrollElementByIdIntoView :: String -> Effect Unit

type Props =
  { items :: Items }


component :: Component Props
component = createComponent "App"


app :: Props -> JSX
app = makeStateless component \props ->
      React.fragment
      [ R.nav_
        [ R.div
          { className: "nav-wrapper brown darken-1"
          , children:
            [ R.a { href: "https://github.com/section77/werbematerial"
                  , className: "brand-logo right hide-on-med-and-down"
                  , children: [R.text "S77 Werbematerial"]
                  }
            , R.ul_
               [ R.li_ [ sidenav
                         { items: props.items
                         , onClick: scrollElementByIdIntoView
                         }
                       ]
               ]
            ]
          }
        ]
      , R.div { className: "row", children: [gallery props] }
      ]
