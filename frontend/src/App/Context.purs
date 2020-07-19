module App.Context where

import AppPrelude

import App.Data.Profile (Profile)
import App.Data.Route (Route)


-- | Context holds data which is widely refered to among components.
-- It is usually provided by a Router component.

type Context =
  { route :: Route
  , currentUser :: Maybe Profile
  }
