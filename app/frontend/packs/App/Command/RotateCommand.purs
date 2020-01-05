module App.Command.RotateCommand where

import AppPrelude

import App.Drawer.PieceActor as PieceActor
import App.EaselJS.Matrix2D as Matrix2D
import App.EaselJS.Point (Point)
import App.EaselJS.Point as Point
import App.Game (Game)
import App.Game as Game
import Effect.Ref as Ref


type RotateCommand =
  { piece_id :: Int
  , position :: Point
  , rotation :: Number
  , center :: Point
  , degree :: Number
  }


create :: Int -> Point -> Number -> RotateCommand
create piece_id center degree =
  { piece_id
  , position: Point.create 0.0 0.0
  , rotation: 0.0
  , center
  , degree
  }


execute :: Game -> RotateCommand -> Effect Unit
execute game cmd = do
  let mtx =
        Matrix2D.create
        # Matrix2D.translate cmd.center.x cmd.center.y
        # Matrix2D.rotate cmd.degree
        # Matrix2D.translate (-cmd.center.x) (-cmd.center.y)
  actor <- Game.findPieceActor game cmd.piece_id
  actor.transform # Ref.modify_ \{ position, rotation } ->
    { position: Matrix2D.apply position mtx
    , rotation: rotation + cmd.degree
    }


isValid :: Game -> RotateCommand -> Effect Boolean
isValid game cmd = do
  Game.findPieceActor game cmd.piece_id
    >>= PieceActor.isAlive


squash :: RotateCommand -> RotateCommand -> Maybe RotateCommand
squash src dst =
  dst { degree = src.degree + dst.degree }
  <$ guard (
    src.piece_id == dst.piece_id
    && src.center.x == dst.center.x
    && src.center.y == dst.center.y
    )
