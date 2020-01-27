module App.Drawer.Transform where

import AppPrelude

import App.Pixi.Matrix (Matrix)
import App.Pixi.Matrix as Matrix
import App.Pixi.Point (Point)


type Transform =
  { position :: Point
  , rotation :: Number
  }

toMatrix :: Transform -> Matrix
toMatrix t =
  Matrix.create
  # Matrix.rotate t.rotation
  # Matrix.translate t.position.x t.position.y
