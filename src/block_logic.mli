(** Block logic *)

(** This file handles block movement, random block generation, and block
    merging. *)

(* Block Movement + Merging *)

(* Removes 0's within an int list and returns the compressed list without 0's.
   ex. compress [3; 3; 0; 3] -> [3; 3; 3]*)
val compress : int list -> int list

(* Combines equal numbers and shifts numbers to the left. Numbers on the
   left-most side receive priority. ex. l_merge [2; 2; 0; 2] -> [4; 2] *)
val l_merge : int list -> int list * int

(* Combines equal numbers and shifts numbers to the right. Numbers on the
   right-most side receive priority. ex. l_merge [2; 2; 0; 2] -> [2; 4] *)
val r_merge : int list -> int list * int

(* Uses l_merge and compress to shift a row to the left to simulate a left
   button press in 2048. Populates rows w/ < num_squares entries w/ 0s to
   preserve the number of squares in a list. ex. l_move [2; 2; 0; 2] -> [4; 2;
   0; 0]*)
val l_move : int list -> int list * int

(* Uses r_merge and compress to shift a row to the right to simulate a right
   button press in 2048. Populates rows w/ < num_squares entries w/ 0s to
   preserve the number of squares in a list. ex. r_move [2; 2; 0; 2] -> [0; 0;
   2; 4]*)
val r_move : int list -> int list * int

(* Transposes a matrix (int list list) so that the columns become the rows. ex.
   transpose [[1;2;3;4];[5;6;7;8];[9;10;11;12];[13;14;15;16]] ->
   [[1;5;9;13];[2;6;10;14];[3;7;11;15];[4;8;12;16]] *)
val transpose : 'a list list -> 'a list list

(* Uses transpose and horizontal move functions to simulate an up button press
   in 2048. Populates rows w/ < num_squares entries w/ 0s to preserve the number
   of squares in a list. ex. u_move [[2;0;0;0];[2;0;0;0];[0;0;0;0];[0;0;0;0]] ->
   [[4;0;0;0];[0;0;0;0];[0;0;0;0];[0;0;0;0]]*)
val u_move : int list list -> int list list * int

(* Uses transpose and horizontal move functions to simulate an down button press
   in 2048. Populates rows w/ < num_squares entries w/ 0s to preserve the number
   of squares in a list. ex. u_move [[2;0;0;0];[2;0;0;0];[0;0;0;0];[0;0;0;0]] ->
   [[0;0;0;0];[0;0;0;0];[0;0;0;0];[4;0;0;0]]*)
val d_move : int list list -> int list list * int

(* Shifts the 4x4 board left, right, up, or down depending on the input
   parameter. The board is expected as an int list list and the function returns
   the new board. ex. calculate_next [[2; 2; 0; 0]; [0; 0; 0; 0]; [4; 4; 8; 0];
   [0; 0; 2; 0]] move_left -> [[4; 0; 0; 0]; [0; 0; 0; 0]; [8; 8; 0; 0]; [2; 0;
   0; 0]]*)
val calculate_next : int list list -> int -> int list list * int

(* Determines the magnitude of the randomly generated block by returning 4 or
   2*)
val random_mag : unit -> int

(* Finds the locations of the empty blocks (0's) within the board *)
val find_zeros : int list list -> (int * int list) list

(* Returns the number of empty blocks within the board *)
val count_empty : (int * int list) list -> int

(* Generates a random block within the board in a random location with a
   magnitude of either 4 or 2*)
val generate_block : int list list -> int list list

(* Generate an initial board that has two blocks (either 4 or 2) in a random
   location on the board*)
val generate_initial : int list list -> int list list
