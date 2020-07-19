{-
Welcome to a Spago project!
You can edit this file as you like.
-}
{ name = "chotto-jigsaw"
, dependencies =
  [ "aff"
  , "affjax"
  , "argonaut"
  , "console"
  , "debug"
  , "effect"
  , "math"
  , "monad-loops"
  , "nullable"
  , "ordered-collections"
  , "precise-datetime"
  , "psci-support"
  , "random"
  , "react-basic"
  , "react-basic-hooks"
  , "remotedata"
  , "routing"
  , "routing-duplex"
  , "tuples"
  , "unsafe-coerce"
  , "web-dom"
  , "web-html"
  , "web-uievents"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs", "test/**/*.purs" ]
}
