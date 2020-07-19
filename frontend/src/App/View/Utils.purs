module App.View.Utils where

import AppPrelude

import App.Data.Route (Route, routeCodec)
import Routing.Duplex as Routing
import Routing.Hash (setHash)


navigate :: Route -> Effect Unit
navigate route = setHash $ Routing.print routeCodec route

hrefTo :: Route -> String
hrefTo route = "#" <> Routing.print routeCodec route
