module App.Command.RotateCommand where

import AppPrelude

import App.Drawer.PieceActor as PieceActor
import App.GameManager (GameManager)
import App.GameManager as GameManager
import App.Pixi.Matrix as Matrix
import App.Pixi.Point (Point)
import App.Pixi.Point as Point
import Effect.Ref as Ref
import Math as Math


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


execute :: GameManager -> RotateCommand -> Effect Unit
execute game cmd = do
  let mtx =
        Matrix.create
        # Matrix.translate (-cmd.center.x) (-cmd.center.y)
        # Matrix.rotate (cmd.degree * Math.pi / 180.0)
        # Matrix.translate cmd.center.x cmd.center.y
  actor <- GameManager.findPieceActor game cmd.piece_id
  actor.transform # Ref.modify_ \{ position, rotation } ->
    { position: Matrix.apply position mtx
    , rotation: rotation + cmd.degree * Math.pi / 180.0
    }


isValid :: GameManager -> RotateCommand -> Effect Boolean
isValid game cmd = do
  GameManager.findPieceActor game cmd.piece_id
    >>= PieceActor.isAlive


squash :: RotateCommand -> RotateCommand -> Maybe RotateCommand
squash src dst =
  dst { degree = src.degree + dst.degree }
  <$ guard (
    src.piece_id == dst.piece_id
    && src.center.x == dst.center.x
    && src.center.y == dst.center.y
    )
