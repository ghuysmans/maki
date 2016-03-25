

(* This file is free software. See file "license" for more details. *)

(** {1 On-Disk Storage} *)

type 'a or_error = ('a, string) Result.result
type path = string

type t = {
  name: string;
  get: string -> string option or_error Lwt.t;
  set: string -> string -> unit or_error Lwt.t;
  iter: ?preload:int -> unit -> (string * string, [`r]) Maki_pipe.t;
  flush_cache: unit -> unit;
}

exception Storage_error of string

val get : t -> string -> string option or_error Lwt.t
(** [get t k] obtains the value for [k] in [t] *)

val get_exn : t -> string -> string option Lwt.t
(** @raise Storage_error in case of failure *)

val find : t -> string -> string Lwt.t
(** @raise Storage_error in case of failure
    @raise Not_found if key could not be found *)

val set : t -> string -> string -> unit or_error Lwt.t
(** [set t k v] puts the pair [k -> v] in [t] *)

val set_exn : t -> string -> string -> unit Lwt.t

val iter : ?preload:int -> t -> (string * string, [`r]) Maki_pipe.t
(** [iter t] iterates over all the pairs [key, value] in [t].
    @param preload number of entries that are loaded in advance, before
     they are pushed into the pipe *)

val flush_cache : t -> unit
(** Flush in-process cache, if any *)

val default : ?dir:path -> unit -> t Lwt.t
(** [default ?dir ()] creates a new default storage (one file per pair)
    @param dir if provided, set the directory used for storing files
      if [dir] is not set, then the current directory is used, unless the
        environment variable "MAKI_DIR" is set
    @raise Unix.Error in case of error, if it could not create [dir] properly *)

val set_default : t -> unit
(** Change the storage that is used to evaluate every Maki function *)

val get_default : unit -> t