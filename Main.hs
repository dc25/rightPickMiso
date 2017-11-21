{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards #-}

import Data.Map
import Debug.Trace

import Miso
import Miso.Event.Decoder
import Miso.String        
import Miso.Svg as MSV

onRightClick :: msg -> Attribute msg
onRightClick message =
    onWithOptions
        Options { preventDefault = True, stopPropagation = True }
        "contextmenu"
        emptyDecoder
        (const message)

data Msg = Pick Int | Init deriving Show

type Board = [Int]

w =  3
cellSize = 60

showCell :: Int -> View Msg
showCell index = 
    let scale = "scale (" ++ show cellSize ++ ", " ++ show cellSize ++ ") " 
        translation = "translate (" ++ show index ++ ", 0)"
    in g_ [ transform_ (ms $ scale ++ translation) ]
          [ circle_ [ cx_ "0.5"
                    , cy_ "0.5"
                    , r_ "0.4"
                    , fill_ "blue"
                    , onClick (Pick index)
                    , onRightClick (Pick index)
                    ] 
                    []
          ]

viewBoard :: Board -> View Msg
viewBoard board = 
    svg_ [ version_ "1.1"
         , MSV.width_ (ms $ show (w * cellSize))
         , MSV.height_ (ms $ show cellSize)
         ]
         (fmap showCell board)

updateBoard :: Msg -> Board -> Effect Msg Board
updateBoard msg board = 
    case trace (show msg) msg of
        Init -> noEff board
        _ -> noEff board

main :: IO ()
main = do
    let
        initialAction = Init
        model         = [0..w-1]
        update        = updateBoard
        view          = viewBoard
        events        = Data.Map.insert "contextmenu" False defaultEvents
        subs          = [ ]
    startApp App {..}
