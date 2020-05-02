module App.Command.CommandGroup where

import AppPrelude

import App.Command.Command (Command)
import App.Command.Command as Command
import Data.Array as Array
import Effect.Ref (Ref)
import Effect.Ref as Ref

type CommandGroup =
  { extrinsic :: Boolean
  , commands :: Ref (Array Command)
  }

create :: Effect CommandGroup
create = do
  commands <- Ref.new []
  pure { extrinsic: false, commands }

createExtrinsic :: Effect CommandGroup
createExtrinsic = do
  commands <- Ref.new []
  pure { extrinsic: true, commands }

squash :: Command -> CommandGroup -> Effect Unit
squash cmd group =
  group.commands # Ref.modify_ \cmds ->
    fromMaybe (Array.snoc cmds cmd) do
      { init, last } <- Array.unsnoc cmds
      cmd' <- Command.squash cmd last
      pure $ Array.snoc init cmd'

any :: (Command -> Boolean) -> CommandGroup -> Effect Boolean
any pred group =
  Ref.read group.commands <#> Array.any pred
