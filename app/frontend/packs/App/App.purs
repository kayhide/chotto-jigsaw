module App.App where

import Prelude

import Data.Maybe (maybe)
import Effect (Effect)
import Effect.Class.Console (log)
import Effect.Exception (throw)
import Web.DOM.Element (Element)
import Web.DOM.ParentNode (QuerySelector(..), querySelector)
import Web.HTML as HTML
import Web.HTML.HTMLDocument (toParentNode)
import Web.HTML.Window as Window

type App =
  { playboard :: Element
  , field :: Element
  , sounds :: Element
  , log :: Element
  }

foreign import play :: App -> Effect Unit

query :: String -> Effect Element
query q = do
  doc <- Window.document =<< HTML.window
  elm <- querySelector (QuerySelector q) (toParentNode doc)
  maybe (throw $ "Element not found: " <> q) pure elm


init :: Effect Unit
init = do
  doc <- Window.document =<< HTML.window
  playboard <- query "#playboard"
  field <- query "#field"
  sounds <- query "#sounds"
  log <- query "#log"
  play { playboard, field, sounds, log }
