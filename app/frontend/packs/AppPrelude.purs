module AppPrelude
       ( module Prelude
       , module Control.MonadZero
       , module Data.Either
       , module Data.Function
       , module Data.Maybe
       , module Data.Traversable
       , module Data.Tuple.Nested
       , module Effect
       , bool
       , throwOnLeft
       , throwOnNothing
       ) where

import Prelude

import Control.MonadZero (class Plus, empty, guard)
import Data.Either (Either(..), either, hush, isLeft, isRight, note)
import Data.Function (on)
import Data.Maybe (Maybe(..), maybe, isNothing, isJust, fromMaybe)
import Data.Traversable (for, for_, traverse_, traverse)
import Data.Tuple.Nested (type (/\), (/\))
import Effect (Effect)
import Effect.Exception (throw)


bool :: forall a. a -> a -> Boolean -> a
bool x y b = if b then y else x

throwOnNothing :: forall a. String -> Maybe a -> Effect a
throwOnNothing msg = throwOnLeft <<< note msg

throwOnLeft :: forall a. Either String a -> Effect a
throwOnLeft = either throw pure

