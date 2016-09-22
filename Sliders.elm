module Sliders exposing (..)

import Slider
import Mouse exposing (Position)
import Html exposing (..)
import Html.App as App

{-

Consider passing the x,y position of the slider in the view,
rather than storing it in the model

Slider needs to return it's width so the parent (ie me) can calculate
its width

Probably use an array of Sliders rather than a dictionary.

Send down the values for all siders each time, send up the values each time.

-}

main : Program Never
main =
  Html.beginnerProgram { model = initialModel, view = view, update = update }

-- MODEL

type alias Model =
  { sliders : Dict SliderId Slider.Model
  , nextSliderId : SliderId
  }

type alias SliderId = Int

initialModel : Model
initialModel =
  Model Dict.empty 0

-- UPDATE

type Msg
  = Remove SliderId
  | Add
  | SliderMsg SliderId Slider.Msg
