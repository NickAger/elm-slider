module Slider exposing (Model, Msg, update, view, init, subscriptions)

import Html exposing (..)
import Html.App as App
import Html.Attributes exposing (..)
import Html.Events exposing (on)
import Json.Decode as Json exposing ((:=))
import Mouse exposing (Position)
import Maybe exposing (..)

main : Program Never
main =
  App.program
    { init = ((init 50 726 (Position 10 10)), Cmd.none )
    , view = view
    , update = update
    , subscriptions = subscriptions
    }

-- MODEL

type alias Model =
  { percentValue : Int
  , mouseDownOffset : Maybe Int
  , properties : Properties
  }

type alias Properties =
  { topLeft : Position
  , height : Int
  }

init : Int -> Int -> Position -> Model
init percent height position =
  Model percent Nothing (Properties position height)

-- UPDATE

type Msg
    = DragStart Int
    | DragAt Int
    | DragEnd

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  ( updateHelp msg model, Cmd.none )


updateHelp : Msg -> Model -> Model
updateHelp msg ({percentValue, mouseDownOffset, properties} as model) =
  case msg of
    DragStart y ->
      let
        offset = calculateOffset y model
      in
        Model (barPercent y model) (Just offset) properties

    DragAt y ->
      Model (barPercent y model) mouseDownOffset properties

    DragEnd ->
      Model (precentageWithOffsetApplied model) Nothing properties

barPercent : Int -> Model -> Int
barPercent y model =
    let
      mouseY = toFloat y
      barY = toFloat model.properties.topLeft.y
      height = toFloat model.properties.height
      percent =  round (100 - ((mouseY - barY) / (height / 100)))
    in
      clamp -2 89 percent

calculateOffset : Int -> Model -> Int
calculateOffset y model =
   (barPercent y model) - model.percentValue

-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
  if isJust model.mouseDownOffset then
    Sub.batch [ Mouse.moves makeDragAt, Mouse.ups makeDragEnd ]
  else
    Sub.none

makeDragAt : Position -> Msg
makeDragAt xy = DragAt xy.y

makeDragEnd : Position -> Msg
makeDragEnd _ = DragEnd

isJust : Maybe a -> Bool
isJust aMaybe = case aMaybe of
  Just _ -> True
  Nothing -> False

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
        [ onMouseDown, style (("bottom", percentCSS model) :: thumbCSS )]
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

percentCSS : Model -> String
percentCSS model =
  toString (precentageWithOffsetApplied model) ++ "%"

precentageWithOffsetApplied : Model -> Int
precentageWithOffsetApplied model =
  let
    offset = withDefault 0 model.mouseDownOffset
  in
    model.percentValue - offset

onMouseDown : Attribute Msg
onMouseDown =
  on "mousedown" (Json.map makeDragStart Mouse.position)

makeDragStart : Position -> Msg
makeDragStart position = DragStart position.y

-- CSS

trackCSS : List (String, String)
trackCSS =
  [
    ("width", "208px")
  , ("position", "absolute")
  , ("background", "#eeeeee")
  , ("border-radius", "4px")
  , ("border", "1px solid #dddddd")
  , ("margin-left", "10px")
  , ("margin-top", "10px")
  , ("background-image", "url('track.jpg')")
  ]

thumbCSS : List (String, String)
thumbCSS =
  [
--    ("border", "1px solid #cccccc")
--  , ("background", "#f6f6f6")
    ("left", "48px")
  , ("margin-left", "0")
  , ("margin-bottom",  "-4px")
  , ("position",  "absolute")
  , ("z-index", "2")
  , ("width", "52px")
  , ("height", "108px")
  , ("border-radius", "4px")
  , ("background-image" , "url('thumb.jpg')")
  ]
