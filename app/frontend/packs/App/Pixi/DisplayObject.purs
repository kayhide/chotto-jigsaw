module App.Pixi.DisplayObject where

import AppPrelude

import App.Pixi.Matrix (Matrix)
import App.Pixi.Point (Point)
import App.Pixi.Type (Container, DisplayObject)
import Data.Nullable (Nullable)
import Data.Nullable as Nullable
import Web.DOM (Element)


foreign import update :: forall attrs. attrs -> DisplayObject -> Effect Unit
foreign import getMatrix :: DisplayObject -> Matrix
foreign import _getParent :: DisplayObject -> Nullable Container

foreign import getName :: DisplayObject -> Effect String
foreign import setName :: String -> DisplayObject -> Effect Unit

foreign import setHitArea :: forall hitarea. hitarea -> DisplayObject -> Effect Unit
foreign import hitTest :: Point -> DisplayObject -> Effect Boolean

foreign import cache :: DisplayObject -> Effect Unit
foreign import toGlobal :: Point -> DisplayObject -> Effect Point
foreign import toLocal :: Point -> DisplayObject -> Effect Point
foreign import getCanvas :: DisplayObject -> Effect Element


getParent :: DisplayObject -> Maybe Container
getParent = Nullable.toMaybe <<< _getParent

copyTransform :: DisplayObject -> DisplayObject -> Effect Unit
copyTransform src dst = update src dst

foreign import clearTransform :: DisplayObject -> Effect Unit


toGlobalFrom :: DisplayObject -> Point -> Effect Point
toGlobalFrom obj pt = toGlobal pt obj

fromGlobalTo :: DisplayObject -> Point -> Effect Point
fromGlobalTo obj pt = toLocal pt obj
