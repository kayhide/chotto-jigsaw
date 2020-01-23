module App.App where

import AppPrelude

import App.Api.Client as Api
import App.Channel.GameChannel as GameChannel
import App.Command.Command as Command
import App.Command.CommandManager as CommandManager
import App.Drawer.PieceActor as PieceActor
import App.EaselJS.Rectangle as Rectangle
import App.EaselJS.Stage as Stage
import App.EaselJS.Ticker as Ticker
import App.Firestore as Firestore
import App.GameManager (GameManager)
import App.GameManager as GameManager
import App.Interactor.BrowserInteractor as BrowserInteractor
import App.Interactor.GameInteractor (GameInteractor)
import App.Interactor.GameInteractor as GameInteractor
import App.Interactor.GuideInteractor as GuideInteractor
import App.Interactor.MouseInteractor as MouseInteractor
import App.Interactor.TouchInteractor as TouchInteractor
import App.Logger as Logger
import App.Model.Game (GameId(..))
import App.Model.Puzzle (Puzzle)
import App.Model.Puzzle as Puzzle
import App.Utils as Utils
import Data.Argonaut (jsonParser)
import Data.Array as Array
import Data.Int as Int
import Data.String (Pattern(..))
import Data.String as String
import Data.Time.Duration (Milliseconds(..))
import Debug.Trace (traceM)
import Effect.Aff (Aff, launchAff_, parallel, sequential)
import Effect.Class (liftEffect)
import Effect.Class.Console (log)
import Effect.Ref as Ref
import Web.DOM (Element)
import Web.DOM.Document as Document
import Web.DOM.Element as Element
import Web.DOM.Node as Node
import Web.DOM.NodeList as NodeList
import Web.DOM.ParentNode (QuerySelector(..), querySelector, querySelectorAll)
import Web.Event.Event (EventType(..))
import Web.Event.EventTarget (addEventListener, eventListener)
import Web.HTML as HTML
import Web.HTML.HTMLDocument (toDocument, toParentNode)
import Web.HTML.HTMLMediaElement as HTMLMediaElement
import Web.HTML.Window as Window

type App =
  { playboard :: Element
  , baseCanvas :: Element
  , activeCanvas :: Element
  , picture :: Element
  , sounds :: Element
  , log :: Element
  }

init :: Effect Unit
init = do
  Logger.append(log)

  doc <- Window.document =<< HTML.window
  playboard <- query "#playboard"
  baseCanvas <- query "#field"
  activeCanvas <- query "#active-canvas"
  picture <- query "#picture"
  sounds <- query "#sounds"
  log <- query "#log"
  play { playboard, baseCanvas, activeCanvas, picture, sounds, log }


getGameId :: Element -> Effect Int
getGameId elm = do
  x <- dataset "game-id" elm
  case Int.fromString =<< x of
    Nothing -> pure 0
    Just x' -> pure x'


play :: App -> Effect Unit
play app = do
  setupLogger app

  gameId <- getGameId app.playboard
  Logger.info $ "game id: " <> show gameId

  pictureUrl <- dataset' "picture" app.playboard
  launchAff_ do
    { image, content: puzzle /\ subscription } <- sequential $
      { image: _, content: _ }
      <$> parallel (Utils.loadImage pictureUrl)
      <*> parallel (setupPuzzle gameId app)
    gi <- liftEffect do
      Logger.info "game ready"
      game <- GameManager.create gameId puzzle image
      CommandManager.register game
      setupUi game app

      gi <- GameInteractor.create game app.baseCanvas app.activeCanvas
      BrowserInteractor.attach gi
      GuideInteractor.attach gi
      isTouchScreen <- Utils.isTouchScreen
      bool MouseInteractor.attach TouchInteractor.attach isTouchScreen gi

      dataset "initial-view" app.playboard
        >>= traverse_ \str -> do
          rect <- jsonParser str >>= Rectangle.decode # throwOnLeft
          GameInteractor.contain rect gi

      Utils.fadeOutSlow app.picture
      pure gi

    subscription # maybe
      (liftEffect $ GameInteractor.shuffle gi)
      (updateOnlineGame gi)

    liftEffect do
      Logger.info "game updated"
      query "#game-progress .loading"
        >>= Utils.fadeOutSlow
      GameInteractor.fit gi
      setupSound app

    pure unit


setupPuzzle
  :: Int -> App -> Aff (Puzzle /\ Maybe GameChannel.Subscription)
setupPuzzle gameId app = do
  bool (setupStandalonePuzzle app) (setupOnlinePuzzle gameId) (0 < gameId)


setupStandalonePuzzle
  :: App -> Aff (Puzzle /\ Maybe GameChannel.Subscription)
setupStandalonePuzzle app = liftEffect do
  Logger.info $ "standalone: " <> show true
  puzzle <- dataset' "puzzle-content" app.playboard
    >>= query
    >>= Element.toNode >>> Node.textContent
    >>= Puzzle.parse
  pure $ puzzle /\ Nothing


