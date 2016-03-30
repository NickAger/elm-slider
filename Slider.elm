module Slider where

import Html exposing (..)
import Html.Attributes exposing (class, style)
import Html.Events exposing (on, targetValue)
import Mouse
import Signal exposing (sampleOn)
import String

--

type alias Model =
  {
    percentValue : Int
  }

view : Signal.Address Action -> Model -> Html
view address model =
  let
    height = 200
  in
    div
      [
        class "slider-track"
      , style [("height", toString height ++ "px")]
      ]
      [
        renderThumb address model
      ]

renderThumb : Signal.Address Action -> Model -> Html
renderThumb address model =
  div
    [
      class "slider-thumb"
    , style [("bottom", toString model.percentValue ++ "%")]
    , on "scroll" targetValue (\str ->
      let
        value = Result.withDefault 0 (String.toInt str)
      in
        Signal.message address (Scroll value)
        )
    ]
    []

-- UPDATE

update : Action -> Model -> Model
update action model =
  case action of
    NoOp ->
      model
    Scroll value ->
      { model | percentValue =  value }

--
initialModel : Model
initialModel =
  {
    percentValue = 50
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
  }


toPosition : (Int, Int) -> Position
toPosition (x, y) = { x = x, y = y }

zeroPosition : Position
zeroPosition =
  toPosition (0, 0)


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

zeroMouseInfo : MouseInfo
zeroMouseInfo =
  {
    position = zeroPosition
  , downPosition = zeroPosition
  }

mouseInfoSignal : Signal MouseInfo
mouseInfoSignal =
  let
    toMouseInfo position mouseDownPosition =
    { position = toPosition position
      , downPosition = mouseDownPosition
     }

    onlyDown = (\(isDown, _) -> isDown == True)
  in
    Signal.map2 toMouseInfo Mouse.position mouseDownPosition
      |> Signal.map2 (,) Mouse.isDown
      |> Signal.filter onlyDown (False, zeroMouseInfo)
      |> Signal.map (\(_, mouseInfo) -> mouseInfo) -- no longer need isDown, only necessary for filter


overThumbSignal : Signal ()
overThumbSignal =
  Signal.map2 (,) mouseInfoSignal properties
    |> Signal.filter mouseDownWithinSlider (zeroMouseInfo, initialProperties)
    |> Signal.map barPercent
    |> Signal.map (\percent -> Signal.message scrollInbox.address percent)
    |> Signal.map (\_ -> ())


mouseDownWithinSlider : (MouseInfo, Properties) -> Bool
mouseDownWithinSlider (mouseInfo, properties) =
  let
    mx = mouseInfo.downPosition.x
    x = properties.topLeft.x
    my = mouseInfo.downPosition.y
    y = properties.topLeft.y
    height = properties.height
  in
   (mx > x - 10 && mx < x + 10) && (my >= y && my <= y + height)

barPercent : (MouseInfo, Properties) -> Int
barPercent (mouseInfo, properties) =
    let
      posY = toFloat mouseInfo.position.y
      y = toFloat properties.topLeft.y
      height = toFloat properties.height
      barPercent =  round (100 - ((posY - y) / (height / 100)))
    in
      (max 0 (min 100 barPercent))



---

type alias Properties =
  {
    topLeft : Position
  , height : Int
  }

initialProperties : Properties
initialProperties =
  {
    topLeft = { x = 8, y = 8 }
  , height = 200
  }

-- PORTS

port properties : Signal Properties

port scrollChanges : Signal Int
port scrollChanges =
  scrollInbox.signal

--

type Action = NoOp | Scroll Int

mainInbox : Signal.Mailbox Action
mainInbox =
  Signal.mailbox NoOp

scrollInbox : Signal.Mailbox Int
scrollInbox =
  Signal.mailbox 50

mainSignal : Signal Action
mainSignal =
  mainInbox.signal

modelSignal : Signal Model
modelSignal =
    Signal.foldp update initialModel mainSignal

--

main : Signal Html
main =
  Signal.map (view mainInbox.address) modelSignal
