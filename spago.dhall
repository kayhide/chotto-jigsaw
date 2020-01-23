{-
Welcome to a Spago project!
You can edit this file as you like.
-}
{ name = "my-project"
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
    , "web-dom"
    , "web-html"
    , "web-uievents"
    ]
, packages = ./packages.dhall
, sources = [ "app/frontend/packs/**/*.purs", "test/frontend/**/*.purs" ]
}
