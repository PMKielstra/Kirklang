open Spec ;;
open Intrinsics ;;
open Genlex ;;

type supertoken =
| Kwd of string
| Ident of string
| Float of float
| String of string
| Chunk of supertoken list
;;

let rec print_supertoken = fun k -> match k with
| Kwd s -> print_string ("Kwd " ^ s)
| Ident s -> print_string ("Ident " ^ s)
| Float f -> print_string "Float "; print_float f
| String s -> print_string ("String " ^ s)
| Chunk l -> print_string "["; print_supertoken_list l; print_string "]"
and print_supertoken_list (l) = List.iter print_supertoken l

let split_list (delimiter: 'a) =
    let rec split_list_helper current_list lists = function
    | [] -> lists @ [current_list]
    | x :: tl when x = delimiter -> split_list_helper [] (lists @ [current_list]) tl
    | hd :: tl -> split_list_helper (current_list @ [hd]) lists tl
    in split_list_helper [] []
;;

let preparse (l: token list): supertoken list =
    let l_mut = ref l in
    let rec preparse_helper (acc: supertoken list): supertoken list =
        match !l_mut with
        | [] -> acc
        | hd :: tl ->
            l_mut := tl;
            if hd = Kwd ")" then
                acc
            else
                acc @ [(match hd with
                | Kwd "(" -> Chunk (preparse_helper [])
                | Kwd k -> Kwd k
                | String s -> String s
                | Ident i -> Ident i
                | Int i -> Float (float_of_int i)
                | Float f -> Float f
                | Char c -> String (String.make 1 c))] |> preparse_helper
    in preparse_helper []
;;

let vartype = function
    | "book" -> Book
    | "shelf" -> Shelf
    | "ghost" -> Ghost
    | _ -> failwith "Bad variable type"

let rec parse: supertoken list -> expr = function
    | Kwd "imp" :: tl -> Imperative (List.map (fun x -> parse [x]) tl);
    | [Chunk l] -> parse l
    | [Float f] -> Value (Float f)
    | [String s] -> Value (String s)
    | [Ident i] -> Variable i
    | [Kwd b; Ident i] when b = "book" || b = "shelf" || b = "ghost" ->
        VariableDef (i, vartype b, Value Undefined)
    | Kwd b :: Ident i :: Kwd "=" :: tl when b = "book" || b = "shelf" || b = "ghost" ->
        VariableDef (i, vartype b, parse tl)
    | Ident i :: Kwd "=" :: tl -> Assignment (i, parse tl);
    | Kwd "brew" :: tl -> Brew (parse tl)
    | Kwd "do" :: tl -> Do (parse tl)
    | [Kwd "if"; cond; c1; c2] -> If (parse [cond], parse [c1], parse [c2])
    | [Kwd "while"; cond; body] -> While (parse [cond], parse [body])
    | Kwd "fun" :: tl -> Value (Function (parse tl))
    | Ident i :: tl -> intrinsic i tl
    | [] -> Value Undefined
    | _ -> failwith "Syntax error"

and intrinsic i tl =
    match intrinsic_opt i with
    | Some (_, f) -> Intrinsic (f, List.map (fun x -> parse [x]) tl)
    | None -> failwith ("No intrinsic found with name " ^ i ^ ".")
;;

let lexer = make_lexer keywords ;;

let list_of_stream stream =
    let result = ref [] in
    Stream.iter (fun value -> result := value :: !result) stream;
    List.rev !result

let parse_section (text: string) =
    lexer (Stream.of_string text)
    |> list_of_stream
    |> preparse
    |> split_list (Kwd ";")
    |> List.map parse