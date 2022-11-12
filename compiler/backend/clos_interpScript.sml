(*
  Implementation of interpreter for closLang expressions written in closLang.
*)
open preamble closLangTheory backend_commonTheory;

val _ = new_theory "clos_interp";

val _ = set_grammar_ancestry ["closLang", "backend_common"];

Definition clos_interpreter_def:
  clos_interpreter = Op None (Cons 0) [] (* TODO: implement *)
End

(*

Definition compile_inc_def:
  ...
End

*)

val _ = export_theory();
