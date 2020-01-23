module App.Interactor.GameInteractor where

import AppPrelude

import App.Command.Command as Command
import App.Command.CommandManager as CommandManager
import App.Drawer.PieceActor (PieceActor)
import App.Drawer.PieceActor as PieceActor
import App.Drawer.PieceDrawer as PieceDrawer
import App.Drawer.Transform as Transform
import App.EaselJS.Container as Container
import App.EaselJS.DisplayObject as DisplayObject
import App.EaselJS.Matrix2D as Matrix2D
import App.EaselJS.Point (Point)
import App.EaselJS.Point as Point
import App.EaselJS.Rectangle (Rectangle)
import App.EaselJS.Rectangle as Rectangle
import App.EaselJS.Shape as Shape
import App.EaselJS.Stage as Stage
import App.EaselJS.Ticker as Ticker
import App.EaselJS.Type (Stage, DisplayObject)
import App.GameManager (GameManager)
import App.GameManager as GameManager
import App.Logger as Logger
import Data.Array as Array
import Data.Int as Int
import Debug.Trace (traceM)
import Effect.Random (randomRange)
import Effect.Ref (Ref)
import Effect.Ref as Ref
import Foreign.Object (Object)
import Foreign.Object as Object
import Math as Math
import Web.DOM (Element)
import Web.HTML as HTML
import Web.HTML.Window as Window

type GameInteractor =
  { game :: GameManager
  , translationTolerance :: Number
  , rotationTolerance :: Number
  , baseStage :: Stage
  , activeStage :: Stage
  , dragger :: Ref Dragger
  , shapeToPiece :: Ref (Object PieceActor)
  }

create :: GameManager -> Element -> Element -> Effect GameInteractor
create game baseCanvas activeCanvas = do
  baseStage <- Stage.create baseCanvas
  activeStage <- Stage.create activeCanvas
  Stage.toDisplayObject activeStage
    # DisplayObject.setShadow { color: "#333", offsetX: 0.0, offsetY: 0.0, blur: 4.0 }
  let translationTolerance = game.puzzleActor.body.linearMeasure / 4.0
  let rotationTolerance = 24.0
  dragger <- Ref.new emptyDragger
  shapeToPiece <-
    Ref.new
    $ Object.fromFoldable
    $ (\actor -> show actor.shape.id /\ actor) <$> game.pieceActors

  Container.addContainer game.puzzleActor.container $ Stage.toContainer baseStage
  game.pieceActors # traverse_ \actor -> do
    Container.addShape actor.shape game.puzzleActor.container
    PieceDrawer.draw actor $ PieceDrawer.withImage game.picture
    boundary <- Rectangle.inflate 8.0 <$> Ref.read actor.localBoundary
    DisplayObject.cache boundary 2.0 $ Shape.toDisplayObject actor.shape

  Ticker.setFramerate 60
  Ticker.onTick $ do
    Stage.update activeStage
    Stage.update baseStage

  CommandManager.onPost \cmd -> do
    actor <- GameManager.findPieceActor game $ Command.pieceId cmd
    PieceActor.updateFace actor

  pure { game, translationTolerance, rotationTolerance, baseStage, activeStage, dragger, shapeToPiece }


contain :: Rectangle -> GameInteractor -> Effect Unit
contain rect gi = do
  let margin = gi.game.puzzleActor.body.linearMeasure
  let rect' = Rectangle.inflate margin rect

  window <- HTML.window
  width <- Int.toNumber <$> Window.innerWidth window
  height <- Int.toNumber <$> Window.innerHeight window
  let obj = Container.toDisplayObject gi.game.puzzleActor.container
  let scale = Math.min (width / rect'.width) (height / rect'.height)
  let x = width / 2.0 - scale * (rect'.x + rect'.width / 2.0)
  let y = height / 2.0 - scale * (rect'.y + rect'.height / 2.0)
  DisplayObject.update { x, y, scaleX: scale, scaleY: scale } obj
  DisplayObject.copyTransform obj $ Stage.toDisplayObject gi.activeStage
  Stage.invalidate gi.baseStage
  Stage.invalidate gi.activeStage


fit :: GameInteractor -> Effect Unit
fit gi = do
  rect <-
    Array.foldr Rectangle.addRectangle Rectangle.empty
    <$> traverse PieceActor.getBoundary gi.game.pieceActors
  contain rect gi


shuffle :: GameInteractor -> Effect Unit
shuffle gi = do
  let game = gi.game
  let width = game.puzzleActor.body.boundary.width
  let height = game.puzzleActor.body.boundary.height
  let s = Math.max width height * 2.0
  actors <- Array.filterA PieceActor.isAlive game.pieceActors
  actors # traverse_ \actor -> do
    center <- Rectangle.center <$> PieceActor.getBoundary actor
    degree <- randomRange (-180.0) 180.0
    CommandManager.post $ Command.rotate actor.body.id center degree

    vec <-
      Point.create
      <$> ((_ - center.x) <$> randomRange 0.0 s)
      <*> ((_ - center.y) <$> randomRange 0.0 s)
    CommandManager.post $ Command.translate actor.body.id vec

  CommandManager.commit


putToActiveLayer :: PieceActor -> GameInteractor -> Effect Unit
putToActiveLayer actor gi = do
  obj <- PieceActor.getFace actor
  Container.addChild obj $ Stage.toContainer gi.activeStage

lookupPieceActor :: GameInteractor -> DisplayObject -> Effect (Maybe PieceActor)
lookupPieceActor gi obj =
  Object.lookup (show obj.id) <$> Ref.read gi.shapeToPiece
  >>= traverse (GameManager.entity gi.game)





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
setPointer pt gi =
  Ref.modify_ (_{ pointer = pt }) gi.dragger

