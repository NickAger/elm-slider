module Slider where

import Html exposing (..)
import Html.Attributes exposing (class, style)
import Mouse
import Signal exposing (sampleOn)

--

type alias Model =
  {
    properties: { topLeft : Position, height : Int}
  , percentValue : Int
  }

-- CSS

trackCSS : List (String, String)
trackCSS =
  [
    ("width", "12px")
  , ("background", "#eeeeee")
  , ("border-radius", "4px")
  , ("border", "1px solid #dddddd")
  , ("position",  "relative")
  , ("margin-left", "10px")
  , ("margin-top", "10px")
  ]

thumbCSS : List (String, String)
thumbCSS =
  [
    ("border", "1px solid #cccccc")
  , ("background", "#f6f6f6")
  , ("left", "-4px")
  , ("margin-left", "0")
  , ("margin-bottom",  "-4px")
  , ("position",  "absolute")
  , ("z-index", "2")
  , ("width", "18px")
  , ("height", "18px")
  , ("border-radius", "4px")
  ]

-- VIEW

view :  Model -> Html
view  model =
  div
    []
    [
      renderSlider model
    , renderModel model
    ]

renderSlider : Model -> Html
renderSlider model =
  div
    [ style (("height", toString model.properties.height ++ "px") :: trackCSS) ]
    [
      div
        [ style (("bottom", toString model.percentValue ++ "%") :: thumbCSS )]
        []
    ]

renderModel : Model -> Html
renderModel model =
  div
    []
    [
      hr [] []
    , text <| toString model
    ]

-- UPDATE

update : MouseInfo -> Model -> Model
update mouseInfo model =
  if mouseDownWithinSlider mouseInfo model then
    { model | percentValue =  (barPercent mouseInfo model)}
  else
    model

mouseDownWithinSlider : MouseInfo -> Model -> Bool
mouseDownWithinSlider mouseInfo model =
  let
    mx = mouseInfo.downPosition.x
    x = model.properties.topLeft.x
    my = mouseInfo.downPosition.y
    y = model.properties.topLeft.y
    height = model.properties.height
  in
   (mx > x - 10 && mx < x + 10) && (my >= y && my <= y + height)

barPercent : MouseInfo -> Model -> Int
barPercent mouseInfo model =
    let
      posY = toFloat mouseInfo.position.y
      y = toFloat model.properties.topLeft.y
      height = toFloat model.properties.height
      barPercent =  round (100 - ((posY - y) / (height / 100)))
    in
      (max 0 (min 100 barPercent))

--
initialModel : Int -> Model
-- topLeft should be retrieved from jquery#offset
initialModel height =
  { properties = { topLeft = { x = 10, y = 10 }, height = height }
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


mouseInfoSignal : Signal MouseInfo
mouseInfoSignal =
  let
    toMouseInfo position mouseDownPosition =
    { position = toPosition position
      , downPosition = mouseDownPosition
     }

    zeroMouseInfo =
      {
        position = zeroPosition
      , downPosition = zeroPosition
      }
    onlyDown = (\(isDown, _) -> isDown == True)
  in
    Signal.map2 toMouseInfo Mouse.position mouseDownPosition
      |> Signal.map2 (,) Mouse.isDown
      |> Signal.filter onlyDown (False, zeroMouseInfo)
      |> Signal.map (\(_, mouseInfo) -> mouseInfo) -- no longer need isDown, only necessary for filter

modelSignal : Signal Model
modelSignal =
    Signal.foldp update (initialModel 200) mouseInfoSignal

--

main : Signal Html
main =
  Signal.map view modelSignal
