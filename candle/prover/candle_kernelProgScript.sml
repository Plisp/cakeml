(*
  Adds Candle specific functions to the kernel module from ml_hol_kernel_funsProg
*)
open preamble;
open ml_translatorLib ml_monad_translatorLib ml_progLib ml_hol_kernel_funsProgTheory;
open basisFunctionsLib print_thmTheory;
open (* lisp: *) lisp_parsingTheory lisp_valuesTheory lisp_printingTheory;
open (* compute: *) computeSyntaxTheory computeTheory computePmatchTheory;
open runtime_checkTheory runtime_checkLib;

val _ = new_theory "candle_kernelProg";

val _ = set_grammar_ancestry ["ml_hol_kernel_funsProg"];

val _ = m_translation_extends "ml_hol_kernel_funsProg"

val _ = (use_long_names := false);

val _ = ml_prog_update open_local_block;

val r = translate lisp_valuesTheory.name_def;
val r = translate lisp_printingTheory.num2ascii_def;
val r = translate lisp_printingTheory.ascii_name_def;

val lemma = prove(“ascii_name_side v3”,
  fs [fetch "-" "ascii_name_side_def"]
  \\ fs [Once lisp_printingTheory.num2ascii_def,AllCaseEqs()])
  |> update_precondition;

val r = translate num2str_def;

val lemma = prove(“∀n. num2str_side n”,
  ho_match_mp_tac lisp_printingTheory.num2str_ind
  \\ rw [] \\ simp [Once (fetch "-" "num2str_side_def")]
  \\ rw [] \\ gvs [DIV_LT_X]
  \\ ‘n MOD 10 < 10’ by fs []
  \\ decide_tac)
  |> update_precondition;

val r = translate lisp_printingTheory.name2str_def;
val r = translate lisp_valuesTheory.list_def;
val r = translate nil_list_def;
val r = translate str_to_v_def;
val r = translate ty_to_v_def;
val r = translate term_to_v_def;
val r = translate thm_to_v_def;
val r = translate update_to_v_def;
val r = translate dest_quote_def;
val r = translate dest_list_def;
val r = translate newlines_def;
val r = translate v2pretty_def;
val r = translate get_size_def;
val r = translate get_next_size_def;
val r = translate annotate_def;
val r = translate remove_all_def;
val r = translate smart_remove_def;
val r = translate flatten_def;
val r = translate dropWhile_def;
val r = translate is_comment_def;
val r = translate v2str_def;
val r = translate vs2str_def;
val r = translate thm_to_string_def;

val _ = ml_prog_update open_local_in_block;

val _ = (append_prog o process_topdecs) `
  val print_thm = fn th => case th of Sequent tms c =>
    let
      val ctxt = !the_context
      val str = thm_to_string ctxt th
      val arr = Word8Array.array 0 (Word8.fromInt 0)
    in
      #(kernel_ffi) str arr
    end;
`
(* compute primitive *)

val _ = ml_prog_update open_local_block;

val r = translate dest_num_def;          (* TODO dest_num_PMATCH         *)
val r = m_translate dest_numeral_def;    (* TODO dest_numeral_PMATCH     *)
val r = translate dest_numeral_opt_def;  (* TODO dest_numeral_opt_PMATCH *)
val r = translate dest_cval_def;         (* TODO dest_cval_PMATCH        *)

val r = compute_thms_def |> EVAL_RULE |> translate;

val r = m_translate dest_binary_PMATCH;
val r = translate num2bit_def;

val _ = use_mem_intro := true;
val r = check [‘ths’] compute_init_def |> translate;
val _ = use_mem_intro := false;

val r = translate cval2term_def;
val r = translate compute_eval_def;

val _ = ml_prog_update open_local_in_block;

val r = check [‘ths’,‘tm’] compute_add_def |> m_translate;
val r = check [‘ths’,‘tm’] compute_def |> m_translate;

val _ = ml_prog_update close_local_blocks;
val _ = ml_prog_update (close_module NONE);

(* extract the interesting theorem *)

val _ = Globals.max_print_depth := 10;

fun define_abbrev_conv name tm = let
  val def = define_abbrev true name tm
  in GSYM def |> SPEC_ALL end

Theorem candle_prog_thm =
  get_Decls_thm (get_ml_prog_state())
  |> CONV_RULE ((RATOR_CONV o RATOR_CONV o RAND_CONV)
                (EVAL THENC define_abbrev_conv "candle_code"))
  |> CONV_RULE ((RATOR_CONV o RAND_CONV)
                (EVAL THENC define_abbrev_conv "candle_init_env"))
  |> CONV_RULE ((RAND_CONV)
                (EVAL THENC define_abbrev_conv "candle_init_state"));

(* extract some other other theorems *)

Theorem EqualityType_TYPE_TYPE = EqualityType_rule [] “:type”;

Theorem EqualityType_TERM_TYPE = EqualityType_rule [] “:term”;

Theorem EqualityType_THM_TYPE = EqualityType_rule [] “:thm”;

Theorem EqualityType_UPDATE_TYPE = EqualityType_rule [] “:update”;

val _ = (print_asts := true);

val _ = export_theory();
