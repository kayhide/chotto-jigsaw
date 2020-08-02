module App.GameManager where

import AppPrelude

import App.Drawer.PieceActor (PieceActor)
import App.Drawer.PieceActor as PieceActor
import App.Drawer.PuzzleActor (PuzzleActor)
import App.Drawer.PuzzleActor as PuzzleActor
import App.Drawer.PuzzleDrawer as PuzzleDrawer
import App.Data.Game (GameId)
import App.Data.Puzzle (Puzzle)
import Data.Array ((!!))
import Data.Array as Array
import Data.Int as Int
import Effect.Ref as Ref
import Web.DOM (Element)

type GameManager =
  { gameId :: GameId
  , picture :: Element
  , puzzleActor :: PuzzleActor
  , pieceActors :: Array PieceActor
  }

create :: GameId -> Puzzle -> Element -> Effect GameManager
create gameId puzzle picture = do
  puzzleActor <- PuzzleActor.create puzzle
  pieceActors <- traverse PieceActor.create (unwrap puzzle).pieces
  PuzzleDrawer.draw puzzleActor { drawsGuide: false }

  pure
    { gameId
    , picture
    , puzzleActor
    , pieceActors
    }

progress :: GameManager -> Effect Number
progress game = do
  let actors = game.pieceActors
  let n = Array.length actors
  xs <- Array.filterA PieceActor.isAlive actors
  pure $ ((n - Array.length xs) # Int.toNumber) / ((n - 1) # Int.toNumber)

entity :: GameManager -> PieceActor -> Effect PieceActor
entity game actor =
  Ref.read actor.merger
  >>= maybe (pure actor) (findPieceActor game >=> entity game)

findPieceActor :: GameManager -> Int -> Effect PieceActor
findPieceActor game id =
  game.pieceActors !! id
    # throwOnNothing ("Piece not found: " <> show id)

