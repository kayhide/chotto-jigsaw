module App.View.Page.PicturesPage where

import AppPrelude

import App.Context (Context)
import App.Data.Picture (Picture(..))
import App.Data.Puzzle as Puzzle
import App.Data.Route as Route
import App.Env (Env)
import App.View.Agent.GamesAgent (GamesAgent, useGamesAgent)
import App.View.Agent.PicturesAgent (PicturesAgent, usePicturesAgent)
import App.View.Atom.Icon as Icon
import App.View.Organism.HeaderMenu as HeaderMenu
import App.View.Skeleton.Wide as Wide
import App.View.Utils (navigate)
import Data.String as String
import React.Basic (JSX, element)
import React.Basic.DOM as R
import React.Basic.DOM.Events (capture_)
import React.Basic.Hooks (ReactComponent, component, useEffect, useReducer)
import React.Basic.Hooks as React


type Props =
  { context :: Context
  }

type State =
  { selectedPicture :: Maybe Picture
  }

data Action
  = SelectPicture (Maybe Picture)

type ChildProps =
  { context :: Context
  , state :: State
  , dispatch :: Action -> Effect Unit
  , pictures :: PicturesAgent
  , games :: GamesAgent
  }

make :: Env -> Effect (ReactComponent Props)
make env = do
  header <- HeaderMenu.make env
  alpha <- makeAlpha env
  component "PicturesPage" \ props@{ context } -> React.do
    let initialState =
          { selectedPicture: Nothing
          }

    state /\ dispatch <- useReducer initialState handleAction
    pictures <- usePicturesAgent env context
    games <- useGamesAgent env context

    useEffect unit do
      pictures.load
      pure $ pure unit

    pure
      $ Wide.render
      { header: element header { context }
      , alpha: element alpha { context, state, dispatch, pictures, games }
      }

handleAction :: State -> Action -> State
handleAction state = case _ of
  SelectPicture picture -> state { selectedPicture = picture }


makeAlpha :: Env -> Effect (ReactComponent ChildProps)
makeAlpha env = do
  component "Alpha" \ props@{ context, state, dispatch, pictures, games } -> React.do
    let renderPicture picture_@(Picture picture) =
          R.button
          { className: "relative pb-full w-full border border-white rounded overflow-hidden"
            <> " transition-transform duration-200 transform origin-center"
            <> bool "" " scale-105 z-20" ((_.id <<< unwrap <$> state.selectedPicture) == Just picture.id)
          , onClick: capture_ $ dispatch $ SelectPicture $ Just picture_
          , children: pure $ R.img
            { className: "absolute w-full h-full object-cover"
            , src: picture.thumbnail_url
            }
          }

    let onStart difficulty =
          state.selectedPicture # traverse_ \ (Picture picture) ->
            games.create $ picture.id /\ wrap { difficulty }

    pure
      $ R.div
      { className: "alpha w-full mt-20"
      , children:
        [ R.div
          { className: "w-full flex justify-between space-x-3"
          , children:
            [ R.button
              { className: "block w-1/2 secondary-button"
              , onClick: capture_ $ navigate Route.Games
              , children:
                [ R.i { className: "fas fa-play px-2" }
                , R.text "Games"
                ]
              }
            , R.button
              { className: "block w-1/2 secondary-button active"
              , onClick: capture_ $ navigate Route.Pictures
              , children:
                [ R.i { className: "fas fa-image px-2" }
                , R.text "Pictures"
                ]
              }
            ]
          }
        , R.div
          { className: "grid grid-cols-3 gap-3 mt-3"
          , children: renderPicture <$> pictures.items
          }
        , renderBackdrop
          { active: isJust state.selectedPicture
          , onDeactivate: dispatch $ SelectPicture Nothing
          }
        , renderStartDialog
          { active: isJust state.selectedPicture
          , picture: state.selectedPicture
          , onStart
          }
        ]
      }



type BackdropProps =
  { active :: Boolean
  , onDeactivate :: Effect Unit
  }

renderBackdrop :: BackdropProps -> JSX
renderBackdrop { active, onDeactivate } =
  R.div
  { className: "fixed inset-0 transition duration-200 bg-gray-300 bg-opacity-25 z-10"
    <> bool " opacity-0 pointer-events-none select-none" "" active
  , onClick: capture_ onDeactivate
  }

type StartDialogProps =
  { active :: Boolean
  , picture :: Maybe Picture
  , onStart :: Puzzle.Difficulty -> Effect Unit
  }

renderStartDialog :: StartDialogProps -> JSX
renderStartDialog { active, picture, onStart } =
  R.div
  { className: ""
  , children: pure $ R.div
    { className: "fixed inset-x-0 top-0 mt-20 mx-auto p-3 w-auto max-w-md bg-white rounded-lg z-50"
      <> " grid grid-cols-2 gap-3"
      <> " transition duration-200"
      <> bool " opacity-0 pointer-events-none select-none" "" active
    , children:
      [ renderButton Puzzle.Trivial
      , renderButton Puzzle.Easy
      , renderButton Puzzle.Normal
      , renderButton Puzzle.Hard
      ]
    }
  }

  where
    renderButton :: Puzzle.Difficulty -> JSX
    renderButton difficulty =
      R.button
      { className: "block px-3 py-8 rounded"
        <> (" text-" <> String.toLower (show difficulty) <> "-900")
        <> (" bg-" <> String.toLower (show difficulty) <> "-400")
      , onClick: capture_ $ onStart difficulty
      , children:
        [ Icon.render "fas fa-magic mr-2"
        , R.text $ show difficulty
        ]
      }
