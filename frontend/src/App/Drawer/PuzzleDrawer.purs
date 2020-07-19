module App.Drawer.PuzzleDrawer where

import AppPrelude

import App.Drawer.PuzzleActor (PuzzleActor)
import App.Data.Puzzle (Puzzle(..))
import App.Pixi.Graphics as G
import App.Pixi.Point as Point
import App.Pixi.Rectangle as Rectangle
import App.Pixi.Type (Graphics)
import Data.Array as Array
import Data.Int as Int

type PuzzleDrawer =
  { drawsGuide :: Boolean
  }

draw :: PuzzleActor -> PuzzleDrawer -> Effect Unit
draw actor drawer = do
  let g = actor.shape
  g # G.clear
  when drawer.drawsGuide do
    g # drawGrid
    g # drawBounds actor

drawBounds :: PuzzleActor -> Graphics -> Effect Unit
drawBounds actor g = do
  let color = G.rgb 255 255 100
  let Puzzle { boundary: rect } = actor.body

  let center = Rectangle.center rect
  g # G.setLineStyle { width: 0.0, color }
  g # G.beginFill color 0.5
  g # G.drawCircle center 5.0
  g # G.endFill

  let len = max rect.width rect.height
  let rect' = Rectangle.create (center.x - len) (center.y - len) (len * 2.0) (len * 2.0)
  g # G.setLineStyle { width: 1.0, color }
  g # G.drawRect rect
  g # G.drawRect rect'

drawGrid :: Graphics -> Effect Unit
drawGrid g = do
  let color = G.rgb 127 255 127

  g # G.setLineStyle { width: 1.0, color }
  g # G.beginFill color 0.5
  g # G.drawCircle Point.zero 5.0
  g # G.endFill

  let n0 = (-10)
  let n1 = 10
  for_ (Array.range n0 n1) \i -> do
    let f = Int.toNumber i
    g # G.setLineStyle { width: bool 1.0 2.0 (i == 0), color }
    g # G.moveTo (Point.create (Int.toNumber n0 * 100.0) (f * 100.0))
    g # G.lineTo (Point.create (Int.toNumber n1 * 100.0) (f * 100.0))
    g # G.moveTo (Point.create (f * 100.0) (Int.toNumber n0 * 100.0))
    g # G.lineTo (Point.create (f * 100.0) (Int.toNumber n1 * 100.0))
