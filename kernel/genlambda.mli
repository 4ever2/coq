(************************************************************************)
(*         *   The Coq Proof Assistant / The Coq Development Team       *)
(*  v      *         Copyright INRIA, CNRS and contributors             *)
(* <O___,, * (see version control and CREDITS file for authors & dates) *)
(*   \VV/  **************************************************************)
(*    //   *    This file is distributed under the terms of the         *)
(*         *     GNU Lesser General Public License Version 2.1          *)
(*         *     (see LICENSE file for the text of the license)         *)
(************************************************************************)

(** Intermediate language used by both the VM and native. *)

open Names
open Constr

type reloc_table = (int * int) array

type case_annot = case_info * reloc_table * Declarations.recursivity_kind

type 'v lambda =
| Lrel          of Name.t * int
| Lvar          of Id.t
| Lmeta         of metavariable * 'v lambda (* type *)
| Levar         of Evar.t * 'v lambda array (* arguments *)
| Lprod         of 'v lambda * 'v lambda
| Llam          of Name.t Context.binder_annot array * 'v lambda
| Llet          of Name.t Context.binder_annot * 'v lambda * 'v lambda
| Lapp          of 'v lambda * 'v lambda array
| Lconst        of pconstant
| Lproj         of Projection.Repr.t * 'v lambda
| Lprim         of pconstant * CPrimitives.t * 'v lambda array
| Lcase         of case_annot * 'v lambda * 'v lambda * 'v lam_branches
  (* annotations, term being matched, accu, branches *)
| Lfix          of (int array * inductive array * int) * 'v fix_decl
| Lcofix        of int * 'v fix_decl
| Lint          of int
| Lparray       of 'v lambda array * 'v lambda
| Lmakeblock    of inductive * int * 'v lambda array
  (* inductive name, constructor tag, arguments *)
| Luint         of Uint63.t
| Lfloat        of Float64.t
| Lval          of 'v
| Lsort         of Sorts.t
| Lind          of pinductive
| Lforce

and 'v lam_branches =
  { constant_branches : 'v lambda array;
    nonconstant_branches : (Name.t Context.binder_annot array * 'v lambda) array }

and 'v fix_decl = Name.t Context.binder_annot array * 'v lambda array * 'v lambda array

type evars =
    { evars_val : constr evar_handler;
      evars_metas : metavariable -> types }

val empty_evars : evars

(** {5 Manipulation functions} *)

val mkLapp : 'v lambda -> 'v lambda array -> 'v lambda
val mkLlam : Name.t Context.binder_annot array -> 'v lambda -> 'v lambda
val decompose_Llam : 'v lambda -> Name.t Context.binder_annot array * 'v lambda
val decompose_Llam_Llet : 'v lambda -> (Name.t Context.binder_annot * 'v lambda option) array * 'v lambda

val map_lam_with_binders : (int -> 'a -> 'a) -> ('a -> 'v lambda -> 'v lambda) ->
  'a -> 'v lambda -> 'v lambda

(* {5 Lift and substitution} *)

val lam_exlift : Esubst.lift -> 'v lambda -> 'v lambda
val lam_lift : int -> 'v lambda -> 'v lambda
val lam_subst_rel : 'v lambda -> Name.t -> int -> 'v lambda Esubst.subs -> 'v lambda
val lam_exsubst : 'v lambda Esubst.subs -> 'v lambda -> 'v lambda
val lam_subst_args : 'v lambda Esubst.subs -> 'v lambda array -> 'v lambda array

(* {5 Simplification} *)

val simplify : ('v lambda -> bool) -> 'v lambda Esubst.subs -> 'v lambda -> 'v lambda

(** {5 Printing} *)

val pp_lam : 'v lambda -> Pp.t
