
import Graphics.Element exposing (down, flow, leftAligned)
import List exposing (map)
import Mouse
import Signal exposing (sampleOn)
import Text exposing (fromString)

showsignals : MouseInfo -> Graphics.Element.Element
showsignals info =
    flow down <|
        map (fromString >> leftAligned) [
                "Info: " ++ toString info
              , "position.x " ++ toString info.position.x
            ]

type alias Position = {
  x : Int,
  y : Int
}

type alias MouseInfo = {
  position : Position,
  downPosition : Position,
  isDown : Bool
}

toPosition : (Int, Int) -> Position
toPosition (x, y) = { x = x, y = y }

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
    toMouseInfo position mouseDownPosition isDown =
      { position = toPosition position
      , downPosition = mouseDownPosition
      , isDown = isDown
     }
  in
    Signal.map3 toMouseInfo Mouse.position mouseDownPosition Mouse.isDown

main : Signal Graphics.Element.Element
main =
    Signal.map showsignals mouseInfoSignal
