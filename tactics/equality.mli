(************************************************************************)
(*         *      The Rocq Prover / The Rocq Development Team           *)
(*  v      *         Copyright INRIA, CNRS and contributors             *)
(* <O___,, * (see version control and CREDITS file for authors & dates) *)
(*   \VV/  **************************************************************)
(*    //   *    This file is distributed under the terms of the         *)
(*         *     GNU Lesser General Public License Version 2.1          *)
(*         *     (see LICENSE file for the text of the license)         *)
(************************************************************************)

(*i*)
open Names
open EConstr
open Ind_tables
open Locus
open Tactypes
open Tactics
(*i*)

type dep_proof_flag = bool (* true = support rewriting dependent proofs *)
type freeze_evars_flag = bool (* true = don't instantiate existing evars *)

type orientation = bool

type conditions =
  | Naive (* Only try the first occurrence of the lemma (default) *)
  | FirstSolved (* Use the first match whose side-conditions are solved *)
  | AllMatches (* Rewrite all matches whose side-conditions are solved *)

val eq_elimination_ref : orientation -> UnivGen.QualityOrSet.t -> GlobRef.t option

(* Equivalent to [general_rewrite l2r] *)
val rewriteLR : constr -> unit Proofview.tactic
val rewriteRL : constr  -> unit Proofview.tactic

(* Warning: old [general_rewrite_in] is now [general_rewrite_bindings_in] *)

val general_setoid_rewrite_clause :
  (Id.t option -> orientation -> occurrences -> constr with_bindings ->
   new_goals:constr list -> unit Proofview.tactic) Hook.t

val general_rewrite : where:Id.t option ->
  l2r:orientation -> occurrences -> freeze:freeze_evars_flag -> dep:dep_proof_flag -> with_evars:evars_flag ->
  ?tac:(unit Proofview.tactic * conditions) -> constr with_bindings -> unit Proofview.tactic

type multi =
  | Precisely of int
  | UpTo of int
  | RepeatStar
  | RepeatPlus

val general_multi_rewrite :
  evars_flag -> (bool * multi * clear_flag * delayed_open_constr_with_bindings) list ->
    clause -> (unit Proofview.tactic * conditions) option -> unit Proofview.tactic

val replace_in_clause_maybe_by : bool option -> constr -> constr -> clause -> unit Proofview.tactic option -> unit Proofview.tactic
val replace    : constr -> constr -> unit Proofview.tactic
val replace_by : constr -> constr -> unit Proofview.tactic -> unit Proofview.tactic

type inj_flags = {
    keep_proof_equalities : bool; (* One may want it or not *)
    injection_pattern_l2r_order : bool; (* Compatibility option: no reason not to want it *)
  }

val discr        : evars_flag -> constr with_bindings -> unit Proofview.tactic
val discrConcl   : unit Proofview.tactic
val discrHyp     : Id.t -> unit Proofview.tactic
val discrEverywhere : evars_flag -> unit Proofview.tactic
val discr_tac    : evars_flag ->
  constr with_bindings Tactics.destruction_arg option -> unit Proofview.tactic

(* Below, if flag is [None], it takes the value from the dynamic value of the option *)
exception NothingToInject
val inj          : inj_flags option -> ?injection_in_context:bool -> intro_patterns option -> evars_flag ->
  clear_flag -> constr with_bindings -> unit Proofview.tactic
val injClause    : inj_flags option -> ?injection_in_context:bool -> intro_patterns option -> evars_flag ->
  constr with_bindings Tactics.destruction_arg option -> unit Proofview.tactic
val injHyp       : inj_flags option -> ?injection_in_context:bool -> clear_flag -> Id.t -> unit Proofview.tactic
val injConcl     : inj_flags option -> ?injection_in_context:bool -> unit -> unit Proofview.tactic
val simpleInjClause : inj_flags option -> evars_flag ->
  constr with_bindings Tactics.destruction_arg option -> unit Proofview.tactic

val dEq : keep_proofs:(bool option) -> evars_flag -> constr with_bindings Tactics.destruction_arg option -> unit Proofview.tactic
val dEqThen : keep_proofs:(bool option) -> evars_flag -> (int -> unit Proofview.tactic) -> constr with_bindings Tactics.destruction_arg option -> unit Proofview.tactic

(* The family rewriteIn expect the proof of an equality *)
val rewriteInHyp : bool -> constr -> Id.t -> unit Proofview.tactic
val rewriteInConcl : bool -> constr -> unit Proofview.tactic

val set_keep_equality : Libobject.locality -> inductive -> bool -> unit

(* Subst *)

(* val unfold_body : Id.t -> tactic *)

type subst_tactic_flags = {
  only_leibniz : bool;
  rewrite_dependent_proof : bool
}
val subst_gen : bool -> Id.t list -> unit Proofview.tactic
val subst : Id.t list -> unit Proofview.tactic
val subst_all : ?flags:subst_tactic_flags -> unit -> unit Proofview.tactic

(* Replace term *)
(* [replace_term dir_opt c cl]
   performs replacement of [c] by the first value found in context
   (according to [dir] if given to get the rewrite direction)  in the clause [cl]
*)
val replace_term : bool option -> constr -> clause -> unit Proofview.tactic

val set_eq_dec_scheme_kind : mutual scheme_kind -> unit
