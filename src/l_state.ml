open Raylib
open Color

let lose_state () =
  draw_text "You lost!" 170 200 40 Color.brown;
  draw_text "Press s to start a new game" 170 270 20 Color.beige
