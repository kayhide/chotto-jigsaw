module App.Drawer.PuzzleActor where

import AppPrelude

import App.EaselJS.Container as Container
import App.EaselJS.Shape as Shape
import App.EaselJS.Type (Container, Shape)
import App.Model.Puzzle (Puzzle)


type PuzzleActor =
  { body :: Puzzle
  , shape :: Shape
  , container :: Container
  }

create :: Puzzle -> Effect PuzzleActor
create body = do
  shape <- Shape.create
  container <- Container.create
  Container.addShape shape container
  pure { body, shape, container }
