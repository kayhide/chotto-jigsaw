module App.Pixi.Type where

import App.Pixi.Point (Point)
import Web.HTML (HTMLCanvasElement)


type DisplayObject =
  { position :: Point
  , rotation :: Number
  , scale :: Point
  }

type Graphics =
  { position :: Point
  , rotation :: Number
  , scale :: Point
  }

type Container =
  { position :: Point
  , rotation :: Number
  , scale :: Point
  }

type Application =
  { view :: HTMLCanvasElement
  , stage :: Container
  }
