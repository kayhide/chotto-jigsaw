module App.Command.Command where

import AppPrelude

import App.Command.MergeCommand (MergeCommand)
import App.Command.MergeCommand as MergeCommand
import App.Command.RotateCommand (RotateCommand)
import App.Command.RotateCommand as RotateCommand
import App.Command.TranslateCommand (TranslateCommand)
import App.Command.TranslateCommand as TranslateCommand
import App.Drawer.Transform (Transform)
import App.EaselJS.Point (Point)
import App.EaselJS.Point as Point
import App.GameManager (GameManager)
import Data.Argonaut (class DecodeJson, class EncodeJson, Json, decodeJson, encodeJson, (.:))

data Command
  = Merge MergeCommand
  | Translate TranslateCommand
  | Rotate RotateCommand

squash :: Command -> Command -> Maybe Command
squash cmd cmd' = case cmd /\ cmd' of
  Translate x /\ Translate y ->
    Translate <$> TranslateCommand.squash x y
  Rotate x /\ Rotate y ->
    Rotate <$> RotateCommand.squash x y
  _ ->
    Nothing

pieceId :: Command -> Int
pieceId = case _ of
  Merge cmd -> cmd.piece_id
  Translate cmd -> cmd.piece_id
  Rotate cmd -> cmd.piece_id

isValid :: GameManager -> Command -> Effect Boolean
isValid game = case _ of
  Merge cmd -> MergeCommand.isValid game cmd
  Translate cmd -> TranslateCommand.isValid game cmd
  Rotate cmd -> RotateCommand.isValid game cmd

execute :: GameManager -> Command -> Effect Unit
execute game cmd = do
  b <- isValid game cmd
  when b case cmd of
    Merge cmd' -> MergeCommand.execute game cmd'
    Translate cmd' -> TranslateCommand.execute game cmd'
    Rotate cmd' -> RotateCommand.execute game cmd'


merge :: Int -> Int -> Command
merge piece_id mergee_id =
  Merge $ MergeCommand.create piece_id mergee_id

translate :: Int -> Point -> Command
translate piece_id vector =
  Translate $ TranslateCommand.create piece_id vector

rotate :: Int -> Point -> Number -> Command
rotate piece_id center degree =
  Rotate $ RotateCommand.create piece_id center degree


isMerge :: Command -> Boolean
isMerge = case _ of
  Merge _ -> true
  _ -> false


getTransform :: Command -> Maybe Transform
getTransform = case _ of
  Merge _ -> Nothing
  Translate cmd -> Just { position: cmd.position, rotation: cmd.rotation }
  Rotate cmd -> Just { position: cmd.position, rotation: cmd.rotation }


instance encodeJsonCommand :: EncodeJson Command where
  encodeJson = case _ of
    Merge cmd -> encodeJson
      { type: "MergeCommand"
      , piece_id: cmd.piece_id
      , mergee_id: cmd.mergee_id
      }
    Translate cmd -> encodeJson
      { type: "TranslateCommand"
      , piece_id: cmd.piece_id
      , position_x: cmd.position.x
      , position_y: cmd.position.y
      , rotation: cmd.rotation
      , delta_x: cmd.vector.x
      , delta_y: cmd.vector.y
      }
    Rotate cmd -> encodeJson
      { type: "RotateCommand"
      , piece_id: cmd.piece_id
      , position_x: cmd.position.x
      , position_y: cmd.position.y
      , rotation: cmd.rotation
      , pivot_x: cmd.center.x
      , pivot_y: cmd.center.y
      , delta_degree: cmd.degree
      }

instance decodeJsonCommand :: DecodeJson Command where
  decodeJson json = do
    obj <- decodeJson json
    obj .: "type"
      >>= case _ of
        "MergeCommand" -> do
          merge
            <$> obj .: "piece_id"
            <*> obj .: "mergee_id"
        "TranslateCommand" -> do
          translate
            <$> obj .: "piece_id"
            <*> ( Point.create
                  <$> obj .: "delta_x"
                  <*> obj .: "delta_y"
                )
        "RotateCommand" -> do
          rotate
            <$> obj .: "piece_id"
            <*> (  Point.create
                   <$> obj .: "pivot_x"
                   <*> obj .: "pivot_y"
                )
            <*> obj .: "delta_degree"
        _ -> Left "Expected one of (MergeCommand|TranslateCommand|RotateCommand)"
