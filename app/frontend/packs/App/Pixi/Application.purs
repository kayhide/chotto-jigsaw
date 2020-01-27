module App.Pixi.Application where

import AppPrelude

import App.Pixi.Point (Point)
import App.Pixi.Type (Application, DisplayObject)
import Data.Nullable (Nullable)
import Data.Nullable as Nullable
import Web.HTML (HTMLCanvasElement)

foreign import create :: HTMLCanvasElement -> Effect Application
foreign import adjustPlacement :: Application -> Effect Unit

foreign import _hitTest :: Point -> Application -> Effect (Nullable DisplayObject)


hitTest :: Point -> Application -> Effect (Maybe DisplayObject)
hitTest pt app = Nullable.toMaybe <$> _hitTest pt app
