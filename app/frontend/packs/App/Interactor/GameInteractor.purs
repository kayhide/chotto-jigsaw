module App.Interactor.GameInteractor where

import AppPrelude

import App.Command.Command as Command
import App.Command.CommandManager as CommandManager
import App.Drawer.PieceActor (PieceActor)
import App.Drawer.PieceActor as PieceActor
import App.Drawer.PieceDrawer as PieceDrawer
import App.Drawer.Transform as Transform
import App.GameManager (GameManager)
import App.GameManager as GameManager
import App.Logger as Logger
import App.Model.Puzzle (Puzzle(..))
import App.Pixi.Application as Application
import App.Pixi.Container as Container
import App.Pixi.DisplayObject as DisplayObject
import App.Pixi.Graphics as Graphics
import App.Pixi.Matrix as Matrix
import App.Pixi.Point (Point)
import App.Pixi.Point as Point
import App.Pixi.Rectangle (Rectangle)
import App.Pixi.Rectangle as Rectangle
import App.Pixi.Texture as Texture
import App.Pixi.Type (Application, Container, DisplayObject)
import Data.Array as Array
import Data.Int as Int
import Debug.Trace (traceM)
import Effect.Random (randomRange)
import Effect.Ref (Ref)
import Effect.Ref as Ref
import Foreign.Object (Object)
import Foreign.Object as Object
import Math as Math
import Web.HTML (HTMLCanvasElement)
import Web.HTML as HTML
import Web.HTML.Window as Window

type GameInteractor =
  { manager :: GameManager
  , translationTolerance :: Number
  , rotationTolerance :: Number
  , baseStage :: Application
  , activeStage :: Application
  , activeLayer :: Container
  , dragger :: Ref Dragger
  , shapeToPiece :: Ref (Object PieceActor)
  }

create :: GameManager -> HTMLCanvasElement -> HTMLCanvasElement -> Effect GameInteractor
create manager baseCanvas activeCanvas = do
  baseStage <- Application.create baseCanvas
  activeStage <- Application.create activeCanvas
  activeLayer <- Container.create
  let Puzzle puzzle = manager.puzzleActor.body
  let translationTolerance = puzzle.linearMeasure / 4.0
  let rotationTolerance = Math.pi / 8.0
  dragger <- Ref.new emptyDragger
  shapeToPiece <-
    traverse (\actor -> (_ /\ actor) <$> DisplayObject.getName (Graphics.toDisplayObject actor.shape)) manager.pieceActors
    >>= Object.fromFoldable >>> Ref.new

  Container.addContainer manager.puzzleActor.container baseStage.stage
  Container.addContainer activeLayer baseStage.stage
  -- Container.addContainer activeLayer activeStage.stage
  texture <- Texture.fromElement manager.picture
  manager.pieceActors # traverse_ \actor -> do
    Container.addShape actor.shape manager.puzzleActor.container
    PieceDrawer.draw actor $ PieceDrawer.withTexture texture
    DisplayObject.cache $ Graphics.toDisplayObject actor.shape

  CommandManager.onExecute \cmd -> do
    actor <- GameManager.findPieceActor manager $ Command.pieceId cmd
    PieceActor.updateFace actor

  pure { manager, translationTolerance, rotationTolerance, baseStage, activeStage, activeLayer, dragger, shapeToPiece }


contain :: Rectangle -> GameInteractor -> Effect Unit
contain rect gi = do
  let Puzzle puzzle = gi.manager.puzzleActor.body
  let margin = puzzle.linearMeasure
  let rect' = Rectangle.inflate margin rect

  window <- HTML.window
  width <- Int.toNumber <$> Window.innerWidth window
  height <- Int.toNumber <$> Window.innerHeight window
  let obj = Container.toDisplayObject gi.manager.puzzleActor.container
  let scale = Math.min (width / rect'.width) (height / rect'.height)
  let x = (rect'.x + rect'.width / 2.0)
  let y = (rect'.y + rect'.height / 2.0)
  let position = Point.create x y
  let t =
        Matrix.create
        # Matrix.translate (-x) (-y)
        # Matrix.scale scale
        # Matrix.decompose
  obj # DisplayObject.update t
  DisplayObject.copyTransform obj $ Container.toDisplayObject gi.activeLayer


fit :: GameInteractor -> Effect Unit
fit gi = do
  rect <-
    Array.foldr Rectangle.addRectangle Rectangle.empty
    <$> traverse PieceActor.getBoundary gi.manager.pieceActors
  contain rect gi


