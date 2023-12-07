open Raylib
open Color
open Board
open Block
open Constants
open Instructions
open Start
open Block_logic
open Tetris_logic

type game_state =
  | StartingPage
  | Game
  | InstructionsPage
  | Tetris

let score = ref 0
let high_score = ref 0
let last_move_time = ref 0.

(*Stores the data we are displaying for the board.*)
let board = ref (generate_initial ())
let tetris_board = ref (Array.init rows (fun _ -> Array.make columns 0))
let is_tetris_initialized = ref false

(* Initiates the RayLib window with window size and frame rate *)
let setup () =
  init_window screen_width screen_height "raylib [core] example - basic window";
  set_target_fps fps

(* Placeholder initialization *)
let init_board () = Array.make_matrix 5 4 0

(* Function to initialize the Tetris board *)
let init_tetris_board () =
  if not !is_tetris_initialized then begin
    tetris_board := init_board ();
    (* add_new_block_in_top_row !tetris_board; *)
    is_tetris_initialized := true
  end

(* Draws and implements the logic for the start page. Continuously checks for
   key input to progress to instructions or game state *)
let starting_page_logic () =
  begin_drawing ();
  clear_background Color.raywhite;
  starting_page ();
  let next_state =
    if is_key_pressed Key.I then InstructionsPage else StartingPage
  in
  end_drawing ();
  next_state

let check_home_page_button_click state =
  if Raylib.is_mouse_button_pressed MouseButton.Left then
    let mouse_x = Raylib.get_mouse_x () in
    let mouse_y = Raylib.get_mouse_y () in
    if
      mouse_x >= home_pos_x
      && mouse_x <= home_pos_x + home_width
      && mouse_y >= home_pos_y
      && mouse_y <= home_pos_y + home_height
    then (
      (* Reset the board *)
      board := generate_initial ();
      score := 0;
      Utils.write_to_file Constants.file_path (string_of_int !high_score);
      StartingPage)
    else state
  else state

(** Logic behind handling the button click for the new game button *)
let check_new_game_button_click () =
  (* If the mouse is over the button and the left mouse button is pressed *)
  if Raylib.is_mouse_button_pressed MouseButton.Left then (
    let mouse_x = Raylib.get_mouse_x () in
    let mouse_y = Raylib.get_mouse_y () in
    if
      mouse_x >= new_pos_x
      && mouse_x <= new_pos_x + new_width
      && mouse_y >= new_pos_y
      && mouse_y <= new_pos_y + new_height
    then (* Reset the board *)
      board := generate_initial ();
    score := 0;
    Utils.write_to_file Constants.file_path (string_of_int !high_score))

let animate delta_time =
  List.iter
    (fun row ->
      List.iter (fun block -> Block.update_block block delta_time) row)
    !board;

  display_tiles_input !board

let new_board tetris_board block =
  if Array.length tetris_board > 0 then tetris_board.(0) <- Array.of_list block

let tetris_game_logic () =
  begin_drawing ();
  clear_background Color.raywhite;
  tetris_page ();
  let next_state = check_home_page_button_click Tetris in
  (* Update the state based on button click *)
  check_new_game_button_click ();
  new_board !tetris_board (generate_random_block ());
  update_board !tetris_board;

  end_drawing ();
  next_state

(* Return the updated state *)
(* Maintain TetrisGame state or transition to others if needed *)

(*Check is button clicked to return to the homepage*)
(* let check_home_page_button_click () = if Raylib.is_mouse_button_pressed
   MouseButton.Left then let mouse_x = Raylib.get_mouse_x () in let mouse_y =
   Raylib.get_mouse_y () in if mouse_x >= 37 && mouse_x <= 37 + 184 && mouse_y
   >= 30 && mouse_y <= 30 + 56 then StartingPage else Game else Game *)

let new_board tetris_board block =
  if Array.length tetris_board > 0 then tetris_board.(0) <- Array.of_list block

let tetris_game_logic () =
  begin_drawing ();
  clear_background Color.raywhite;
  tetris_page ();
  let next_state = check_home_page_button_click Tetris in
  (* Update the state based on button click *)
  check_new_game_button_click ();
  new_board !tetris_board (generate_random_block ());
  update_board !tetris_board;

  end_drawing ();
  next_state

(* Return the updated state *)
(* Maintain TetrisGame state or transition to others if needed *)

(*Check is button clicked to return to the homepage*)
(* let check_home_page_button_click () = if Raylib.is_mouse_button_pressed
   MouseButton.Left then let mouse_x = Raylib.get_mouse_x () in let mouse_y =
   Raylib.get_mouse_y () in if mouse_x >= 37 && mouse_x <= 37 + 184 && mouse_y
   >= 30 && mouse_y <= 30 + 56 then StartingPage else Game else Game *)

(* Draws and implements the logic for the game page. Continuously checks for key
   input to reset the game *)
let rec game_logic current_time delta_time =
  begin_drawing ();
  clear_background Color.raywhite;
  game_page ();
  let next_state = check_home_page_button_click Game in
  check_new_game_button_click ();

  if !score > !high_score then high_score := !score
  else high_score := !high_score;
  if is_key_pressed Key.Left then handle_move current_time move_left
  else if is_key_pressed Key.Right then handle_move current_time move_right
  else if is_key_pressed Key.Up then handle_move current_time move_up
  else if is_key_pressed Key.Down then handle_move current_time move_down;
  animate delta_time;

  display_tiles_input !board;
  draw_text "Score " score_label_pos_x score_label_pos_y score_label_size
    Color.brown;
  draw_text (string_of_int !score) score_pos_x score_pos_y score_size
    Color.beige;
  draw_text "High Score " hs_label_pos_x hs_label_pos_y hs_label_size
    Color.brown;
  draw_text (string_of_int !high_score) hs_pos_x hs_pos_y hs_size Color.beige;

  end_drawing ();
  next_state

and handle_move current_time dir =
  if current_time -. !last_move_time > Constants.move_cooldown then (
    last_move_time := current_time;
    let new_board, score_delta = calculate_next !board dir in
    if new_board = !board then (
      score := !score + score_delta;
      board := new_board)
    else
      let final_board = generate_block new_board in
      score := !score + score_delta;
      board := final_board)
  else ()

(* Draws and implements the logic for the instruction page. Continuously checks
   for key input to return to start page or begin the game *)
let instructions_logic () =
  begin_drawing ();
  clear_background Color.raywhite;
  instructions ();
  let next_state =
    if is_key_pressed Key.Escape then StartingPage
    else if is_key_pressed Key.O then Game
    else if is_key_pressed Key.T then Tetris
    else InstructionsPage
  in
  end_drawing ();
  next_state

(* Main control loop of the game. Depending on the state of the game, a
   different logic block is executed *)
let rec main_loop last_time state =
  let open Unix in
  let current_time = gettimeofday () in
  let delta_time = current_time -. last_time in
  if Raylib.window_should_close () then Raylib.close_window ()
  else
    let next_state =
      match state with
      | StartingPage -> starting_page_logic ()
      | Game -> game_logic current_time delta_time
      | InstructionsPage -> instructions_logic ()
      | Tetris -> tetris_game_logic ()
    in
    let frame_end_time = gettimeofday () in
    let frame_duration = frame_end_time -. current_time in
    let frame_target = 1.0 /. float_of_int fps in
    let sleep_duration = max 0.0 (frame_target -. frame_duration) in
    ignore (select [] [] [] sleep_duration);

    main_loop current_time next_state

let () = setup ()
(* start the main loop with the StartingPage state *)
