module Sliders exposing (..)

import Slider
import Mouse exposing (Position)
import Html exposing (..)
import Html.App as App
import Array exposing (Array)
import Json.Decode exposing (..)
import WebSocket


main : Program Never
main =
    App.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL
{- might need to change `Array Slider.Model` for a
   `Dict SliderId Slider.Model` as the server *should*
   have some concept of sliderId
-}


type alias Model =
    { sliders : Array Slider.Model }


numberSliders : Int
numberSliders =
    10


init : ( Model, Cmd Msg )
init =
    ( initialModel, Cmd.none )


initialModel : Model
initialModel =
    let
        sliderModels =
            Array.repeat numberSliders (Slider.initModel 50)
    in
        (Model sliderModels)



-- UPDATE


type Msg
    = ServerUpdate (List Int)
    | SliderMsg Int Slider.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SliderMsg index sliderMsg ->
            updateSliderModel index sliderMsg model

        ServerUpdate sliderValues ->
            let
                sliders =
                    List.map2 Slider.setValueIfNotDragging sliderValues (Array.toList model.sliders)

                updatedModel =
                    { model | sliders = Array.fromList sliders }
            in
                ( updatedModel, Cmd.none )


updateSliderModel : Int -> Slider.Msg -> Model -> ( Model, Cmd Msg )
updateSliderModel index sliderMsg model =
    let
        aModel =
            Array.get index model.sliders

        updatedSliderModel =
            Maybe.map (\sliderModel -> Slider.updateMain sliderMsg sliderModel 10) aModel

        updatedModel' =
            Maybe.map (\sliderModel -> { model | sliders = (Array.set index sliderModel model.sliders) }) updatedSliderModel

        updatedModel =
            Maybe.withDefault model updatedModel'
    in
        ( updatedModel, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    let
        sliders =
            Array.indexedMap sliderView model.sliders
    in
        div [] (Array.toList sliders)


sliderView : Int -> Slider.Model -> Html Msg
sliderView index aSliderModel =
    let
        position =
            Position (10 + (Slider.trackWidth * index)) 10
    in
        App.map (SliderMsg index) (Slider.renderSlider position aSliderModel)



-- Subscriptions


subscriptions : Model -> Sub Msg
subscriptions model =
    let
        subscriptions =
            Array.indexedMap subscriptionItem model.sliders
        subscriptionsList = Array.toList subscriptions
        WebSocket.listen "ws://localhost:8080" NewMessage
    in
        Sub.batch (subscriptionsList ++ [])

makeServerUpdate : Position -> Msg
makeDragAt xy =
    DragAt xy.y

{-
ServerUpdate
   subscriptions : Model -> Sub Msg
   subscriptions model =
       WebSocket.listen "ws://localhost:8080" NewMessage
      -- WebSocket.listen "ws://echo.websocket.org" NewMessage
-}


subscriptionItem : Int -> Slider.Model -> Sub Msg
subscriptionItem index aSliderModel =
    Sub.map (SliderMsg index) (Slider.subscriptions aSliderModel)
