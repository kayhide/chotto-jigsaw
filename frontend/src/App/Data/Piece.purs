module App.Data.Piece where

import AppPrelude

import App.Pixi.Point (Point)
import App.Pixi.Point as Point
import Data.Argonaut (class DecodeJson, Json, decodeJson, (.:))
import Data.Set (Set)

type Loop = Array (Maybe Point)

newtype Piece =
  Piece
  { id :: Int
  , loops :: Array Loop
  , neighborIds :: Set Int
  }

derive instance newtypePiece :: Newtype Piece _
derive newtype instance eqPiece :: Eq Piece
derive newtype instance showPiece :: Show Piece

instance decodeJsonPiece :: DecodeJson Piece where
  decodeJson json = do
    obj <- decodeJson json
    id <- obj .: "number"
    loop <- traverse (traverse decodePoint) =<< obj .: "points"
    neighborIds <- obj .: "neighbors"
    pure
      $ wrap
      { id
      , loops: pure loop
      , neighborIds
      }

decodePoint :: Array Json -> Either String Point
decodePoint xs = do
  case xs of
    [x, y] -> Point.create <$> decodeJson x <*> decodeJson y
    _      -> Left "Expected array of [x, y]"