movePointerTo :: Point -> GameInteractor -> Effect Unit
movePointerTo pt gi = do
  dragger <- Ref.read gi.dragger
  when dragger.active do
    case dragger.piece of
      Nothing -> do
        let pt0 = dragger.pointer
        let vec = Point.subtract pt pt0
        let obj = Container.toDisplayObject $ gi.game.puzzleActor.container
        obj # DisplayObject.update { x: obj.x + vec.x, y: obj.y + vec.y }
        Stage.invalidate gi.baseStage
      Just actor -> do
        let obj = Container.toDisplayObject gi.game.puzzleActor.container
        pt0 <- DisplayObject.fromGlobalTo obj dragger.pointer
        pt1 <- DisplayObject.fromGlobalTo obj pt
        let vec = Point.subtract pt1 pt0
        CommandManager.post $ Command.translate actor.body.id vec
        Stage.invalidate gi.activeStage
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
        let obj = Container.toDisplayObject gi.game.puzzleActor.container
        pt0 <- DisplayObject.fromGlobalTo obj dragger.pointer
        CommandManager.post $ Command.rotate actor.body.id pt0 (angle - dragger.spinner)
        Stage.invalidate gi.activeStage

pegZoomer :: Number -> GameInteractor -> Effect Unit
pegZoomer scale gi =
  Ref.modify_ (_{ zoomer = scale }) gi.dragger

zoomPointer :: Number -> GameInteractor -> Effect Unit
zoomPointer scale gi = do
  dragger <- Ref.read gi.dragger
  when (dragger.active && isNothing dragger.piece) do
    let obj = Container.toDisplayObject gi.game.puzzleActor.container
    let pt0 = dragger.pointer
    let t =
          Matrix2D.create
          # Matrix2D.translate pt0.x pt0.y
          # Matrix2D.scale (scale / dragger.zoomer)
          # Matrix2D.translate (-pt0.x) (-pt0.y)
          # Matrix2D.appendMatrix (DisplayObject.getMatrix obj)
          # Matrix2D.decompose
    DisplayObject.update t obj
    Stage.invalidate gi.baseStage


resume :: Point -> GameInteractor -> Effect Unit
resume pt gi = do
  dragger <- Ref.read gi.dragger
  piece <- do
    p <- join <$> for dragger.piece \p' -> do
      obj <- PieceActor.getFace p'
      pt' <- DisplayObject.fromGlobalTo obj pt
      bool Nothing (Just p') <$> DisplayObject.hitTest pt' obj
    case p of
      Nothing -> do
        obj <- Stage.getObjectUnderPoint pt gi.baseStage
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
    let obj = Container.toDisplayObject gi.game.puzzleActor.container
    pt0 <- DisplayObject.fromGlobalTo obj dragger.pointer
    findMeargeableOn gi pt0 mergee
      >>= traverse_ \merger -> do
        release gi
        CommandManager.post $ Command.merge merger.body.id mergee.body.id
        CommandManager.commit
        Ref.modify_ (_{ active = false, piece = Nothing }) gi.dragger
        Stage.invalidate gi.baseStage

finish :: GameInteractor -> Effect Unit
finish gi = do
  release gi
  Ref.modify_ _{ active = false } gi.dragger

capture :: GameInteractor -> PieceActor -> Effect Unit
capture gi actor = do
  dragger <- Ref.read gi.dragger
  when (isNothing dragger.piece) do
    Logger.info $ "capture: " <> show actor.body.id
    obj <- PieceActor.getFace actor
    Container.addChild obj $ Stage.toContainer gi.activeStage
    DisplayObject.copyTransform
      (Container.toDisplayObject gi.game.puzzleActor.container)
      (Stage.toDisplayObject gi.activeStage)
    Stage.invalidate gi.activeStage
    Stage.invalidate gi.baseStage
    Ref.write dragger{ piece = pure actor } gi.dragger

release :: GameInteractor -> Effect Unit
release gi = do
  dragger <- Ref.read gi.dragger
  dragger.piece # traverse_ \actor -> do
    Logger.info $ "release: " <> show actor.body.id
    obj <- PieceActor.getFace actor
    Container.addChild obj $ gi.game.puzzleActor.container
    Stage.invalidate gi.activeStage
    Stage.invalidate gi.baseStage
    CommandManager.commit
    Ref.write dragger{ piece = Nothing } gi.dragger


findMeargeableOn :: GameInteractor -> Point -> PieceActor -> Effect (Maybe PieceActor)
findMeargeableOn gi pt sbj = do
  ids <- Array.fromFoldable <$> Ref.read sbj.neighborIds
  actors <-
    Array.filter (\obj -> obj.body.id /=  sbj.body.id) <<< Array.nubBy (compare `on` _.body.id)
    <$> traverse (GameManager.entity gi.game <=< GameManager.findPieceActor gi.game) ids
  Array.head <$> Array.filterA (\obj -> isWithinTolerance gi sbj obj pt) actors

isWithinTolerance :: GameInteractor -> PieceActor -> PieceActor -> Point -> Effect Boolean
isWithinTolerance gi sbj obj pt = do
  s <- Ref.read sbj.transform
  o <- Ref.read obj.transform
  pure $ fromMaybe false do
    guard $ getAngle s.rotation o.rotation < gi.rotationTolerance
    let pt0 = Transform.toMatrix s # Matrix2D.invert # Matrix2D.apply pt
    let pt1 = Transform.toMatrix o # Matrix2D.invert # Matrix2D.apply pt
    pure $ Point.distance pt1 pt0 < gi.translationTolerance

getAngle :: Number -> Number -> Number
getAngle s o =
  Int.toNumber
  $ bool identity (360 - _) =<< (180 <= _)
  $ Int.round (s - o) `mod` 360
