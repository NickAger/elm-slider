module Sliders exposing (..)

import Slider
import Mouse exposing (Position)
import Html exposing (..)
import Array exposing (Array)
import Json.Decode as Decode
import Json.Encode as Encode
import WebSocket


main : Program Never Model Msg
main =
    Html.program
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
    = ServerUpdate (Result String (List Int))
    | SliderMsg Int Slider.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SliderMsg index sliderMsg ->
            updateSliderModel index sliderMsg model

        ServerUpdate sliderValuesResult ->
            handleServerUpdate sliderValuesResult model


handleServerUpdate : Result String (List Int) -> Model -> ( Model, Cmd Msg )
handleServerUpdate sliderValuesResult model =
    case sliderValuesResult of
        Ok sliderValues ->
            let
                sliders =
                    Array.toList model.sliders
                        |> List.map2 Slider.setValueIfNotDragging sliderValues

                updatedModel =
                    { model | sliders = Array.fromList sliders }
            in
                ( updatedModel, Cmd.none )

        -- ignore error and continue
        Err _ ->
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
        ( updatedModel, WebSocket.send websocketAddress json )



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
        Html.map (SliderMsg index) (Slider.renderSlider position aSliderModel)



-- Subscriptions


subscriptions : Model -> Sub Msg
subscriptions model =
    let
        subscriptions =
            Array.indexedMap subscriptionItem model.sliders

        subscriptionsList =
            Array.toList subscriptions

        serverUpdate =
            WebSocket.listen websocketAddress makeServerUpdate
    in
        Sub.batch (serverUpdate :: subscriptionsList)


makeServerUpdate : String -> Msg
makeServerUpdate json =
    let
        decodeResult =
            Decode.decodeString (Decode.field "sliders" (Decode.list Decode.int)) json
    in
        case decodeResult of
            Result.Ok values ->
                ServerUpdate (Ok values)

            Result.Err error ->
                ServerUpdate (Err (Debug.log "server update error" error))


subscriptionItem : Int -> Slider.Model -> Sub Msg
subscriptionItem index aSliderModel =
    Sub.map (SliderMsg index) (Slider.subscriptions aSliderModel)


slidersJson : List Int -> Encode.Value
slidersJson sliderValues =
    Encode.object
        [ ( "version", Encode.int 1 )
        , ( "sliders", (Encode.list (List.map Encode.int sliderValues)) )
        ]


slidersJsonString : List Int -> String
slidersJsonString sliderValues =
    Encode.encode 0 (slidersJson sliderValues)


topY : Int
topY =
    10


startX : Int
startX =
    10


websocketAddress : String
websocketAddress =
    "ws://localhost:8080"
