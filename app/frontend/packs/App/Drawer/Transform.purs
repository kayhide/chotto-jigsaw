module App.Drawer.Transform where

import AppPrelude

import App.EaselJS.Matrix2D (Matrix2D)
import App.EaselJS.Matrix2D as Matrix2D
import App.EaselJS.Point (Point)


type Transform =
  { position :: Point
  , rotation :: Number
  }

toMatrix :: Transform -> Matrix2D
toMatrix t =
  Matrix2D.create
  # Matrix2D.translate t.position.x t.position.y
  # Matrix2D.rotate t.rotation

