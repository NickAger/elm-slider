module CounterList exposing (..)

import Html exposing (Html, button, div, text, h1)
import Html.App as Html
import Html.Events exposing (onClick)
import List
import Dict exposing (Dict)
import Counter
import Maybe



main : Program Never
main =
  Html.beginnerProgram { model = initialModel, view = view, update = update }


-- MODEL

type alias Model =
  { counters : Dict CounterId Counter.Model
  , nextCounterId : CounterId
  }

type alias CounterId = Int


initialModel : Model
initialModel =
  Model Dict.empty 0



-- UPDATE

type Msg
  = Remove CounterId
  | Add
  | CounterMsg CounterId Counter.Msg



update : Msg -> Model -> Model
update msg model =
  case msg of
    Remove id ->
      { model | counters = Dict.remove id model.counters }

    Add ->
      { model | nextCounterId = model.nextCounterId + 1
              , counters = Dict.insert model.nextCounterId Counter.model  model.counters
      }

    CounterMsg counterId counterAction ->
      let
        res =
          Dict.get counterId model.counters
            |> Maybe.map (Counter.update counterAction)
      in
        case res of
          Just (counterMdl, Nothing ) ->
            { model | counters = Dict.insert counterId counterMdl model.counters }

          Just (counterMdl, Just counterNotification ) ->
            case counterNotification of
              Counter.Remove ->
                update (Remove counterId) model

              Counter.MoveUp ->
                {model | counters = shiftLeft counterId model.counters}

              Counter.MoveDown ->
                {model | counters = shiftRight counterId model.counters}

          Nothing ->
            model


shiftLeft : CounterId -> Dict CounterId Counter.Model -> Dict CounterId Counter.Model
shiftLeft id counters =
  let
    shift lst =
      case lst of
        ( a, b ) :: ( c, d ) :: r ->
          if c == id then
            ( a, d ) :: shift (( c, b ) :: r)
          else
            ( a, b ) :: shift (( c, d ) :: r)

        ( a, b ) :: [] ->
          [ ( a, b ) ]

        [] ->
          []
  in
    shift (Dict.toList counters) |> Dict.fromList


shiftRight : CounterId -> Dict CounterId Counter.Model -> Dict CounterId Counter.Model
shiftRight id counters =
  let
    shift lst =
      case lst of
        ( a, b ) :: ( c, d ) :: r ->
          if a == id then
            ( c, b ) :: shift (( a, d ) :: r)
          else
            ( a, b ) :: shift (( c, d ) :: r)

        ( a, b ) :: [] ->
          [ ( a, b ) ]

        [] ->
          []
  in
    shift (Dict.toList counters) |> Dict.fromList


-- VIEW


view : Model -> Html Msg
view model =
  let
    counters =
      model.counters |> Dict.toList |> List.map counterView
  in
    div
      []
      ([ h1 [] [text "List of counters"]]
                ++ counters
                ++ [div [] []]
                ++ [button [ onClick Add] [text "Add counter"]])


counterView : (CounterId, Counter.Model) -> Html Msg
counterView (id, mdl) =
  Html.map (CounterMsg id) (Counter.view mdl)
