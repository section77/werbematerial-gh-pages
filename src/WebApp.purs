module WebApp where


import Affjax (printResponseFormatError)
import Affjax as AX
import Affjax.ResponseFormat as ResponseFormat
import Control.Monad.Except (runExcept)
import Data.Either (Either(..))
import Data.List.NonEmpty as LNE
import Data.Maybe (Maybe(..))
import Effect (Effect)
import Effect.Aff (launchAff_)
import Effect.Class (liftEffect)
import Effect.Console (log)
import Effect.Exception (throw)
import Foreign (renderForeignError)
import Foreign.Generic (decodeJSON)
import Prelude (Unit, bind, map, ($), (=<<))
import React.Basic.DOM (render)
import Web.DOM.NonElementParentNode (getElementById)
import Web.HTML (window)
import Web.HTML.HTMLDocument (toNonElementParentNode)
import Web.HTML.Window (document)
import WebApp.App (app)


main :: Effect Unit
main = do
  root <- getElementById "root" =<< (map toNonElementParentNode $ document =<< window)
  case root of
    Nothing -> throw "root element in html site not found"
    Just root' -> launchAff_ $ do
      res <- AX.get ResponseFormat.string "/items.json"
      liftEffect $ case res.body of
        Left err -> log $ printResponseFormatError  err
        Right str -> case runExcept $ decodeJSON str of
          Left err -> log $ renderForeignError $ LNE.head err
          Right items -> render (app items) root'



