# OCaml Patterns

## Algebraic Data Types and Pattern Matching

```ocaml
(* Sum types for domain modeling *)
type shape =
  | Circle of float
  | Rectangle of float * float
  | Triangle of { a : float; b : float; c : float }

let area = function
  | Circle r -> Float.pi *. r *. r
  | Rectangle (w, h) -> w *. h
  | Triangle { a; b; c } ->
    let s = (a +. b +. c) /. 2.0 in
    Float.sqrt (s *. (s -. a) *. (s -. b) *. (s -. c))

(* Pattern matching with guards *)
let classify_age = function
  | n when n < 0 -> Error "Invalid age"
  | n when n < 13 -> Ok "child"
  | n when n < 20 -> Ok "teenager"
  | _ -> Ok "adult"

(* Exhaustive matching — compiler warns on missing cases *)
type payment = Cash | Card of string | Crypto of { chain : string; addr : string }

let process_payment = function
  | Cash -> print_endline "Cash payment"
  | Card num -> Printf.printf "Card ending %s\n" (String.sub num (String.length num - 4) 4)
  | Crypto { chain; addr } -> Printf.printf "Crypto on %s to %s\n" chain addr
```

## Modules and Functors

```ocaml
(* Module signature — defines the public API *)
module type CACHE = sig
  type key
  type 'a t
  val create : int -> 'a t
  val get : 'a t -> key -> 'a option
  val set : 'a t -> key -> 'a -> unit
end

(* Functor — parameterized module *)
module MakeCache (K : Hashtbl.HashedType) : CACHE with type key = K.t = struct
  type key = K.t
  type 'a t = { tbl : (key, 'a) Hashtbl.t; cap : int }
  let create cap = { tbl = Hashtbl.create cap; cap }
  let get c k = Hashtbl.find_opt c.tbl k
  let set c k v =
    if Hashtbl.length c.tbl >= c.cap then Hashtbl.clear c.tbl;
    Hashtbl.replace c.tbl k v
end

(* First-class modules — pass modules as values *)
let pick_cache (type k) (module C : CACHE with type key = k) size =
  C.create size
```

## GADTs (Generalized Algebraic Data Types)

```ocaml
type _ expr =
  | Int : int -> int expr
  | Bool : bool -> bool expr
  | Add : int expr * int expr -> int expr
  | If : bool expr * 'a expr * 'a expr -> 'a expr

let rec eval : type a. a expr -> a = function
  | Int n -> n
  | Bool b -> b
  | Add (x, y) -> eval x + eval y
  | If (cond, t, f) -> if eval cond then eval t else eval f

(* Type-safe: eval (Add (Int 1, Int 2)) = 3 *)
(* Rejected at compile time: Add (Int 1, Bool true) *)
```

## Error Handling with Result

```ocaml
(* Result type for recoverable errors *)
type app_error = Not_found of string | Parse_error of string | Unauthorized

let parse_int s =
  match int_of_string_opt s with
  | Some n -> Ok n
  | None -> Error (Parse_error (Printf.sprintf "Not an integer: %s" s))

(* Chaining with Result.bind or let* *)
let ( let* ) = Result.bind

let process_order order_id_str =
  let* id = parse_int order_id_str in
  let* order = find_order id in
  let* _ = validate_stock order in
  Ok (confirm order)
```

## Effects (OCaml 5 Multicore)

```ocaml
(* Effect handlers for algebraic effects — OCaml 5+ *)
open Effect
open Effect.Deep

type _ Effect.t +=
  | Log : string -> unit Effect.t
  | Ask : string -> string Effect.t

let program () =
  perform (Log "Starting");
  let name = perform (Ask "What is your name?") in
  perform (Log ("Hello, " ^ name))

let run_with_handlers () =
  match_with program ()
    { retc = Fun.id
    ; exnc = raise
    ; effc = fun (type a) (eff : a Effect.t) ->
        match eff with
        | Log msg -> Some (fun (k : (a, _) continuation) ->
            Printf.printf "[LOG] %s\n" msg; continue k ())
        | Ask prompt -> Some (fun (k : (a, _) continuation) ->
            Printf.printf "%s> " prompt; continue k (read_line ()))
        | _ -> None }
```

## Concurrency: Lwt and Domains

```ocaml
(* Lwt — lightweight cooperative threads *)
open Lwt.Syntax

let fetch_both url1 url2 =
  let* resp1 = Http.get url1
  and* resp2 = Http.get url2 in
  Lwt.return (resp1, resp2)

(* Domain-based parallelism — OCaml 5 *)
let parallel_map f lst =
  let domains = List.map (fun x -> Domain.spawn (fun () -> f x)) lst in
  List.map Domain.join domains

(* Mutex for shared mutable state *)
let counter = Atomic.make 0

let increment () = Atomic.fetch_and_add counter 1
```

## Performance: Unboxed Types and Memory Layout

```ocaml
(* Unboxed records — no allocation overhead *)
type point = { x : float; y : float } [@@unboxed]

(* Use arrays for cache-friendly data *)
let sum_floats arr =
  let len = Array.length arr in
  let rec go acc i =
    if i >= len then acc
    else go (acc +. Array.unsafe_get arr i) (i + 1)
  in
  go 0.0 0

(* Avoid polymorphic comparison — use type-specific compare *)
let compare_strings (a : string) (b : string) = String.compare a b
(* NOT: let compare_strings a b = compare a b *)
```

## Testing with Alcotest

```ocaml
let test_area () =
  Alcotest.(check (float 0.001)) "circle area"
    (Float.pi *. 4.0) (area (Circle 2.0));
  Alcotest.(check (float 0.001)) "rectangle area"
    12.0 (area (Rectangle (3.0, 4.0)))

let () =
  Alcotest.run "shapes" [
    "area", [
      Alcotest.test_case "basic shapes" `Quick test_area;
    ];
  ]
```
