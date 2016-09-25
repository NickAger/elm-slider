module Slider exposing (Model, Msg, updateMain, renderSlider, trackWidth, initModel, subscriptions, setValueIfNotDragging, getValue)

import Html exposing (..)
import Html.App as App
import Html.Attributes exposing (..)
import Html.Events exposing (on)
import Json.Decode as Json
import Mouse exposing (Position)
import Maybe.Extra

main : Program Never
main =
  App.program
    { init = ((initModel 50), Cmd.none )
    , view = view
    , update = update
    , subscriptions = subscriptions
    }

-- MODEL

type alias Model =
  { percentValue : Int
  , mouseDownOffset : Maybe Int
  }

type alias Properties =
  { topLeft : Position
  , height : Int
  }

initModel : Int -> Model
initModel percent =
  Model percent Nothing

isDragging : Model -> Bool
isDragging model = Maybe.Extra.isJust model.mouseDownOffset

setValueIfNotDragging : Int -> Model -> Model
setValueIfNotDragging newValue model =
  let
    normalisedValue = (round ((toFloat newValue) * 0.91)) - 2
  in
    if isDragging model then
      model
    else
      { model | percentValue = normalisedValue }

getValue : Model -> Int
getValue model =
  (round ((toFloat model.percentValue) * 1.099)) + 2

-- UPDATE

type Msg
    = DragStart Int
    | DragAt Int
    | DragEnd

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  ( updateMain msg model defaultPosition.y, Cmd.none )


updateMain : Msg -> Model -> Int -> Model
updateMain msg model top =
  case msg of
    DragStart mouseY ->
      let
        offset = calculateOffset mouseY top model
      in
        Model model.percentValue (Just offset)

    DragAt mouseY ->
      Model (barPercent mouseY top model) model.mouseDownOffset

    DragEnd ->
      Model model.percentValue Nothing

barPercent : Int -> Int -> Model -> Int
barPercent mouseY top model =
    let
      offset = Maybe.withDefault 0 model.mouseDownOffset
      y = toFloat (mouseY + offset)
      barY = toFloat top
      height = toFloat trackHeight
      percent =  round (100 - ((y - barY) / (height / 100)))
    in
      clamp -2 89 percent

calculateOffset : Int -> Int -> Model -> Int
calculateOffset mouseY top model =
  let
    barY = toFloat top
    height = toFloat trackHeight
    percent = toFloat model.percentValue
  in
    round (barY + ((100 - percent) * (height / 100))) - mouseY

-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
  if Maybe.Extra.isJust model.mouseDownOffset then
    Sub.batch [ Mouse.moves makeDragAt, Mouse.ups makeDragEnd ]
  else
    Sub.none

makeDragAt : Position -> Msg
makeDragAt xy = DragAt xy.y

makeDragEnd : Position -> Msg
makeDragEnd _ = DragEnd

-- VIEW

view : Model -> Html Msg
view = renderSlider defaultPosition

renderSlider : Position -> Model -> Html Msg
renderSlider position model =
  div
    [ style ((positionCSS position) ++ trackCSS) ]
    [
      div
        [ onMouseDown, style (("bottom", percentCSS model) :: thumbCSS )]
        []
    ]

positionCSS : Position -> List (String, String)
positionCSS position =
  [
    ("height", px trackHeight)
  , ("top", px position.y)
  , ("left", px position.x)
  ]

px : Int -> String
px number =
  toString number ++ "px"

percentCSS : Model -> String
percentCSS model =
  toString model.percentValue ++ "%"

onMouseDown : Attribute Msg
onMouseDown =
  on "mousedown" (Json.map makeDragStart Mouse.position)

makeDragStart : Position -> Msg
makeDragStart position = DragStart position.y

-- CSS

trackCSS : List (String, String)
trackCSS =
  [
    ("width", px trackWidth)
  , ("position", "absolute")
  , ("background-image", "url('track.jpg')")
  ]

thumbCSS : List (String, String)
thumbCSS =
  [
    ("left", "24px")
  , ("position",  "absolute")
  , ("z-index", "2")
  , ("width", "26px")
  , ("height", "54px")
  , ("background-image" , "url('thumb.jpg')")
  ]

trackWidth : Int
trackWidth = 104

trackHeight : Int
trackHeight = 363

defaultPosition : Position
defaultPosition = (Position 10 10)
