module AppPrelude
       ( module Prelude
       , module Control.MonadZero
       , module Data.Either
       , module Data.Function
       , module Data.Maybe
       , module Data.Newtype
       , module Data.Traversable
       , module Data.Tuple.Nested
       , module Effect
       , module Effect.Class
       , bool
       , throwOnLeft
       , throwOnNothing
       ) where

import Prelude

import Control.MonadZero (class Plus, empty, guard)
import Data.Either (Either(..), either, hush, isLeft, isRight, note)
import Data.Function (on)
import Data.Maybe (Maybe(..), maybe, isNothing, isJust, fromMaybe)
import Data.Newtype (unwrap)
import Data.Traversable (for, for_, traverse_, traverse)
import Data.Tuple.Nested (type (/\), (/\))
import Effect (Effect)
import Effect.Class (class MonadEffect, liftEffect)
import Effect.Exception (throw)


bool :: forall a. a -> a -> Boolean -> a
bool x y b = if b then y else x

throwOnNothing :: forall a m. MonadEffect m => String -> Maybe a -> m a
throwOnNothing msg = throwOnLeft <<< note msg

throwOnLeft :: forall a m. MonadEffect m => Either String a -> m a
throwOnLeft = either (liftEffect <<< throw) pure

