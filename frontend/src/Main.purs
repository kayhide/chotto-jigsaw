module Main where

import AppPrelude

import App.Data.DateTime (getTimezone)
import App.Env (LogLevel(..))
import App.View.Router as Router
import Control.Monad.Maybe.Trans (MaybeT(..), runMaybeT)
import Effect (Effect)
import Effect.Exception (throw)
import React.Basic.DOM (render)
import React.Basic.Hooks (element)
import Web.DOM.NonElementParentNode (getElementById)
import Web.DOM.ParentNode (querySelector)
import Web.HTML (window)
import Web.HTML.HTMLDocument (head, toNonElementParentNode)
import Web.HTML.HTMLElement (toParentNode)
import Web.HTML.HTMLMetaElement as Meta
import Web.HTML.Window (document)


main :: Effect Unit
main = do
  baseUrl <-
    readMeta "BASE_URL" >>= case _ of
      Nothing -> throw "BASE_URL is not set"
      Just x -> pure $ wrap x
  let logLevel = Dev
  timezone <- getTimezone

  window
    >>= document
    >>= toNonElementParentNode >>> getElementById "app"
    >>= case _ of
    Nothing -> throw "Container element not found."
    Just elm -> do
      router <- Router.make { baseUrl, logLevel, timezone }
      render (element router {}) elm


readMeta :: String -> Effect (Maybe String)
readMeta name = runMaybeT do
  head' <- MaybeT $ window >>= document >>= head
  meta' <- MaybeT $ toParentNode head' # querySelector (wrap $ "meta[name=" <> name <> "]")
  MaybeT $ traverse Meta.content $ Meta.fromElement meta'
