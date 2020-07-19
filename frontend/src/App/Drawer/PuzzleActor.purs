module App.Drawer.PuzzleActor where

import AppPrelude

import App.Data.Puzzle (Puzzle)
import App.Pixi.Container as Container
import App.Pixi.Graphics as Graphics
import App.Pixi.Type (Container, Graphics)


type PuzzleActor =
  { body :: Puzzle
  , shape :: Graphics
  , container :: Container
  }

create :: Puzzle -> Effect PuzzleActor
create body = do
  shape <- Graphics.create
  container <- Container.create
  Container.addShape shape container
  pure { body, shape, container }