shuffle :: GameInteractor -> Effect Unit
shuffle gi = do
  let Puzzle puzzle = gi.manager.puzzleActor.body
  let width = puzzle.boundary.width
  let height = puzzle.boundary.height
  let l = Math.max width height
  let x0 = width / 2.0 - l
  let x1 = x0 + l * 2.0
  let y0 = height / 2.0 - l
  let y1 = y0 + l * 2.0

  actors <- Array.filterA PieceActor.isAlive gi.manager.pieceActors
  actors # traverse_ \actor -> do
    center <- Rectangle.center <$> PieceActor.getBoundary actor
    degree <- randomRange (-180.0) 180.0
    CommandManager.post $ Command.rotate actor.body.id center degree

    vec <-
      Point.create
      <$> ((_ - center.x) <$> randomRange x0 x1)
      <*> ((_ - center.y) <$> randomRange y0 y1)
    CommandManager.post $ Command.translate actor.body.id vec

  CommandManager.commit


putToActiveLayer :: PieceActor -> GameInteractor -> Effect Unit
putToActiveLayer actor gi = do
  obj <- PieceActor.getFace actor
  Container.addChild obj $ gi.activeStage.stage

lookupPieceActor :: GameInteractor -> DisplayObject -> Effect (Maybe PieceActor)
lookupPieceActor gi obj = do
  Object.lookup <$> DisplayObject.getName obj <*> Ref.read gi.shapeToPiece
  >>= traverse (GameManager.entity gi.manager)





-- * Dragger

type Dragger =
  { active :: Boolean
  , piece :: Maybe PieceActor
  , pointer :: Point
  , spinner :: Number
  , zoomer :: Number
  }

emptyDragger :: Dragger
emptyDragger =
  { active: false
  , piece: Nothing
  , pointer: Point.zero
  , spinner: 0.0
  , zoomer: 1.0
  }


setPointer :: Point -> GameInteractor -> Effect Unit
setPointer pt gi = do
  Ref.modify_ (_{ pointer = pt }) gi.dragger

movePointerTo :: Point -> GameInteractor -> Effect Unit
movePointerTo pt gi = do
  dragger <- Ref.read gi.dragger
  when dragger.active do
    case dragger.piece of
      Nothing -> do
        let project = DisplayObject.fromGlobalTo $ Container.toDisplayObject gi.baseStage.stage
        pt0 <- project dragger.pointer
        pt1 <- project pt
        let vec = Point.subtract pt1 pt0
        let obj = Container.toDisplayObject gi.manager.puzzleActor.container
        obj # DisplayObject.update { position: Point.add obj.position vec }
      Just actor -> do
        let obj = Container.toDisplayObject gi.manager.puzzleActor.container
        let project = DisplayObject.fromGlobalTo obj
        pt0 <- project dragger.pointer
        pt1 <- project pt
        let vec = Point.subtract pt1 pt0
        CommandManager.post $ Command.translate actor.body.id vec
    Ref.modify_ (_{ pointer = pt }) gi.dragger


pegSpinner :: Number -> GameInteractor -> Effect Unit
pegSpinner angle gi =
  Ref.modify_ (_{ spinner = angle }) gi.dragger

spinPointer :: Number -> GameInteractor -> Effect Unit
spinPointer angle gi = do
  dragger <- Ref.read gi.dragger
  when dragger.active do
    case dragger.piece of
      Nothing -> pure unit
      Just actor -> do
        let obj = Container.toDisplayObject gi.manager.puzzleActor.container
        pt0 <- DisplayObject.fromGlobalTo obj dragger.pointer
        CommandManager.post $ Command.rotate actor.body.id pt0 (angle - dragger.spinner)

pegZoomer :: Number -> GameInteractor -> Effect Unit
pegZoomer scale gi =
  Ref.modify_ (_{ zoomer = scale }) gi.dragger

zoomPointer :: Number -> GameInteractor -> Effect Unit
zoomPointer scale gi = do
  dragger <- Ref.read gi.dragger
  when (dragger.active && isNothing dragger.piece) do
    let obj = Container.toDisplayObject gi.manager.puzzleActor.container
    let project = DisplayObject.fromGlobalTo $ Container.toDisplayObject gi.baseStage.stage
    pt0 <- project dragger.pointer
    let t =
          Matrix.create
          # Matrix.translate (-pt0.x) (-pt0.y)
          # Matrix.scale (scale / dragger.zoomer)
          # Matrix.translate pt0.x pt0.y
          # Matrix.appendMatrix (DisplayObject.getMatrix obj)
          # Matrix.decompose
    DisplayObject.update t obj


