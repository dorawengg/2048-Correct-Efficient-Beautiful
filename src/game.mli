type game_state =
  | StartingPage
  | Game
  | InstructionsPage

val score : int ref
(** Reference to the current score in the game. *)

val high_score : int ref
(** Reference to the highest score achieved in the game. *)

val last_move_time : float ref
(** Reference to the timestamp of the last move in the game. *)

val board : Block_logic.block list list ref
(** Reference to the game board, represented as a list of blocks. *)

val setup : unit -> unit
(** Initializes the Raylib window with the specified size and frame rate. *)

val init_board : unit -> int array array
(** Initializes a placeholder game board represented as a 2D array. *)

val starting_page_logic : unit -> game_state
(** Handles the logic for the starting page, checking for key input to progress
    to instructions or the game state. Returns the next game state. *)

val check_home_page_button_click : game_state -> game_state
(** Checks for the home page button click and resets the board if clicked.
    Returns the next game state. *)

val check_new_game_button_click : unit -> unit
(** Handles the button click logic for the new game button. *)

val animate : float -> unit
(** Animates the game board based on the elapsed time. *)

val game_logic : float -> float -> game_state
(** Handles the game logic, checking for key input, button clicks, and updating
    the board. Returns the next game state. *)

val handle_move : float -> int -> unit
(** Handles the movement of the game board based on user input and updates the
    game state accordingly. *)

val instructions_logic : unit -> game_state
(** Handles the logic for the instruction page, checking for key input to return
    to the start page or begin the game. Returns the next game state. *)

val main_loop : float -> game_state -> unit
(** Main control loop of the game, executing different logic blocks based on the
    current game state. *)