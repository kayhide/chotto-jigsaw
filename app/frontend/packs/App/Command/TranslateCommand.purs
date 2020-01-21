module App.Command.TranslateCommand where

import AppPrelude

import App.Drawer.PieceActor as PieceActor
import App.EaselJS.Point (Point)
import App.EaselJS.Point as Point
import App.Game (Game)
import App.Game as Game
import Effect.Ref as Ref


type TranslateCommand =
  { piece_id :: Int
  , position :: Point
  , rotation :: Number
  , vector :: Point
  }


create :: Int -> Point -> TranslateCommand
create piece_id vector = { piece_id, position: Point.create 0.0 0.0, rotation: 0.0, vector }


execute :: Game -> TranslateCommand -> Effect Unit
execute game cmd = do
  actor <- Game.findPieceActor game cmd.piece_id
  actor.transform # Ref.modify_ \{ position, rotation } ->
    { position: Point.add position cmd.vector
    , rotation
    }


isValid :: Game -> TranslateCommand -> Effect Boolean
isValid game cmd = do
  Game.findPieceActor game cmd.piece_id
    >>= PieceActor.isAlive


squash :: TranslateCommand -> TranslateCommand -> Maybe TranslateCommand
squash src dst =
  dst { vector = Point.add src.vector dst.vector }
  <$ guard (src.piece_id == dst.piece_id)