resume :: Point -> GameInteractor -> Effect Unit
resume pt gi = do
  dragger <- Ref.read gi.dragger
  pt' <- pt # DisplayObject.fromGlobalTo (Container.toDisplayObject gi.baseStage.stage)
  piece <- do
    p <- join <$> for dragger.piece \p' -> do
      obj <- PieceActor.getFace p'
      obj' <- Application.hitTest pt gi.activeStage
      pure $ bool Nothing (Just p') $ obj' == Just obj
    case p of
      Nothing -> do
        obj <- Application.hitTest pt gi.baseStage
        join <$> traverse (lookupPieceActor gi) obj
      Just _ -> pure p
  when ((_.body.id <$> dragger.piece) /= (_.body.id <$> piece)) do
    release gi
    traverse_ (capture gi) piece
  Ref.modify_ (_{ active = true, pointer = pt }) gi.dragger

pause :: GameInteractor -> Effect Unit
pause gi = do
  Ref.modify_ _{ active = false } gi.dragger

attempt :: GameInteractor -> Effect Unit
attempt gi = do
  dragger <- Ref.read gi.dragger
  dragger.piece # traverse_ \mergee -> do
    let obj = Container.toDisplayObject gi.manager.puzzleActor.container
    pt0 <- DisplayObject.fromGlobalTo obj dragger.pointer
    findMeargeableOn gi pt0 mergee
      >>= traverse_ \merger -> do
        release gi
        CommandManager.post $ Command.merge merger.body.id mergee.body.id
        CommandManager.commit
        Ref.modify_ (_{ active = false, piece = Nothing }) gi.dragger

finish :: GameInteractor -> Effect Unit
finish gi = do
  release gi
  Ref.modify_ _{ active = false } gi.dragger

capture :: GameInteractor -> PieceActor -> Effect Unit
capture gi actor = do
  dragger <- Ref.read gi.dragger
  when (isNothing dragger.piece) do
    Logger.info $ "capture: " <> show actor.body.id
    DisplayObject.copyTransform
      (Container.toDisplayObject gi.manager.puzzleActor.container)
      (Container.toDisplayObject gi.activeLayer)
    obj <- PieceActor.getFace actor
    Container.addChild obj gi.activeLayer
    Ref.write dragger{ piece = pure actor } gi.dragger

release :: GameInteractor -> Effect Unit
release gi = do
  dragger <- Ref.read gi.dragger
  dragger.piece # traverse_ \actor -> do
    Logger.info $ "release: " <> show actor.body.id
    obj <- PieceActor.getFace actor
    Container.addChild obj $ gi.manager.puzzleActor.container
    CommandManager.commit
    Ref.write dragger{ piece = Nothing } gi.dragger


findMeargeableOn :: GameInteractor -> Point -> PieceActor -> Effect (Maybe PieceActor)
findMeargeableOn gi pt sbj = do
  ids <- Array.fromFoldable <$> Ref.read sbj.neighborIds
  actors <-
    Array.filter (\obj -> obj.body.id /=  sbj.body.id) <<< Array.nubBy (compare `on` _.body.id)
    <$> traverse (GameManager.entity gi.manager <=< GameManager.findPieceActor gi.manager) ids
  Array.head <$> Array.filterA (\obj -> isWithinTolerance gi sbj obj pt) actors

isWithinTolerance :: GameInteractor -> PieceActor -> PieceActor -> Point -> Effect Boolean
isWithinTolerance gi sbj obj pt = do
  s <- Ref.read sbj.transform
  o <- Ref.read obj.transform
  pure $ fromMaybe false do
    guard $ getAngle s.rotation o.rotation < gi.rotationTolerance
    let pt0 = Transform.toMatrix s # Matrix.invert # Matrix.apply pt
    let pt1 = Transform.toMatrix o # Matrix.invert # Matrix.apply pt
    pure $ Point.distance pt1 pt0 < gi.translationTolerance

getAngle :: Number -> Number -> Number
getAngle s o =
  (_ * (Math.pi / 180.0))
  $ Int.toNumber
  $ bool identity (360 - _) =<< (180 <= _)
  $ Int.round (s * 180.0 / Math.pi - o * 180.0 / Math.pi) `mod` 360
