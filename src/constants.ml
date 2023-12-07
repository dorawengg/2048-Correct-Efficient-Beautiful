(* Screen dimensions *)
let screen_width = 800
let screen_height = 600
let num_squares = 4
let square_size = 80
let spacing = 7

(* Control constants *)
let move_left = 0
let move_right = 1
let move_up = 2
let move_down = 3

(* High score *)
let file_path = "data/high_score.json"

(* Audio *)
let block_move_sound = Raylib.load_music_stream "resources/block.mp3"
let button_click_sound = Raylib.load_music_stream "resources/button.mp3"