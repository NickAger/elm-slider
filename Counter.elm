module Counter exposing (Msg, MsgToParent (..), Model, model, update, view)

import Html exposing (Html, button, span, div, text)
--import Html.App as Html
import Html.Events exposing (onClick)


{- main : Program Never
main =
  Html.beginnerProgram { model = model, view = view, update = update }
 -}

-- MODEL

type alias Model = Int

model : number
model = 0


-- UPDATE

type Msg = Increment | Decrement | Notify MsgToParent

type MsgToParent = Remove | MoveUp | MoveDown

update : Msg -> Model -> (Model, Maybe MsgToParent)
update msg model =
  case msg of
    Increment ->
      ( model + 1, Nothing )

    Decrement ->
      ( model - 1, Nothing )

    Notify msgToParent ->
      ( model, Just msgToParent )


-- VIEW

view : Model -> Html Msg
view model =
  div []
    [ button [ onClick Decrement ] [ text "-" ]
    , span [] [ text (toString model) ]
    , button [ onClick Increment ] [ text "+" ]
    , span [] [text " | "]
    , button [onClick (Notify Remove)] [text "Remove"]
    , button [onClick (Notify MoveDown)] [text "MoveDown"]
    , button [onClick (Notify MoveUp)] [text "MoveUp"]
    ]
