open Spec ;;

let float_add l = Float (List.fold_left (fun acc (Float a) -> acc +. a) 0. l) ;;
let float_sub = function
| [Float a; Float b] -> Float (a -. b)
| _ -> failwith "Cannot subtract more than two elements at a time"
let float_mul l = Float (List.fold_left (fun  acc (Float a) -> acc *. a) 1. l) ;;
let float_div = function
| [Float a; Float b] -> Float (a /. b)
| _ -> failwith "Cannot divide more than two elements at a time"
let float_mod = function
| [Float a; Float b] -> Float (float_of_int ((int_of_float a) mod (int_of_float b)))
| _ -> failwith "Cannot mod more than two elements at a time"
let str_concat l = String (List.fold_left (fun acc (String s) -> acc ^ s) "" l) ;;

let intrinsic_opt i = List.find_opt (fun x -> (fst x) = i) [
    "add", float_add;
    "sub", float_sub;
    "mul", float_mul;
    "div", float_div;
    "mod", float_mod;
    "concat", str_concat;
]