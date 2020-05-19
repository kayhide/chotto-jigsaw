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
    , "psci-support"
    , "random"
    , "tuples"
    , "unsafe-coerce"
    , "web-dom"
    , "web-html"
    , "web-uievents"
    ]
, packages = ./packages.dhall
, sources = [ "frontend/src/**/*.purs" ]
}
