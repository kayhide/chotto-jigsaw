module App.Utils where

import AppPrelude

import Control.Monad.Error.Class (try)
import Control.Monad.Loops (untilJust)
import Data.Array as Array
import Data.Time.Duration (Milliseconds)
import Effect.Aff (Aff, delay)
import Effect.Aff.Compat (EffectFnAff, fromEffectFnAff)
import Web.DOM (DOMTokenList)
import Web.DOM.DOMTokenList as DOMTokenList
import Web.DOM.Element (Element)
import Web.DOM.Element as Element
import Web.DOM.NodeList as NodeList
import Web.DOM.ParentNode (QuerySelector(..), querySelectorAll)
import Web.HTML as HTML
import Web.HTML.HTMLDocument (toParentNode)
import Web.HTML.Window as Window


foreign import toArray :: forall a b. a -> Array b

foreign import _loadImage :: String -> EffectFnAff Element

loadImage :: String -> Aff Element
loadImage url = fromEffectFnAff $ _loadImage url


retryOnFailAfter
  :: forall a.
     Milliseconds -> Aff a -> Aff a
retryOnFailAfter ms action =
  untilJust do
    res <- try action
    when (isLeft res) do
      delay ms
    pure $ hush res


selectElements :: String -> Effect (Array Element)
selectElements q = do
  doc <- Window.document =<< HTML.window
  elms <- NodeList.toArray =<< querySelectorAll (QuerySelector q) (toParentNode doc)
  pure $ Array.catMaybes $ Element.fromNode <$> elms



foreign import isTouchScreen :: Effect Boolean
foreign import isFullscreenAvailable :: Effect Boolean
foreign import toggleFullscreen :: Element -> Effect Unit

foreign import setWidth :: forall elm. Number -> elm -> Effect Unit
foreign import setHeight :: forall elm. Number -> elm -> Effect Unit

addClass :: String -> Element -> Effect Unit
addClass name elm = void $ withClassList DOMTokenList.add name elm

removeClass :: String -> Element -> Effect Unit
removeClass name elm = void $ withClassList DOMTokenList.remove name elm

toggleClass :: String -> Element -> Effect Unit
toggleClass name elm = void $ withClassList DOMTokenList.toggle name elm

withClassList
  :: forall a.
     (DOMTokenList -> String -> Effect a) -> String -> Element -> Effect a
withClassList action name elm = do
  xs <- Element.classList elm
  action xs name

foreign import trigger :: forall elm. String -> elm -> Effect Unit

foreign import fadeInSlow :: forall elm. elm -> Effect Unit
foreign import fadeOutSlow :: forall elm. elm -> Effect Unit
foreign import fadeToggle :: forall elm. elm -> Effect Unit
