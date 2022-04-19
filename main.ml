open Parse ;;
open Eval ;;

let readin (directory: string) (filename: string): (string * string) list =
    let current_section = ref "" in
    let current_code = ref "" in
    let result = ref [] in
    let channel = open_in (Filename.concat directory filename) in
    try
        while true do
            let line = input_line channel in
            if String.starts_with ~prefix:"SECTION " line then
            begin
                result := (!current_section, !current_code) :: !result;
                current_code := "";
                current_section := String.sub line 8 (String.length line - 8)
            end
            else
                current_code := !current_code ^ " " ^ line
        done; List.rev !result
    with End_of_file ->
        result := (!current_section, !current_code) :: !result; close_in channel; List.rev !result
;;

let rec interleave (generic: (string * string) list) (week: (string * string) list): string =
    match generic with
    | [] -> ""
    | (sec, code) :: tl -> (
        match List.find_opt (fun (s, _) -> s = sec) week with
        | Some (_, c) -> c
        | None -> ""
    ) ^ " " ^ code ^ " " ^ interleave tl week
;;

let _ = Random.self_init () ;;
let random_from_list l = List.nth l (Random.int (List.length l)) ;;

let main () =
    if Array.length Sys.argv <= 1 then
        failwith "Please provide the address of a folder."
    else
        let files = Sys.readdir (Sys.argv.(1))
            |> Array.to_list
            |> List.filter (fun x -> Filename.extension x = ".kds") in
        (if List.mem "generic.kds" files && List.length files > 1 then
        begin
            List.filter ((<>) "generic.kds") files
            |> random_from_list
            |> readin Sys.argv.(1)
            |> interleave (readin Sys.argv.(1) "generic.kds")
        end
        else
        begin
            random_from_list files
            |> readin Sys.argv.(1)
            |> List.fold_left (fun acc (_, c) -> acc ^ " " ^ c) ""
        end)
        |> parse_section
        |> eval_section
;;
        
let _ = main () ;;