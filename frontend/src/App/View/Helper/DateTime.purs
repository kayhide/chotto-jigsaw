module App.View.Helper.DateTime where

import AppPrelude

import App.Data.DateTime (Timezone(..))
import Data.DateTime (DateTime, adjust)
import Data.Formatter.DateTime (Formatter, FormatterCommand(..), format)
import Data.List (List(..), (:))
import Data.Time.Duration (negateDuration)


toDefaultDateTime :: DateTime -> String
toDefaultDateTime dt = format f dt
  where
    f :: Formatter
    f = YearFull
        : Placeholder "/"
        : MonthTwoDigits
        : Placeholder "/"
        : DayOfMonthTwoDigits
        : Placeholder " "
        : Hours24
        : Placeholder ":"
        : MinutesTwoDigits
        : Placeholder ":"
        : SecondsTwoDigits
        : Nil

toDateTimeIn :: Timezone -> DateTime -> String
toDateTimeIn (Timezone offset) dt =
  maybe "???" toDefaultDateTime $ adjust (negateDuration offset) dt
