module Sliders exposing (..)

import Slider
import Mouse exposing (Position)
import Html exposing (..)
import Html.App as App
import Array exposing (Array)
import Json.Decode exposing (..)
import Json.Encode exposing (..)
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
    | ServerUpdateError
    | SliderMsg Int Slider.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SliderMsg index sliderMsg ->
            updateSliderModel index sliderMsg model

        ServerUpdate sliderValues ->
            let
                sliders =
                    Array.toList model.sliders
                        |> List.map2 Slider.setValueIfNotDragging sliderValues

                updatedModel =
                    { model | sliders = Array.fromList sliders }
            in
                ( updatedModel, Cmd.none )

        ServerUpdateError ->
            -- nothing todo
            ( model, Cmd.none )


updateSliderModel : Int -> Slider.Msg -> Model -> ( Model, Cmd Msg )
updateSliderModel index sliderMsg model =
    let
        updatedModel =
            Array.get index model.sliders
                |> Maybe.map (\sliderModel -> Slider.updateMain sliderMsg sliderModel topY)
                |> Maybe.map (\sliderModel -> { model | sliders = (Array.set index sliderModel model.sliders) })
                |> Maybe.withDefault model

        json =
            updatedModel.sliders
                |> Array.map Slider.getValue
                |> Array.toList
                |> slidersJsonString
    in
        ( updatedModel, WebSocket.send "ws://localhost:8080" json )



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
            Position (startX + (Slider.trackWidth * index)) topY
    in
        App.map (SliderMsg index) (Slider.renderSlider position aSliderModel)



-- Subscriptions


subscriptions : Model -> Sub Msg
subscriptions model =
    let
        subscriptions =
            Array.indexedMap subscriptionItem model.sliders

        subscriptionsList =
            Array.toList subscriptions

        serverUpdate =
            WebSocket.listen "ws://localhost:8080" makeServerUpdate
    in
        Sub.batch (serverUpdate :: subscriptionsList)


makeServerUpdate : String -> Msg
makeServerUpdate json =
    let
        decodeResult =
            decodeString ("sliders" := (Json.Decode.list Json.Decode.int)) json
    in
        case decodeResult of
            Result.Ok values ->
                ServerUpdate values

            Result.Err _ ->
                ServerUpdateError


subscriptionItem : Int -> Slider.Model -> Sub Msg
subscriptionItem index aSliderModel =
    Sub.map (SliderMsg index) (Slider.subscriptions aSliderModel)


slidersJson : List Int -> Json.Encode.Value
slidersJson sliderValues =
    Json.Encode.object
        [ ( "version", Json.Encode.int 1 )
        , ( "sliders", (Json.Encode.list (List.map Json.Encode.int sliderValues)) )
        ]


slidersJsonString : List Int -> String
slidersJsonString sliderValues =
    encode 0 (slidersJson sliderValues)


topY : Int
topY =
    10


startX : Int
startX =
    10
