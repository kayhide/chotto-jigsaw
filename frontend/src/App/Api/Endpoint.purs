module App.Api.Endpoint where

import AppPrelude hiding ((/))

import App.Data.Picture (PictureId)
import App.Data.Game (GameId)
import Data.Generic.Rep (class Generic)
import Data.Generic.Rep.Show (genericShow)
import Data.Lens.Iso.Newtype (_Newtype)
import Routing.Duplex (RouteDuplex', int, prefix, root, segment)
import Routing.Duplex.Generic (noArgs, sum)
import Routing.Duplex.Generic.Syntax ((/))

data Endpoint
  = Login
  | Pictures
  | Picture PictureId
  | PictureGames PictureId
  | Games
  | Game GameId

derive instance genericEndpoint :: Generic Endpoint _
instance showEndpoint :: Show Endpoint where
  show = genericShow


endpointCodec :: RouteDuplex' Endpoint
endpointCodec =
  root $ prefix "api" $ sum
  { "Login": "auth" / noArgs
  , "Pictures": "pictures" / noArgs
  , "Picture": "pictures" / (_Newtype (int segment) :: RouteDuplex' PictureId)
  , "PictureGames": "pictures" / (_Newtype (int segment) :: RouteDuplex' PictureId) / "games"
  , "Games": "games" / noArgs
  , "Game": "games" / (_Newtype (int segment) :: RouteDuplex' GameId)
  }
