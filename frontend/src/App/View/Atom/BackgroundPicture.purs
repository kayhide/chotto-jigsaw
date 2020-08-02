module App.View.Atom.BackgroundPicture where

import AppPrelude

import React.Basic (JSX)
import React.Basic.DOM as R


render :: String -> JSX
render url =
  R.div
  { className: "background-picture"
  , children: pure $ R.div
    { className: "bg-image"
    }
  }
