module App.Command.MergeCommand where

import AppPrelude

import App.Drawer.PieceActor as PieceActor
import App.Game (Game)
import App.Game as Game


type MergeCommand =
  { piece_id :: Int
  , mergee_id :: Int
  }


create :: Int -> Int -> MergeCommand
create piece_id mergee_id = { piece_id, mergee_id }


execute :: Game -> MergeCommand -> Effect Unit
execute game cmd = do
  piece <- Game.entity game =<< Game.findPieceActor game cmd.piece_id
  mergee <- Game.entity game =<< Game.findPieceActor game cmd.mergee_id
  PieceActor.merge mergee piece


isValid :: Game -> MergeCommand -> Effect Boolean
isValid game cmd = do
  (&&)
    <$> pure (cmd.piece_id /= cmd.mergee_id)
    <*> (PieceActor.isAlive =<< Game.findPieceActor game cmd.mergee_id)
