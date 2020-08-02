module App.Data.Route where

import AppPrelude hiding ((/))

import App.Data.Game (GameId)
import Data.Generic.Rep (class Generic)
import Data.Generic.Rep.Show (genericShow)
import Data.Lens.Iso.Newtype (_Newtype)
import Routing.Duplex (RouteDuplex', int, root, segment)
import Routing.Duplex.Generic (noArgs, sum)
import Routing.Duplex.Generic.Syntax ((/))


data Route
  = Home
  | Login
  | Logout
  | Games
  | Game GameId
  | Pictures

derive instance genericRoute :: Generic Route _
derive instance eqRoute :: Eq Route
derive instance ordRoute :: Ord Route
instance showRoute :: Show Route where
  show = genericShow


routeCodec :: RouteDuplex' Route
routeCodec =
  root $ sum
  { "Home": noArgs
  , "Login": "login" / noArgs
  , "Logout": "logout" / noArgs
  , "Games": "games" / noArgs
  , "Game": "games" / (_Newtype (int segment) :: RouteDuplex' GameId)
  , "Pictures": "pictures" / noArgs
  }
