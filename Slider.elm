module Slider exposing (Model, Msg, update, view, init, subscriptions)

import Html exposing (..)
import Html.App as App
import Html.Attributes exposing (..)
import Html.Events exposing (on)
import Json.Decode as Json exposing ((:=))
import Mouse exposing (Position)

main : Program Never
main =
  App.program
    { init = ((init 50 200 (Position 10 10)), Cmd.none )
    , view = view
    , update = update
    , subscriptions = subscriptions
    }

-- MODEL

type alias Model =
  { percentValue : Int
  , isDragging : Bool
  , properties : Properties
  }

type alias Properties =
  { topLeft : Position
  , height : Int
  }

init : Int -> Int -> Position -> Model
init percent height position =
  Model percent False (Properties position height)

-- UPDATE

type Msg
    = DragStart Position
    | DragAt Position
    | DragEnd Position

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  ( updateHelp msg model, Cmd.none )


updateHelp : Msg -> Model -> Model
updateHelp msg ({percentValue, isDragging, properties} as model) =
  case msg of
    DragStart xy ->
      Model (barPercent xy model) True properties

    DragAt xy ->
      Model (barPercent xy model) isDragging properties

    DragEnd _ ->
      Model percentValue False properties

barPercent : Position -> Model -> Int
barPercent position model =
    let
      mouseY = toFloat position.y
      barY = toFloat model.properties.topLeft.y
      height = toFloat model.properties.height
      barPercent =  round (100 - ((mouseY - barY) / (height / 100)))
    in
      clamp 0 100 barPercent

-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
  if model.isDragging then
    Sub.batch [ Mouse.moves DragAt, Mouse.ups DragEnd ]
  else
    Sub.none

-- VIEW

{-
view :  Model -> Html Msg
view  model =
  div
    []
    [
      renderSlider model
    , renderModel model
    ]
-}

view : Model -> Html Msg
view = renderSlider

renderSlider : Model -> Html Msg
renderSlider model =
  div
    [ style ((position model.properties) ++ trackCSS) ]
    [
      div
        [ onMouseDown, style (("bottom", percent model.percentValue) :: thumbCSS )]
        []
    ]

renderModel : Model -> Html Msg
renderModel model =
  div
    []
    [
      hr [] []
    , text <| toString model
    ]

position : Properties -> List (String, String)
position properties =
  [
    ("height", px properties.height)
  , ("top", px properties.topLeft.y)
  , ("left", px properties.topLeft.x)
  ]

px : Int -> String
px number =
  toString number ++ "px"

percent : Int -> String
percent number =
  toString number ++ "%"

onMouseDown : Attribute Msg
onMouseDown =
  on "mousedown" (Json.map DragStart Mouse.position)

-- CSS

trackCSS : List (String, String)
trackCSS =
  [
    ("width", "12px")
  , ("position", "absolute")
  , ("background", "#eeeeee")
  , ("border-radius", "4px")
  , ("border", "1px solid #dddddd")
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
