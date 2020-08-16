module App.Drawer.PieceDrawer where

import AppPrelude

import App.Drawer.PieceActor (PieceActor)
import App.Data.Piece (Loop)
import App.Pixi.DisplayObject as DisplayObject
import App.Pixi.Graphics as G
import App.Pixi.Point (Point)
import App.Pixi.Rectangle as Rectangle
import App.Pixi.Texture (Texture)
import App.Pixi.Type (Graphics)
import Data.Array as Array
import Effect.Ref as Ref

type PieceDrawer =
  { texture :: Maybe Texture
  , drawsImage :: Boolean
  , drawsStroke :: Boolean
  , drawsControlLine :: Boolean
  , drawsBoundary :: Boolean
  , drawsCenter :: Boolean
  , createsHitArea :: Boolean
  }

withTexture :: Texture -> PieceDrawer
withTexture texture =
  { texture: pure texture
  , drawsImage: true
  , drawsStroke: false
  , drawsControlLine: false
  , drawsBoundary: false
  , drawsCenter: false
  , createsHitArea: true
  }

draw :: PieceActor -> PieceDrawer -> Effect Unit
draw actor drawer = do
  let g = actor.shape
  G.clear g

  bool
    (G.beginFill (G.rgb 127 191 255) 0.5)
    (maybe (G.beginFill (G.rgb 255 63 63) 0.5) G.beginTextureFill drawer.texture)
    drawer.drawsImage g

  when drawer.drawsStroke do
    G.setLineStyle { width: 2.0, color: G.rgb 255 125 255 } g

  traverse_ (\loop -> drawCurve loop g) (actor.body # unwrap # _.loops)

  G.endFill g
  G.closePath g

  when drawer.drawsBoundary do
    rect <- Ref.read actor.localBoundary
    G.setLineStyle { width: 1.0, color: G.rgb 0 255 0 } g
    G.drawRect rect g
    G.closePath g

  when drawer.drawsControlLine do
    G.setLineStyle { width: 1.0, color: G.rgb 80 80 40 } g
    traverse_ (\loop -> drawPolyline loop g) (actor.body # unwrap # _.loops)
    G.closePath g

  when drawer.drawsCenter do
    pt <- Rectangle.center <$> Ref.read actor.localBoundary
    G.setLineStyle { width: 0.0 } g
    G.beginFill (G.rgb 40 255 124) 0.8 g
    G.drawCircle pt 8.0 g
    G.endFill g

  when drawer.createsHitArea do
    rect <- Ref.read actor.localBoundary
    DisplayObject.setHitArea rect actor.shape


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
