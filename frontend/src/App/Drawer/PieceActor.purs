module App.Drawer.PieceActor where

import AppPrelude

import App.Drawer.Transform (Transform)
import App.Model.Piece (Piece)
import App.Model.Piece as Piece
import App.Pixi.Container as Container
import App.Pixi.DisplayObject as DisplayObject
import App.Pixi.Graphics as Graphics
import App.Pixi.Matrix as Matrix
import App.Pixi.Point as Point
import App.Pixi.Rectangle (Rectangle)
import App.Pixi.Rectangle as Rectangle
import App.Pixi.Type (Container, Graphics, SomeDisplayObject, toSomeDisplayObject)
import Data.Array as Array
import Data.Set (Set)
import Data.Set as Set
import Effect.Ref (Ref)
import Effect.Ref as Ref


type PieceActor =
  { body :: Piece
  , shape :: Graphics
  , container :: Ref (Maybe Container)
  , transform :: Ref Transform
  , loops :: Ref (Array Piece.Loop)
  , merger :: Ref (Maybe Int)
  , localBoundary :: Ref Rectangle
  , neighborIds :: Ref (Set Int)
  }

create :: Piece -> Effect PieceActor
create body = do
  shape <- Graphics.create
  shape # DisplayObject.setName ("piece-" <> show body.id)

  container <- Ref.new Nothing
  transform <- Ref.new { position: Point.zero, rotation: 0.0 }
  loops <- Ref.new body.loops
  merger <- Ref.new Nothing
  let boundary' =
        Array.foldr Rectangle.addPoint Rectangle.empty
        $ Array.catMaybes $ Array.concat body.loops
  localBoundary <- Ref.new boundary'
  neighborIds <- Ref.new body.neighborIds
  pure { body, shape, container, transform, loops, merger, localBoundary, neighborIds }

isAlive :: PieceActor -> Effect Boolean
isAlive actor = isNothing <$> Ref.read actor.merger

getFace :: PieceActor -> Effect SomeDisplayObject
getFace actor = maybe (toSomeDisplayObject actor.shape) toSomeDisplayObject <$> Ref.read actor.container

getShapes :: PieceActor -> Effect (Array Graphics)
getShapes actor =
  Ref.read actor.container
  >>= maybe (pure $ pure actor.shape) Container.getShapes

getBoundary :: PieceActor -> Effect Rectangle
getBoundary actor = do
  boundary <- Ref.read actor.localBoundary
  { position, rotation } <- Ref.read actor.transform
  let mtx =
        Matrix.create
        # Matrix.rotate rotation
        # Matrix.translate position.x position.y
  pure
    $ Array.foldr Rectangle.addPoint Rectangle.empty
    $ (\pt -> Matrix.apply pt mtx) <$> Rectangle.cornerPoints boundary


updateFace :: PieceActor -> Effect Unit
updateFace actor = do
  t <- Ref.read actor.transform
  DisplayObject.update { position: t.position, rotation: t.rotation } =<< getFace actor


merge :: PieceActor -> PieceActor -> Effect Unit
merge mergee merger = do
  Ref.write (pure merger.body.id) mergee.merger

  neighborIds <- Set.union <$> Ref.read mergee.neighborIds <*> Ref.read merger.neighborIds
  Ref.write (Set.delete merger.body.id neighborIds) merger.neighborIds
  Ref.write (Set.delete mergee.body.id neighborIds) mergee.neighborIds

  loops <- Ref.read mergee.loops
  Ref.modify_ (_ <> loops) merger.loops


  merger.localBoundary # Ref.modify_ \rect ->
    Array.foldr Rectangle.addPoint rect
    $ Array.catMaybes $ Array.concat loops

  c <- Ref.read merger.container >>= case _ of
    Nothing -> do
      let obj = merger.shape
      parent <- DisplayObject.getParent obj # throwOnNothing "No parent"
      c <- Container.create
      Ref.write (pure c) merger.container
      DisplayObject.copyTransform obj c
      DisplayObject.clearTransform obj
      Container.addShape merger.shape c
      Container.addContainer c parent
      pure c
    Just c -> pure c

  getShapes mergee
    >>= traverse_ \s -> do
      DisplayObject.clearTransform s
      Container.addShape s c
