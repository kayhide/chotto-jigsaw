module App.Pixi.DisplayObject where

import AppPrelude

import App.Pixi.Matrix (Matrix)
import App.Pixi.Point (Point)
import App.Pixi.Type (class DisplayObject, Container)
import Data.Nullable (Nullable)
import Data.Nullable as Nullable
import Web.DOM (Element)


foreign import update :: forall attrs obj. DisplayObject obj => attrs -> obj -> Effect Unit
foreign import getMatrix :: forall obj. DisplayObject obj => obj -> Matrix
foreign import _getParent :: forall obj. DisplayObject obj => obj -> Nullable Container

foreign import getName :: forall obj. DisplayObject obj => obj -> Effect String
foreign import setName :: forall obj. DisplayObject obj => String -> obj -> Effect Unit

foreign import setHitArea :: forall hitarea obj. DisplayObject obj => hitarea -> obj -> Effect Unit
foreign import hitTest :: forall obj. DisplayObject obj => Point -> obj -> Effect Boolean

foreign import cache :: forall obj. DisplayObject obj => obj -> Effect Unit
foreign import toGlobal :: forall obj. DisplayObject obj => Point -> obj -> Effect Point
foreign import toLocal :: forall obj. DisplayObject obj => Point -> obj -> Effect Point
foreign import getCanvas :: forall obj. DisplayObject obj => obj -> Effect Element


getParent :: forall obj. DisplayObject obj => obj -> Maybe Container
getParent = Nullable.toMaybe <<< _getParent

copyTransform :: forall a b. DisplayObject a => DisplayObject b => a -> b -> Effect Unit
copyTransform src dst = update src dst

foreign import clearTransform :: forall obj. DisplayObject obj => obj -> Effect Unit


toGlobalFrom :: forall obj. DisplayObject obj => obj -> Point -> Effect Point
toGlobalFrom obj pt = toGlobal pt obj

fromGlobalTo :: forall obj. DisplayObject obj => obj -> Point -> Effect Point
fromGlobalTo obj pt = toLocal pt obj
