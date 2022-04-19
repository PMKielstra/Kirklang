open Spec;;

let print_val = function
        | String s -> print_string s
        | Float f -> print_float f
        | Closure _ -> print_string "<Closure>"
        | Function _ -> print_string "<Function>"
        | Undefined -> ()

class type variable =
object
    method close: bool
    method write: value -> unit
    method read: value
end

class book =
object
    method close = true
    val mutable content = Undefined
    method write (v: value) = content <- v
    method read = content
end;;

class shelf =
object
    method close = false
    val stack = Stack.create ()
    method write (v: value) = Stack.push v stack
    method read = Stack.pop stack
end;;

class ghost =
object
    method close = false
    method write = print_val
    method read = String (read_line ())
end;;

let rec last = function
| [x] -> x
| hd :: tl -> last tl
| [] -> Undefined

module Env =
struct
    type t = (string, variable) Hashtbl.t
    let make () = Hashtbl.create 10
    let add = Hashtbl.add
    let write (env: t) (name: string) = (Hashtbl.find env name)#write
    let close (env: t) =
        let fold_helper name var acc = if var#close then (name, var#read) :: acc else acc in
        Hashtbl.fold fold_helper env []
    let closure_find (s: string) (b: string * value) = (fst b) = s
    let read (c: closure) (env: t) (name: string) =
        match List.find_opt (closure_find name) c with
        | Some (_, v) -> v
        | None -> (Hashtbl.find env name)#read
end

let rec eval (c: closure) (env: Env.t) (e: expr): value =
    let newvar = function
    | Book -> new book
    | Shelf -> new shelf
    | Ghost -> new ghost
    in match e with
    | Imperative l -> List.iter (fun x -> ignore (eval c env x)) l; Undefined
    | Value v -> v
    | Variable s -> Env.read c env s
    | VariableDef (s, vtype, e) ->
      let v = newvar vtype in
      v#write (eval c env e);
      Env.add env s v;
      Undefined
    | Assignment (s, v) -> Env.write env s (eval c env v); Undefined
    | Brew expr -> Closure (Env.close env, expr)
    | Do expr -> (
        match eval c env expr with
        | Closure (c', expr') -> eval (c' @ c) env expr'
        | Function expr -> eval c env expr
        | _ -> failwith "Trying to do good without brewing good"
    )
    | If (condition, case1, case2) -> if (eval c env condition) = (Float 0.) then (eval c env case1) else (eval c env case2)
    | While (condition, body) -> while (eval c env condition) <> (Float 0.) do eval c env body |> ignore done; Undefined
    | Intrinsic (f, vars) -> f (List.map (eval c env) vars)
;;

let eval_section (sec: expr list) =
    let env = Env.make () in
    List.iter (fun x -> ignore (eval [] env x)) sec
;;
