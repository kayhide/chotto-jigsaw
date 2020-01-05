{-
Welcome to a Spago project!
You can edit this file as you like.
-}
{ name = "my-project"
, dependencies =
    [ "console"
    , "debug"
    , "effect"
    , "math"
    , "psci-support"
    , "web-dom"
    , "web-html"
    ]
, packages = ./packages.dhall
, sources = [ "app/frontend/packs/**/*.purs", "test/frontend/**/*.purs" ]
}
