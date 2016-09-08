module SliderPair exposing (..)

import Slider
import Mouse exposing (Position)
import Html exposing (..)
import Html.App as App

main : Program Never
main =
  App.program
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }

-- MODEL

type alias Model =
  { slider1 : Slider.Model
  , slider2 : Slider.Model
  }


init : ( Model, Cmd Msg )
init = (Model (Slider.init 50 200 (Position 10 10)) (Slider.init 50 200 (Position 50 10)), Cmd.none)

-- UPDATE

type Msg
    = Slider1 Slider.Msg
    | Slider2 Slider.Msg


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        Slider1 subMsg ->
          let
            (slider1, _) = Slider.update subMsg model.slider1
          in
            ({ model | slider1 = slider1 }, Cmd.none)

        Slider2 subMsg ->
          let
            (slider2, _) = Slider.update subMsg model.slider2
          in
            ({ model | slider2 = slider2 }, Cmd.none)

-- VIEW

view : Model -> Html Msg
view model =
    div []
        [ App.map Slider1 (Slider.view model.slider1)
        , App.map Slider2 (Slider.view model.slider2)
        ]

-- Subscriptions

subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Sub.map Slider1 (Slider.subscriptions model.slider1)
        , Sub.map Slider2 (Slider.subscriptions model.slider2) ]
