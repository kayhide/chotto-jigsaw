module App.View.Atom.Icon where

import AppPrelude

import React.Basic (JSX)
import React.Basic.DOM as R


render :: String -> JSX
render className = R.i { className }
