module App.View.Skeleton.Wide where

import AppPrelude

import App.View.Atom.BackgroundPicture as BackgroundPicture
import Prim.Row as Row
import React.Basic.DOM as R
import React.Basic.Hooks (JSX, fragment)
import React.Basic.Hooks as React
import Record as Record


type PropsRow =
  ( alpha :: JSX
  | PropsRowOptional
  )

type PropsRowOptional =
  ( header :: JSX
  , footer :: JSX
  )

type Props = { | PropsRow }

render ::
  forall props props'.
  Row.Union props PropsRowOptional props' =>
  Row.Nub props' PropsRow =>
  { | props } -> JSX
render props = do
  let def = { header: mempty, footer: mempty } :: { | PropsRowOptional }
  let { alpha, header, footer } = Record.merge props def :: Props
  fragment
    [ BackgroundPicture.render ""
    , R.div
      { className: "flex flex-col w-screen h-screen"
      , children:
        [ header
        , R.div
          { className: "flex-grow w-full"
          , children:
            [ R.div
              { className: "w-full mx-auto max-w-3xl"
              , children: pure $ alpha
              }
            ]
          }
        , footer
        ]
      }
    ]
