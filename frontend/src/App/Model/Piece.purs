module App.Model.Piece where

import AppPrelude

import App.Pixi.Point (Point)
import App.Pixi.Point as Point
import Data.Argonaut (Json, decodeJson, (.:))
import Data.Set (Set)

type Loop = Array (Maybe Point)

type Piece =
  { id :: Int
  , loops :: Array Loop
  , neighborIds :: Set Int
  }

decode :: Json -> Either String Piece
decode json = do
  obj <- decodeJson json
  id <- obj .: "number"
  loop <- traverse (traverse decodePoint) =<< obj .: "points"
  neighborIds <- obj .: "neighbors"
  pure
    { id
    , loops: pure loop
    , neighborIds
    }

decodePoint :: Array Json -> Either String Point
decodePoint xs = do
  case xs of
    [x, y] -> Point.create <$> decodeJson x <*> decodeJson y
    _      -> Left "Expected array of [x, y]"
