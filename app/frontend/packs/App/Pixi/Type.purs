module App.Pixi.Type where

import AppPrelude

import App.Pixi.Point (Point)
import Data.Newtype (class Newtype)
import Unsafe.Coerce (unsafeCoerce)
import Web.HTML (HTMLCanvasElement)


data SomeDisplayObject

class DisplayObject a where
  toSomeDisplayObject :: a -> SomeDisplayObject

instance displayObjectSomeDisplayObject :: DisplayObject SomeDisplayObject where
  toSomeDisplayObject = identity


newtype Graphics =
  Graphics
  { position :: Point
  , rotation :: Number
  , scale :: Point
  }

derive instance newtypeGraphics :: Newtype Graphics _

instance displayObjectGraphics :: DisplayObject Graphics where
  toSomeDisplayObject = unsafeCoerce


newtype Container =
  Container
  { position :: Point
  , rotation :: Number
  , scale :: Point
  }

derive instance newtypeContainer :: Newtype Container _

instance displayObjectContainer :: DisplayObject Container where
  toSomeDisplayObject = unsafeCoerce


newtype Application =
  Application
  { view :: HTMLCanvasElement
  , stage :: Container
  }

derive instance newtypeApplication :: Newtype Application _
