module App.Drawer.PuzzleDrawer where

import AppPrelude

import App.Drawer.PuzzleActor (PuzzleActor)
import App.EaselJS.Graphics (Graphics)
import App.EaselJS.Graphics as G
import App.EaselJS.Point as Point
import Data.Array as Array
import Data.Int as Int

type PuzzleDrawer =
  { drawsGuide :: Boolean
  }

draw :: PuzzleActor -> PuzzleDrawer -> Effect Unit
draw actor drawer = do
  let g = actor.shape.graphics
  G.clear g
  when drawer.drawsGuide $ drawGuide g

drawGuide :: Graphics -> Effect Unit
drawGuide g = do
  G.setStrokeStyle 1.0 g
  G.beginStroke "rgba(127,255,255,0.7)" g
  G.beginFill "rgba(127,255,255,0.5)" g
  G.drawCircle Point.zero 5.0 g

  G.setStrokeStyle 1.0 g
  G.beginStroke "rgba(127,255,255,0.7)" g
  for_ (Array.range (-5) 5) \i -> do
    let f = Int.toNumber i
    G.moveTo (Point.create (-500.0) (f * 100.0)) g
    G.lineTo (Point.create 500.0 (f * 100.0)) g
    G.moveTo (Point.create (f * 100.0) (-500.0)) g
    G.lineTo (Point.create (f * 100.0) 500.0) g
