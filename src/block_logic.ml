open Constants
open Random

(* Block movement *)

(* Helper function that removes 0's within a list and returns the compressed
   list ex. compress [3; 3; 0; 3] -> [3; 3; 3]*)
let rec compress = function
  | [] -> []
  | 0 :: t -> compress t
  | h :: t -> h :: compress t

(* Helper function that combines equal numbers and shifts numbers to the left.
   Numbers on the left-most side receive priority. ex. l_merge [2; 2; 0; 2] ->
   [4; 2] *)
let rec l_merge = function
  | a :: b :: t when a = b ->
      let merged_list, score = l_merge t in
      ((a + b) :: merged_list, a + b + score)
  | a :: t ->
      let merged_list, score = l_merge t in
      (a :: merged_list, score)
  | [] -> ([], 0)

let r_merge lst =
  let reversed_lst = List.rev lst in
  let merged, score = l_merge reversed_lst in
  (List.rev merged, score)

(* Uses l_merge and compress to shift a row to the left to simulate a left
   button press in 2048. Populates rows w/ < num_squares entries w/ 0s to
   preserve the number of squares in a list. ex. l_move [2; 2; 0; 2] -> [4; 2;
   0; 0]*)
let l_move (row : int list) : int list * int =
  let compressed = compress row in
  let merged, score = l_merge compressed in
  let result = compress merged in
  (result @ List.init (List.length row - List.length result) (fun _ -> 0), score)

(* Uses r_merge and compress to shift a row to the right to simulate a right
   button press in 2048. Populates rows w/ < num_squares entries w/ 0s to
   preserve the number of squares in a list. ex. r_move [2; 2; 0; 2] -> [0; 0;
   2; 4]*)
let r_move (row : int list) : int list * int =
  let compressed = List.rev (compress row) in
  let merged, score = r_merge compressed in
  let result_length = List.length merged in
  let padded_result =
    List.init (List.length row - result_length) (fun _ -> 0) @ merged
  in
  (padded_result, score)

(* Helper function that transposes a matrix (list of lists) *)
let transpose matrix =
  match matrix with
  | [] -> []
  | [] :: _ -> []
  | _ ->
      let rec innerTranspose mat acc =
        if List.exists (fun x -> x <> []) mat then
          innerTranspose
            (List.map
               (function
                 | [] -> []
                 | h :: t -> t)
               mat)
            (List.map
               (function
                 | [] -> failwith "Invalid matrix"
                 | h :: t -> h)
               mat
            :: acc)
        else List.rev acc
      in
      innerTranspose matrix []

(* Helper function that moves a board up *)
let u_move (board : int list list) : int list list * int =
  let transposed_board = transpose board in
  let moved_board, scores = List.split (List.map l_move transposed_board) in
  (transpose moved_board, List.fold_left ( + ) 0 scores)

(* Helper function that moves a board down *)
let d_move (board : int list list) : int list list * int =
  let transposed_board = transpose board in
  let moved_board, scores = List.split (List.map r_move transposed_board) in
  (transpose moved_board, List.fold_left ( + ) 0 scores)

(* Shifts the 4x4 board left, right, up, or down depending on the input
   parameter. The board is expected as an int list list and the function returns
   the new board. ex. calculate_next [[2; 2; 0; 0]; [0; 0; 0; 0]; [4; 4; 8; 0];
   [0; 0; 2; 0]] move_left -> [[4; 0; 0; 0]; [0; 0; 0; 0]; [8; 8; 0; 0]; [2; 0;
   0; 0]]*)
let calculate_next (board : int list list) (dir : int) : int list list * int =
  match dir with
  | dir when dir = move_left ->
      let moved_board, scores = List.split (List.map l_move board) in
      (moved_board, List.fold_left ( + ) 0 scores)
  | dir when dir = move_right ->
      let moved_board, scores = List.split (List.map r_move board) in
      (moved_board, List.fold_left ( + ) 0 scores)
  | dir when dir = move_up ->
      let moved_board, scores = u_move board in
      (moved_board, scores)
  | dir when dir = move_down ->
      let moved_board, scores = d_move board in
      (moved_board, scores)
  | _ -> failwith "Invalid direction"

(*****************************************************************************)
(* Random block generation *)

let random_mag () =
  let rand = Random.int 10 in
  match rand with
  | _ when rand = 5 -> 4
  | _ -> 2

let find_zeros (board : int list list) : (int * int list) list =
  List.mapi
    (fun ind_1 a ->
      (ind_1, List.mapi (fun ind_2 b -> if b = 0 then ind_2 else -1) a))
    board

let count_empty (lst : (int * int list) list) : int =
  List.fold_left
    (fun acc (_, int_list) ->
      acc + List.length (List.filter (fun x -> x >= 0) int_list))
    0 lst

let generate_block board =
  Random.self_init ();
  let mag = random_mag () in
  let zero_lst = find_zeros board in
  let loc = Random.int (count_empty zero_lst) in
  let rec find_nth_empty n lst =
    match lst with
    | [] -> failwith "Error: Empty list"
    | (row, cols) :: t ->
        let valid_cols = List.filter (fun x -> x >= 0) cols in
        if n < List.length valid_cols then (row, List.nth valid_cols n)
        else find_nth_empty (n - List.length valid_cols) t
  in

  let target_row, target_col = find_nth_empty loc zero_lst in

  List.mapi
    (fun i row ->
      if i = target_row then
        List.mapi (fun j cell -> if j = target_col then mag else cell) row
      else row)
    board
