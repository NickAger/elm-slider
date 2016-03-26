module Slider where

import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (id, type', for, value, class)
import StartApp

--

type alias Model =
  {
    position : Position
  , value : Int
  }

view address model =
  div [ class "slider-track" ]
    [
      div [ class "slider-thumb" ] []
    ]


-- UPDATE

update : Event -> Model -> Model
update event model =
  case event of
    MouseEvent mouseInfo ->
      updateMouse mouseInfo model
    ModelEvent action ->
      updateModel action model


updateMouse : MouseInfo Model -> Model
updateMouse mouseInfo model =
  if model.mouseCaptured then

  else

  model

updateModel : Action -> Model -> Model
updateModel action model =
  case action of
    NoOp ->
      model
    MouseDownOnThumb ->
      { model | mouseCaptured = True }

initialModel =
  { position = { x = 0, y = 0 }
  , value = 50
  }

-- SIGNALS

type alias Position = {
  x : Int
, y : Int
}

type alias MouseInfo = {
  position : Position,
  downPosition : Position,
  isDown : Bool
}

toPosition : (Int, Int) -> Position
toPosition (x, y) = { x = x, y = y }

mouseDownPosition : Signal Position
mouseDownPosition =
  let
    onlyDown = (\isDown -> isDown == True)
    mouseDown = Mouse.isDown
      |> Signal.filter onlyDown False
  in
    Mouse.position
      |> sampleOn mouseDown
      |> Signal.map toPosition


mouseInfoSignal : Signal MouseInfo
mouseInfoSignal =
  let
    toMouseInfo position mouseDownPosition isDown =
      { position = toPosition position
      , downPosition = mouseDownPosition
      , isDown = isDown
     }
  in
    Signal.map3 toMouseInfo Mouse.position mouseDownPosition Mouse.isDown


inbox : Signal.Mailbox Action
inbox =
  Signal.mailbox NoOp

actions : Signal Action
actions =
  inbox.signal

type Event = MouseEvent MouseInfo | ModelEvent Action

model : Signal Event
model =
  let
    mergedSignals = Signal.merge
      (map ModelEvent actions)
      (map MouseEvent mouseInfoSignal)
  in
    Signal.foldp update initialModel mergedSignals

--

main : Signal Element
main =
  Signal.map view model
