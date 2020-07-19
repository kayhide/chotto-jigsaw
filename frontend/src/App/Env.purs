module App.Env where

import AppPrelude

import App.Api.Request (BaseUrl)
import App.Data.DateTime (Timezone)


-- | Env is a set of configurations.
-- Once loaded, it never changes all over the application.

type Env =
  { logLevel :: LogLevel
  , baseUrl :: BaseUrl
  , timezone :: Timezone
  }

data LogLevel = Dev | Prod

derive instance eqLogLevel :: Eq LogLevel
derive instance ordLogLevel :: Ord LogLevel