setupOnlinePuzzle
  :: Int -> Aff (Puzzle /\ Maybe GameChannel.Subscription)
setupOnlinePuzzle gameId = do
  sub <- GameChannel.subscribe gameId
  Logger.info $ "subscribing: GameChannel-" <> show gameId
  json <- GameChannel.requestContent sub
  puzzle <- liftEffect $ Puzzle.decode json # throwOnLeft
  pure $ puzzle /\ pure sub


updateOnlineGame :: GameInteractor -> GameChannel.Subscription -> Aff Unit
updateOnlineGame gi sub = do
  liftEffect $ do
    firestore <- Firestore.connect
    firestore # Firestore.onCommandAdd \cmd -> do
      actor <- GameManager.findPieceActor gi.game (Command.pieceId cmd)
      alive <- PieceActor.isAlive actor
      when alive do
        Command.execute gi.game cmd
        PieceActor.updateFace actor
        Stage.invalidate gi.baseStage

    CommandManager.onCommit \group -> do
      when (not group.extrinsic) do
        cmds <- Ref.read group.commands
        cmds # traverse_ \cmd ->
          Firestore.postCommand cmd firestore

        when (Array.any Command.isMerge cmds) do
          progress <- GameManager.progress gi.game
          launchAff_ do
            Api.updateGame (GameId gi.game.id) { progress }

  Utils.retryOnFailAfter (Milliseconds 5000.0) do
    GameChannel.requestUpdate sub


setupLogger :: App -> Effect Unit
setupLogger app = do
  Logger.append \msg -> do
    doc <- Window.document =<< HTML.window
    p <- Document.createElement "p" $ toDocument doc
    Node.setTextContent msg $ Element.toNode p
    void $ Node.appendChild (Element.toNode p) (Element.toNode app.log)


setupUi :: GameManager -> App -> Effect Unit
setupUi game app = do
  Ticker.onTick do
    fps <- Ticker.getMeasuredFPS
    query "#info .fps"
      >>= Element.toNode
      >>> Node.setTextContent (show $ Int.round fps)

  Utils.fadeInSlow app.activeCanvas
  Utils.fadeInSlow app.baseCanvas

  query "#log-button" >>= \btn -> do
    listener <- eventListener \e -> do
      Utils.fadeToggle app.log
      Utils.toggleClass "rotate-180" btn
    addEventListener (EventType "click") listener false (Element.toEventTarget btn)

  Utils.isFullscreenAvailable >>= if _
    then
    query "[data-action=fullscreen]"
    >>= \btn -> do
      listener <- eventListener \_ -> do
        Utils.toggleFullscreen app.playboard
      addEventListener (EventType "click") listener false (Element.toEventTarget btn)
    else
    query "[data-action=fullscreen]"
    >>= Utils.addClass "disabled"

  queryMany "[data-action=playboard-background]"
    >>= traverse_ \btn -> do
      listener <- eventListener \_ -> do
        xs <- Element.classList app.playboard
        Array.filter (String.contains (Pattern "bg-")) (Utils.toArray xs)
          # traverse_ (\x -> Utils.removeClass x app.playboard)
        ys <- Element.classList btn
        Array.find (String.contains (Pattern "bg-")) (Utils.toArray ys)
          # traverse_ (\x -> Utils.addClass x app.playboard)

      addEventListener (EventType "click") listener false (Element.toEventTarget btn)

  CommandManager.onCommit \group -> do
    cmds <- Ref.read group.commands
    when (Array.any Command.isMerge cmds) do
      progress <- GameManager.progress game
      query "#progressbar"
        >>= Element.setAttribute "style" ("width:" <> show (progress * 100.0) <> "%")


setupSound :: App -> Effect Unit
setupSound app = do
  merge <- querySelector (QuerySelector ".merge") (Element.toParentNode app.sounds)
  merge
    >>= HTMLMediaElement.fromElement
    # traverse_ \elm ->
    CommandManager.onPost \cmd -> do
      when (Command.isMerge cmd) do
        HTMLMediaElement.play elm


-- * Helper functions

query :: String -> Effect Element
query q = do
  doc <- Window.document =<< HTML.window
  querySelector (QuerySelector q) (toParentNode doc)
    >>= throwOnNothing ("Element not found: " <> q)

queryMany :: String -> Effect (Array Element)
queryMany q = do
  doc <- Window.document =<< HTML.window
  querySelectorAll (QuerySelector q) (toParentNode doc)
    >>= NodeList.toArray
    >>> map (map Element.fromNode >>> Array.catMaybes)

dataset :: String -> Element -> Effect (Maybe String)
dataset key elm =
  Element.getAttribute ("data-" <> key) elm

dataset' :: String -> Element -> Effect String
dataset' key elm =
  dataset key elm
  >>= throwOnNothing ("Data not found: " <> key)
