module App.EaselJS.Type where

import App.EaselJS.Graphics (Graphics)
import Web.DOM (Element)


type DisplayObject =
  { id :: Int
  , x :: Number
  , y :: Number
  , rotation :: Number
  , scaleX :: Number
  , scaleY :: Number
  }


type Shape =
  { id :: Int
  , graphics :: Graphics
  }

foreign import data Container :: Type

type Stage =
  { canvas :: Element
  }
