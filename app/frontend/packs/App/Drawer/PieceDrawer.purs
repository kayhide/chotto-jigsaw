module App.Drawer.PieceDrawer where

import AppPrelude

import App.Drawer.PieceActor (PieceActor)
import App.EaselJS.DisplayObject as DisplayObject
import App.EaselJS.Graphics (Graphics)
import App.EaselJS.Graphics as G
import App.EaselJS.Point (Point)
import App.EaselJS.Rectangle as Rectangle
import App.EaselJS.Shape as Shape
import App.Model.Piece (Loop)
import Data.Array as Array
import Effect.Ref as Ref
import Web.DOM (Element)

type PieceDrawer =
  { image :: Maybe Element
  , drawsImage :: Boolean
  , drawsStroke :: Boolean
  , drawsControlLine :: Boolean
  , drawsBoundary :: Boolean
  , drawsCenter :: Boolean
  , createsHitArea :: Boolean
  }

withImage :: Element -> PieceDrawer
withImage image =
  { image: pure image
  , drawsImage: true
  , drawsStroke: false
  , drawsControlLine: false
  , drawsBoundary: false
  , drawsCenter: false
  , createsHitArea: true
  }

draw :: PieceActor -> PieceDrawer -> Effect Unit
draw actor drawer = do
  let g = actor.shape.graphics
  G.clear g

  bool
    (G.beginFill "rgba(127, 191, 255, 0.5)")
    (maybe (G.beginFill "#f33") G.beginBitmapFill drawer.image)
    drawer.drawsImage g

  when drawer.drawsStroke do
    G.setStrokeStyle 2.0 g
    G.beginStroke "#faf" g

  traverse_ (\loop -> drawCurve loop g) actor.body.loops

  G.endFill g
  G.endStroke g

  when drawer.drawsBoundary do
    rect <- Ref.read actor.localBoundary
    G.setStrokeStyle 2.0 g
    G.beginStroke "#0f0" g
    G.drawRect rect g
    G.endStroke g

  when drawer.drawsControlLine do
    G.setStrokeStyle 1.0 g
    G.beginStroke "#663" g
    traverse_ (\loop -> drawPolyline loop g) actor.body.loops
    G.endStroke g

  when drawer.drawsCenter do
    pt <- Rectangle.center <$> Ref.read actor.localBoundary
    G.setStrokeStyle 2.0 g
    G.beginFill "#3f9" g
    G.drawCircle pt 8.0 g
    G.endFill g

  when drawer.createsHitArea do
    rect <- Ref.read actor.localBoundary
    shape <- Shape.create
    let g' = shape.graphics
    G.beginFill "#000" g'
    G.drawRect rect g'
    G.endFill g'

    DisplayObject.setHitArea (Shape.toDisplayObject shape)
      $ Shape.toDisplayObject actor.shape


drawCurve :: Loop -> Graphics -> Effect Unit
drawCurve loop g = do
  Array.uncons loop # traverse_ \({ head, tail }) -> do
    head # traverse_ \pt ->
      G.moveTo pt g
    f tail
  where
    f :: Array (Maybe Point) -> Effect Unit
    f pts = case Array.take 3 pts of
      [Just pt1, Just pt2, Just pt3] -> do
        G.bezierCurveTo pt1 pt2 pt3 g
        f $ Array.drop 3 pts
      [_, _, Just pt3] -> do
        G.lineTo pt3 g
        f $ Array.drop 3 pts
      _ ->
        pure unit

drawPolyline :: Loop -> Graphics -> Effect Unit
drawPolyline loop g = do
    Array.uncons loop # traverse_ \({ head, tail }) -> do
      head # traverse_ \pt ->
        G.moveTo pt g
      f tail
  where
    f :: Array (Maybe Point) -> Effect Unit
    f pts = case Array.uncons pts of
      Just { head, tail } -> do
        head # traverse_ \pt -> G.lineTo pt g
        f tail
      _ ->
        pure unit
