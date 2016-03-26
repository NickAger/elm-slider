module Slider where

import Html exposing (..)
import Html.Attributes exposing (class, style)
import Mouse
import Signal exposing (sampleOn)

--

type alias Model =
  {
    topLeft : Position
  , height : Int
  , percentValue : Int
  }

view :  Model -> Html
view  model =
  div
    [
      class "slider-track"
    , style [("height", toString model.height ++ "px")]
    ]
    [
      div
        [
          class "slider-thumb"
        , style [("bottom", toString model.percentValue ++ "%")]
        ]
        []
    ]

-- UPDATE

mouseDownWithinSlider : MouseInfo -> Model -> Bool
mouseDownWithinSlider mouseInfo model =
  let
    mx = mouseInfo.downPosition.x
    x = model.topLeft.x
    my = mouseInfo.downPosition.y
    y = model.topLeft.y
    height = model.height
  in
   (mx > x - 10 && mx < x + 10) && (my >= y && my <= y + height)

barPercent : MouseInfo -> Model -> Int
barPercent mouseInfo model =
    let
      posY = toFloat mouseInfo.position.y
      y = toFloat model.topLeft.y
      height = toFloat model.height
      barPercent =  round (100 - ((posY - y) / (height / 100)))
    in
      (max 0 (min 100 barPercent))

update : MouseInfo -> Model -> Model
update mouseInfo model =
  if mouseInfo.isDown && (mouseDownWithinSlider mouseInfo model) then
    { model | percentValue =  (barPercent mouseInfo model)}
  else
    model

--
initialModel : Model
initialModel =
  { topLeft = { x = 8, y = 8 }
  , height = 200
  , percentValue = 50
  }

-- SIGNALS

type alias Position =
  {
    x : Int
  , y : Int
  }

type alias MouseInfo =
  {
    position : Position
  , downPosition : Position
  , isDown : Bool
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

modelSignal : Signal Model
modelSignal =
    Signal.foldp update initialModel mouseInfoSignal

--

main : Signal Html
main =
  Signal.map view modelSignal
