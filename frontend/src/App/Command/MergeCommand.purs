module App.Command.MergeCommand where

import AppPrelude

import App.Drawer.PieceActor as PieceActor
import App.GameManager (GameManager)
import App.GameManager as GameManager


type MergeCommand =
  { piece_id :: Int
  , mergee_id :: Int
  }


create :: Int -> Int -> MergeCommand
create piece_id mergee_id = { piece_id, mergee_id }


execute :: GameManager -> MergeCommand -> Effect Unit
execute game cmd = do
  piece <- GameManager.entity game =<< GameManager.findPieceActor game cmd.piece_id
  mergee <- GameManager.entity game =<< GameManager.findPieceActor game cmd.mergee_id
  PieceActor.merge mergee piece


isValid :: GameManager -> MergeCommand -> Effect Boolean
isValid game cmd = do
  (&&)
    <$> pure (cmd.piece_id /= cmd.mergee_id)
    <*> (PieceActor.isAlive =<< GameManager.findPieceActor game cmd.mergee_id)
