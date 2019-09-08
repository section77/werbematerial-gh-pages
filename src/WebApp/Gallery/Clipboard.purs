module WebApp.Gallery.Clipboard where


import Prelude

import Data.Maybe (fromJust, maybe)
import Effect (Effect)
import Effect.Uncurried (EffectFn2, runEffectFn2)
import Partial.Unsafe (unsafePartial)
import Web.DOM (Element)
import Web.DOM.Document (createElement)
import Web.DOM.Element as Element
import Web.DOM.Node as Node
import Web.DOM.NonElementParentNode (getElementById)
import Web.HTML (window)
import Web.HTML.HTMLDocument (toDocument, toNonElementParentNode)
import Web.HTML.HTMLDocument as HTMLDocument
import Web.HTML.HTMLElement as HTMLElement
import Web.HTML.HTMLInputElement (fromElement)
import Web.HTML.HTMLInputElement as HTMLInputElement
import Web.HTML.Window (document)


foreign import execCommandImpl :: EffectFn2 String String Boolean
execCommand :: String -> String -> Effect Boolean
execCommand = runEffectFn2 execCommandImpl

copyToClipboard :: String -> Effect Boolean
copyToClipboard text = unsafePartial $ do
  doc <- document =<< window

  -- lookup or create the transfer element
  element :: Element <- do
    let id = "clipboard-transfer-element"
    mayElement <- getElementById id $ toNonElementParentNode doc
    maybe (do
          element <- createElement "input" $ toDocument doc
          Element.setId id element
          Element.setAttribute "style" "position: absolute; left: -1000px" element
          body <- fromJust <$> HTMLDocument.body doc
          _ <- Node.appendChild (Element.toNode element) (HTMLElement.toNode body)
          pure element) pure mayElement

  let htmlInputElement = fromJust $ fromElement element

  -- set the given text as the content from the transfer element
  HTMLInputElement.setValue text htmlInputElement

  -- set it active
  HTMLInputElement.select htmlInputElement

  -- copy the active element value to the clipboard
  execCommand "copy" ""

