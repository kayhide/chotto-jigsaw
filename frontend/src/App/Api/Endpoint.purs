module App.Api.Endpoint where

import AppPrelude hiding ((/))

import Data.Generic.Rep (class Generic)
import Data.Generic.Rep.Show (genericShow)
import Routing.Duplex (RouteDuplex', int, optional, param, prefix, root, segment, string)
import Routing.Duplex.Generic (noArgs, sum)
import Routing.Duplex.Generic.Syntax ((/))

data Endpoint
  = Login
  | Games

derive instance genericEndpoint :: Generic Endpoint _
instance showEndpoint :: Show Endpoint where
  show = genericShow


endpointCodec :: RouteDuplex' Endpoint
endpointCodec =
  root $ prefix "api" $ sum
  { "Login": "auth" / noArgs
  , "Games": "games" / noArgs
  }
