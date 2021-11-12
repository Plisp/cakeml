(*
  Correctness proof for clos_op
*)

open preamble;
open closLangTheory closSemTheory closPropsTheory clos_opTheory;

val _ = new_theory "clos_opProof";

val _ = set_grammar_ancestry ["closLang", "closSem", "closProps", "clos_op"];

Triviality list_split3:
  ∀P. P [] ∧ (∀x y z zs. P (x::y::z::zs)) ∧ (∀x. P [x]) ∧ (∀x y. P [x; y]) ⇒
      ∀xs. P xs
Proof
  rw[] \\ Cases_on ‘xs’ \\ fs [] \\ Cases_on ‘t’ \\ fs [] \\ Cases_on ‘t'’ \\ fs []
QED

Triviality evaluate_MakeBool:
  ∀b. evaluate ([MakeBool b],vs,s) = (Rval [Boolv b],s)
Proof
  Cases \\ EVAL_TAC
QED

Theorem dest_Op_thm:
  dest_Op f x = SOME (i,ys) ⇔
  ∃tra y. x = Op tra y ys ∧ f y = SOME i
Proof
  Cases_on ‘x’ \\ gvs [dest_Op_Nil_def,dest_Op_def,AllCaseEqs()]
  \\ rw [] \\ eq_tac \\ rw []
QED

Theorem dest_Op_Nil_thm:
  dest_Op_Nil f x = SOME i ⇔
  ∃tra y. x = Op tra y [] ∧ f y = SOME i
Proof
  Cases_on ‘x’ \\ gvs [dest_Op_Nil_def,dest_Op_def,AllCaseEqs()]
  \\ fs [PULL_EXISTS] \\ Cases_on ‘l’ \\ fs []
QED

Theorem dest_Const_thm:
  dest_Const x = SOME i ⇔ x = Const i
Proof
  Cases_on ‘x’ \\ fs [dest_Const_def]
QED

Theorem dest_Cons_thm:
  dest_Cons x = SOME i ⇔ x = Cons i
Proof
  Cases_on ‘x’ \\ fs [dest_Cons_def]
QED

Theorem eq_direct_thm:
  ∀x y env s res s1 t z.
    evaluate ([Op t Equal [x; y]],env,s) = (res,s1) ∧
    res ≠ Rerr (Rabort Rtype_error) ∧
    eq_direct x y = SOME z ⇒
    evaluate ([z],env,s) = (res,s1)
Proof
  rpt gen_tac \\ fs [eq_direct_def]
  \\ reverse (Cases_on ‘eq_direct_const x y’) \\ fs []
  THEN1
   (gvs [eq_direct_const_def,AllCaseEqs(),dest_Op_Nil_thm,dest_Const_thm]
    \\ fs [evaluate_def,do_app_def]
    THEN1
     (Cases_on ‘evaluate ([x],env,s)’ \\ fs [] \\ Cases_on ‘q’ \\ fs []
      \\ rw [] \\ fs [evaluate_def]
      \\ imp_res_tac evaluate_SING \\ gvs []
      \\ cheat)
    THEN1
     (Cases_on ‘evaluate ([y],env,s)’ \\ fs [] \\ Cases_on ‘q’ \\ fs []
      \\ rw [] \\ fs [evaluate_def]
      \\ imp_res_tac evaluate_SING \\ gvs []
      \\ cheat)
    \\ EVAL_TAC \\ rw [] \\ fs [] \\ EVAL_TAC)
  \\ reverse (Cases_on ‘eq_direct_nil x y’) \\ fs []
  THEN1
   (gvs [eq_direct_nil_def,AllCaseEqs(),dest_Op_Nil_thm,dest_Cons_thm]
    \\ fs [evaluate_def,do_app_def]
    THEN1
     (Cases_on ‘evaluate ([x],env,s)’ \\ fs [] \\ Cases_on ‘q’ \\ fs []
      \\ rw [] \\ fs [evaluate_def]
      \\ imp_res_tac evaluate_SING \\ gvs [AllCaseEqs()]
      \\ gvs[do_eq_def,AllCaseEqs(),do_app_def])
    THEN1
     (Cases_on ‘evaluate ([y],env,s)’ \\ fs [] \\ Cases_on ‘q’ \\ fs []
      \\ rw [] \\ fs [evaluate_def]
      \\ imp_res_tac evaluate_SING \\ gvs [AllCaseEqs()]
      \\ gvs[do_eq_def,AllCaseEqs(),do_app_def])
    \\ EVAL_TAC \\ rw [] \\ fs [] \\ EVAL_TAC)
  \\ fs []
QED

Theorem dont_lift_Rval:
  dont_lift x ∧ evaluate ([x],env,s1) = (res,s2) ⇒
  ∃v. res = Rval [v] ∧ s2 = s1
Proof
  cheat
QED

Theorem evaluate_dont_lift:
  evaluate ([x],env,s1) = (Rval [v],s2:('a,'b) state) ∧ dont_lift x ⇒
  evaluate ([x],env1,s) = (Rval [v],s:('a,'b) state)
Proof
  cheat
QED

Theorem lift_exps_acc:
  ∀xs n binds ys k binds2.
    lift_exps xs n binds = (ys,k,binds2) ⇒
    ∃binds1. binds2 = binds ++ binds1
Proof
  cheat
QED

Theorem lift_exps_n:
  ∀xs n binds ys k binds2.
    lift_exps xs n binds = (ys,k,binds2) ∧ n = LENGTH binds ⇒
    k = LENGTH binds2
Proof
  cheat
QED

Theorem lift_exps_length:
  ∀xs n binds ys k binds2.
    lift_exps xs n binds = (ys,k,binds2) ⇒
    LENGTH xs = LENGTH ys
Proof
  cheat
QED

Theorem lift_exps_thm:
  ∀xs n binds env s0 ys k vs0 binds2 s1 (s2:('a,'b) state) res0.
    evaluate (binds,env,s0) = (Rval vs0,s1) ∧
    evaluate (xs,env,s1) = (res0,s2) ∧ n = LENGTH binds ∧
    lift_exps xs n binds = (ys,k,binds2) ⇒
    ∃res.
      evaluate (binds2,env,s0) = (res,s2) ∧
      (∀err. res = Rerr err ⇒ res0 = res) ∧
      ∀ws (s3:('a,'b) state) bind_vals.
        res = Rval bind_vals ⇒
        ∃vs. res0 = Rval vs ∧
             evaluate (ys,bind_vals++ws,s3) = (Rval vs,s3)
Proof
  ho_match_mp_tac lift_exps_ind \\ rpt strip_tac
  THEN1 gvs [lift_exps_def,evaluate_def]
  \\ gvs [] \\ pop_assum mp_tac
  \\ simp [lift_exps_def]
  \\ IF_CASES_TAC
  THEN1
   (pairarg_tac \\ gvs [] \\ strip_tac \\ gvs []
    \\ first_x_assum drule
    \\ qpat_x_assum ‘evaluate (_::_,_) = _’ mp_tac
    \\ simp [Once evaluate_CONS]
    \\ Cases_on ‘evaluate (xs,env,s1)’ \\ gvs []
    \\ strip_tac \\ gvs [] \\ strip_tac \\ gvs []
    \\ Cases_on ‘evaluate ([x],env,s1)’ \\ gvs []
    \\ drule_all dont_lift_Rval
    \\ strip_tac \\ gvs []
    \\ Cases_on ‘res’ \\ gvs [] \\ rw []
    \\ Cases_on ‘q’ \\ gvs []
    \\ simp [Once evaluate_CONS]
    \\ drule_all evaluate_dont_lift \\ fs [])
  \\ Cases_on ‘dest_Op dest_Cons x’ \\ fs []
  THEN1
   (pairarg_tac \\ gvs [] \\ strip_tac \\ gvs []
    \\ qpat_x_assum ‘evaluate _ = _’ mp_tac
    \\ simp [Once evaluate_CONS]
    \\ Cases_on ‘evaluate ([x],env,s1)’
    \\ reverse (Cases_on ‘q’) \\ rw []
    THEN1
     (drule lift_exps_acc \\ rw [] \\ fs []
      \\ full_simp_tac std_ss [GSYM APPEND_ASSOC,APPEND]
      \\ simp [Once evaluate_APPEND]
      \\ simp [Once evaluate_CONS])
    \\ imp_res_tac evaluate_SING \\ gvs []
    \\ Cases_on ‘evaluate (xs,env,r)’ \\ fs []
    \\ last_x_assum (qspecl_then [‘env’,‘s0’] mp_tac)
    \\ simp [Once evaluate_APPEND]
    \\ rw [] \\ fs []
    \\ reverse (Cases_on ‘res’) \\ gvs []
    \\ reverse (Cases_on ‘q’) \\ gvs []
    \\ drule lift_exps_n \\ rw []
    \\ imp_res_tac lift_exps_acc \\ gvs []
    \\ gvs [evaluate_APPEND] \\ gvs [AllCaseEqs()]
    \\ rw [] \\ pop_assum (qspec_then ‘ws’ strip_assume_tac)
    \\ gvs [] \\ last_x_assum assume_tac
    \\ imp_res_tac evaluate_IMP_LENGTH \\ gvs []
    \\ simp [Once evaluate_CONS]
    \\ fs [evaluate_def]
    \\ full_simp_tac std_ss [GSYM APPEND_ASSOC,APPEND] \\ gvs []
    \\ gvs [EL_APPEND2])
  \\ rename [‘_ = SOME c’] \\ PairCases_on ‘c’ \\ fs []
  \\ pairarg_tac \\ fs []
  \\ pairarg_tac \\ fs []
  \\ strip_tac \\ gvs [dest_Op_thm,dest_Cons_thm]
  \\ imp_res_tac lift_exps_acc \\ gvs []
  \\ first_x_assum drule \\ fs []
  \\ Cases_on ‘evaluate (c1,env,s1)’ \\ fs [] \\ strip_tac
  \\ reverse (Cases_on ‘res’) \\ gvs []
  THEN1
   (simp [Once evaluate_APPEND]
    \\ qpat_x_assum ‘evaluate (Op _ _ _ :: _ , _) = _’ mp_tac
    \\ simp [Once evaluate_CONS]
    \\ fs [evaluate_def])
  \\ qpat_x_assum ‘evaluate (Op _ _ _ :: _ , _) = _’ mp_tac
  \\ simp [Once evaluate_CONS]
  \\ fs [evaluate_def,do_app_def]
  \\ reverse (Cases_on ‘q’) THEN1 gvs [] \\ gvs []
  \\ Cases_on ‘evaluate (xs,env,r)’ \\ fs [] \\ strip_tac
  \\ imp_res_tac lift_exps_n \\ rw [] \\ gvs []
  \\ first_x_assum drule_all \\ strip_tac \\ gvs []
  \\ Cases_on ‘res’ \\ gvs []
  \\ Cases_on ‘q’ \\ gvs []
  \\ rw []
  \\ simp [Once evaluate_CONS]
  \\ fs [evaluate_def,do_app_def]
  \\ gvs [evaluate_APPEND] \\ gvs [AllCaseEqs()]
  \\ gvs [PULL_EXISTS]
  \\ full_simp_tac std_ss [GSYM APPEND_ASSOC]
QED

Theorem lift_exps_Let:
  lift_exps [x] 0 [] = ([y],n,binds) ∧
  evaluate ([x],env,s1) = (res,s2) ⇒
  evaluate ([Let None binds y],env,s1) = (res,s2)
Proof
  strip_tac
  \\ drule_at (Pos last) lift_exps_thm
  \\ fs [evaluate_def]
  \\ disch_then drule
  \\ strip_tac \\ fs []
  \\ reverse (Cases_on ‘res'’) \\ gvs []
  \\ pop_assum (qspecl_then [‘env’,‘s2’] strip_assume_tac)
  \\ gvs []
QED

Theorem lift_exps_pure:
  lift_exps xs n binds = (ys,k,binds2) ⇒ EVERY pure ys
Proof
  cheat
QED

Theorem evaluate_ConjList_append_F:
  ∀xs ys.
    evaluate ([ConjList xs],env1,r) = (Rval [Boolv F],r) ∧ EVERY pure xs ⇒
    evaluate ([ConjList (xs ++ ys)],env1,r) = (Rval [Boolv F],r:('c,'ffi) state)
Proof
  Induct THEN1 (EVAL_TAC \\ rw [] \\ EVAL_TAC)
  \\ reverse (Cases_on ‘xs’) \\ fs [ConjList_def]
  THEN1
   (fs [evaluate_def] \\ rpt gen_tac
    \\ rpt (CASE_TAC \\ fs []) \\ rw []
    \\ imp_res_tac pure_correct
    \\ first_x_assum (qspecl_then [‘r’,‘env1’] assume_tac) \\ gvs [])
  \\ reverse (Cases_on ‘ys’) \\ fs [ConjList_def]
  \\ fs [evaluate_def] \\ rpt gen_tac \\ EVAL_TAC
QED

Theorem evaluate_ConjList_append_T:
  ∀xs ys.
    evaluate ([ConjList xs],env1,r) = (Rval [Boolv T],r) ∧ EVERY pure xs ⇒
    evaluate ([ConjList (xs ++ ys)],env1,r) =
    evaluate ([ConjList ys],env1,r:('c,'ffi) state)
Proof
  Induct THEN1 (EVAL_TAC \\ rw [] \\ EVAL_TAC)
  \\ reverse (Cases_on ‘xs’) \\ fs [ConjList_def]
  THEN1
   (fs [evaluate_def] \\ rpt gen_tac
    \\ rpt (CASE_TAC \\ fs []) \\ rw []
    \\ fs [evaluate_MakeBool]
    \\ imp_res_tac pure_correct
    \\ first_x_assum (qspecl_then [‘r’,‘env1’] assume_tac) \\ gvs [])
  \\ reverse (Cases_on ‘ys’) \\ fs [ConjList_def]
  \\ fs [evaluate_def] \\ rpt gen_tac \\ EVAL_TAC
QED

Theorem do_eq_sym:
  do_eq x y = do_eq y x
Proof
  cheat
QED

Theorem pure_eq_pure_list:
  ∀xs.
    EVERY (λ(x,y). pure x ∧ pure y) xs ⇒
    EVERY pure (append (eq_pure_list xs))
Proof
  cheat
QED

Theorem eq_pure_thm:
  evaluate ([x1; y1],env1,r) = (Rval [h1; h2],r) ∧ pure x1 ∧ pure y1 ∧
  do_eq h1 h2 = Eq_val b ⇒
  evaluate ([eq_pure x1 y1],env1,r) = (Rval [Boolv b],r)
Proof
  fs [eq_pure_def]
  \\ qsuff_tac ‘
      ∀xs hs b.
        LIST_REL (λ(x1,y1) (h1,h2). evaluate ([x1; y1],env1,r) = (Rval [h1; h2],r) ∧
                                    pure x1 ∧ pure y1) xs hs ∧
        do_eq_list (MAP FST hs) (MAP SND hs) = Eq_val b ∧
        EVERY pure (append (eq_pure_list xs)) ⇒
        evaluate ([ConjList (append (eq_pure_list xs))],env1,r) = (Rval [Boolv b],r)’
  THEN1
   (disch_then (qspecl_then [‘[(x1,y1)]’,‘[(h1,h2)]’,‘b’] mp_tac)
    \\ rw [] \\ gvs[do_eq_def |> CONJUNCT2]
    \\ Cases_on ‘b’ \\ gvs []
    \\ last_x_assum irule
    \\ irule pure_eq_pure_list \\ fs [])
  \\ ho_match_mp_tac eq_pure_list_ind
  \\ rpt strip_tac
  THEN1 (gvs [do_eq_def |> CONJUNCT2] \\ EVAL_TAC)
  THEN1
   (simp [Once eq_pure_list_def]
    \\ reverse (Cases_on ‘eq_direct x y’) \\ gvs [UNCURRY]
    THEN1
     (qspecl_then [‘x’,‘y’,‘env1’,‘r’] mp_tac eq_direct_thm
      \\ simp [Once evaluate_def,do_app_def]
      \\ simp [Once do_eq_sym] \\ fs [do_eq_def |> CONJUNCT2]
      \\ Cases_on ‘do_eq (FST y') (SND y')’ \\ fs [ConjList_def]
      \\ Cases_on ‘b'’ \\ fs [])
    \\ Cases_on ‘dest_Op dest_Cons x’ \\ fs []
    \\ Cases_on ‘dest_Op dest_Cons y’ \\ fs []
    THEN1
     (simp [Once evaluate_def,do_app_def,ConjList_def]
      \\ simp [Once do_eq_sym] \\ fs [do_eq_def |> CONJUNCT2]
      \\ Cases_on ‘do_eq (FST y') (SND y')’ \\ fs [ConjList_def]
      \\ Cases_on ‘b'’ \\ fs [])
    THEN1
     (gvs [PULL_EXISTS] \\ last_x_assum irule
      \\ fs [evaluate_def]
      \\ cheat)
    THEN1 cheat
    \\ PairCases_on ‘x'’
    \\ PairCases_on ‘x''’
    \\ gvs [dest_Op_thm]
    \\ IF_CASES_TAC
    THEN1
     (EVAL_TAC \\ Cases_on ‘b’ \\ gvs [dest_Cons_thm]
      \\ Cases_on ‘y'’
      \\ gvs [evaluate_def,AllCaseEqs(),do_app_def]
      \\ qpat_x_assum ‘do_eq_list _ _ = _’ mp_tac
      \\ fs [do_eq_def]
      \\ rw [] \\ fs [] \\ imp_res_tac evaluate_IMP_LENGTH \\ gvs [])
    \\ last_x_assum irule
    \\ Cases_on ‘x''0 = x'0’ \\ gvs []
    \\ irule_at Any pure_eq_pure_list
    \\ cheat)
  \\ gvs [PULL_EXISTS,FORALL_PROD,UNCURRY,do_eq_def |> CONJUNCT2]
  \\ simp [Once eq_pure_list_def]
  \\ pop_assum mp_tac
  \\ simp [Once eq_pure_list_def] \\ rw []
  \\ Cases_on ‘do_eq (FST y) (SND y)’ \\ fs []
  \\ reverse (Cases_on ‘b'’) \\ gvs []
  \\ last_x_assum drule
  \\ Cases_on ‘do_eq (FST y') (SND y')’ \\ fs [] \\ rw []
  \\ fs [evaluate_ConjList_append_F,evaluate_ConjList_append_T]
QED

Theorem SmartOp_thm:
  evaluate ([Op t op xs], env, s) = (res,s1) ∧ res ≠ Rerr (Rabort Rtype_error) ⇒
  evaluate ([SmartOp t op xs], env, s) = (res,s1)
Proof
  fs [SmartOp_def] \\ CASE_TAC \\ fs [] \\ rename [‘_ = SOME z’]
  \\ pop_assum mp_tac \\ qid_spec_tac ‘xs’ \\ ho_match_mp_tac list_split3
  \\ fs [SmartOp'_def] \\ rpt strip_tac
  THEN1
   (gvs [AllCaseEqs()]
    \\ Cases_on ‘x’ \\ fs [dest_Op_def] \\ gvs [AllCaseEqs()]
    \\ Cases_on ‘o'’ \\ gvs [dest_Cons_def]
    \\ Cases_on ‘∃k. op = ElemAt k’
    THEN1
     (gvs [cons_op_def,dest_ElemAt_def]
      \\ qmatch_asmsub_abbrev_tac ‘if b then _ else _’
      \\ reverse (fs [AllCaseEqs()])
      THEN1 (pop_assum kall_tac \\ gvs []
             \\ gvs [evaluate_def,AllCaseEqs(),do_app_def])
      \\ fs [Abbr‘b’] \\ gvs []
      \\ gvs [evaluate_def,AllCaseEqs(),do_app_def]
      \\ qspecl_then [‘l’,‘env’,‘s’] assume_tac EVERY_pure_correct
      \\ gvs [] \\ rename [‘ee ≠ _’]
      \\ Cases_on ‘ee’ \\ fs [])
    \\ Cases_on ‘∃k1 k2. op = TagLenEq k1 k2’
    THEN1
     (gvs [cons_op_def,dest_ElemAt_def,dest_TagLenEq_def]
      \\ reverse (fs [AllCaseEqs()])
      \\ gvs [evaluate_def,AllCaseEqs(),do_app_def,evaluate_MakeBool]
      \\ TRY (rw [] \\ eq_tac \\ rw []
              \\ imp_res_tac evaluate_IMP_LENGTH \\ fs [])
      \\ qspecl_then [‘l’,‘env’,‘s’] assume_tac EVERY_pure_correct
      \\ gvs [] \\ rename [‘ee ≠ _’]
      \\ Cases_on ‘ee’ \\ fs [])
    \\ Cases_on ‘∃k. op = TagEq k’
    THEN1
     (gvs [cons_op_def,dest_ElemAt_def,dest_TagLenEq_def,dest_TagEq_def]
      \\ reverse (fs [AllCaseEqs()])
      \\ gvs [evaluate_def,AllCaseEqs(),do_app_def,evaluate_MakeBool]
      \\ TRY (rw [] \\ eq_tac \\ rw []
              \\ imp_res_tac evaluate_IMP_LENGTH \\ fs [])
      \\ qspecl_then [‘l’,‘env’,‘s’] assume_tac EVERY_pure_correct
      \\ gvs [] \\ rename [‘ee ≠ _’]
      \\ Cases_on ‘ee’ \\ fs [])
    \\ Cases_on ‘∃k. op = LenEq k’
    THEN1
     (gvs [cons_op_def,dest_ElemAt_def,dest_TagLenEq_def,dest_TagEq_def,dest_LenEq_def]
      \\ reverse (fs [AllCaseEqs()])
      \\ gvs [evaluate_def,AllCaseEqs(),do_app_def,evaluate_MakeBool]
      \\ TRY (rw [] \\ eq_tac \\ rw []
              \\ imp_res_tac evaluate_IMP_LENGTH \\ fs [])
      \\ qspecl_then [‘l’,‘env’,‘s’] assume_tac EVERY_pure_correct
      \\ gvs [] \\ rename [‘ee ≠ _’]
      \\ Cases_on ‘ee’ \\ fs [])
    \\ last_x_assum mp_tac
    \\ Cases_on ‘op’ \\ fs [] \\ EVAL_TAC)
  \\ reverse (Cases_on ‘dest_Op_Consts x y’) \\ gvs []
  THEN1
   (gvs [AllCaseEqs()]
    \\ Cases_on ‘x’ \\ fs [dest_Op_Consts_def,dest_Op_Nil_def,dest_Op_def,dest_Const_def]
    \\ Cases_on ‘o'’ \\ fs [dest_Op_Consts_def,dest_Op_def,dest_Const_def]
    \\ Cases_on ‘l’ \\ fs [dest_Op_Consts_def,dest_Op_def,dest_Const_def]
    \\ Cases_on ‘y’ \\ fs [dest_Op_Consts_def,dest_Op_def,dest_Const_def]
    \\ Cases_on ‘o'’ \\ fs [dest_Op_Consts_def,dest_Op_def,dest_Const_def]
    \\ Cases_on ‘l’ \\ gvs []
    \\ gvs [int_op_def,AllCaseEqs(),MakeInt_def]
    \\ gvs [evaluate_def,AllCaseEqs(),do_app_def,evaluate_MakeBool]
    \\ gvs [do_eq_def] \\ intLib.COOPER_TAC)
  \\ last_x_assum mp_tac
  \\ simp [eq_op_def,GSYM AND_IMP_INTRO]
  \\ disch_then kall_tac \\ fs [AllCaseEqs()]
  \\ reverse (Cases_on ‘eq_direct x y’) \\ rw []
  THEN1 (drule_all eq_direct_thm \\ fs [])
  \\ gvs [eq_any_def,AllCaseEqs()]
  \\ drule_at Any lift_exps_thm
  \\ simp [Once evaluate_def]
  \\ last_x_assum mp_tac
  \\ simp [Once evaluate_def]
  \\ Cases_on ‘evaluate ([x; y],env,s)’ \\ fs []
  \\ strip_tac \\ disch_then drule
  \\ strip_tac
  \\ simp [Once evaluate_def]
  \\ reverse (Cases_on ‘q’) \\ gvs []
  \\ CASE_TAC \\ fs []
  \\ imp_res_tac evaluate_IMP_LENGTH
  \\ gvs [LENGTH_EQ_NUM_compute,do_app_def]
  \\ rename [‘do_eq h1 h2’]
  \\ reverse (Cases_on ‘do_eq h1 h2’) \\ gvs []
  \\ imp_res_tac lift_exps_length \\ gvs []
  \\ first_x_assum (qspecl_then [‘env’,‘r’] assume_tac)
  \\ irule eq_pure_thm \\ fs []
  \\ imp_res_tac lift_exps_pure \\ fs []
  \\ simp [Once do_eq_sym]
QED

Theorem SmartOp_simp:
  set_globals (SmartOp t op xs) = set_globals (Op t op xs) ∧
  esgc_free (SmartOp t op xs) = esgc_free (Op t op xs) ∧
  pure (SmartOp t op xs) = pure (Op t op xs)
Proof
  cheat
QED

Theorem SmartOp_Const:
  ∀xs. SmartOp t (Const i) xs = Op t (Const i) xs
Proof
  ho_match_mp_tac list_split3 \\ EVAL_TAC \\ rw []
  \\ rpt ((Cases_on ‘x’ \\ fs [] \\ EVAL_TAC) ORELSE
          (Cases_on ‘o'’ \\ fs [] \\ EVAL_TAC) ORELSE
          (Cases_on ‘y’ \\ fs [] \\ EVAL_TAC))
  \\ every_case_tac \\ fs []
QED

Theorem SmartOp_Cons:
  ∀xs. SmartOp t (Cons n) xs = Op t (Cons n) xs
Proof
  ho_match_mp_tac list_split3 \\ EVAL_TAC \\ rw []
  \\ rpt ((Cases_on ‘x’ \\ fs [] \\ EVAL_TAC) ORELSE
          (Cases_on ‘o'’ \\ fs [] \\ EVAL_TAC) ORELSE
          (Cases_on ‘y’ \\ fs [] \\ EVAL_TAC))
  \\ every_case_tac \\ fs []
QED

Theorem SmartOp_Install:
  SmartOp t Install = Op t Install
Proof
  fs [FUN_EQ_THM] \\ ho_match_mp_tac list_split3 \\ EVAL_TAC \\ rw []
  \\ rpt ((Cases_on ‘x’ \\ fs [] \\ EVAL_TAC) ORELSE
          (Cases_on ‘o'’ \\ fs [] \\ EVAL_TAC) ORELSE
          (Cases_on ‘y’ \\ fs [] \\ EVAL_TAC))
  \\ every_case_tac \\ fs []
QED

Theorem fv_max_SmartOp:
  fv_max n [Op t op xs] ⇒ fv_max n [SmartOp t op xs]
Proof
  cheat
QED

Theorem code_locs_SmartOp:
  LIST_TO_BAG (code_locs [SmartOp t op xs]) =
  LIST_TO_BAG (code_locs [Op t op xs])
Proof
  cheat
QED

Theorem every_Fn_SOME_SmartOp:
  every_Fn_SOME [SmartOp t op xs] = every_Fn_SOME [Op t op xs]
Proof
  cheat
QED

Theorem every_Fn_vs_NONE_SmartOp:
  every_Fn_vs_NONE xs ⇒ every_Fn_vs_NONE [SmartOp t op xs]
Proof
  cheat
QED

Theorem no_Labels_SmartOp:
  EVERY no_Labels xs ⇒ no_Labels (SmartOp t op xs)
Proof
  cheat
QED

Theorem obeys_max_app_SmartOp:
  EVERY (obeys_max_app k) xs ⇒ obeys_max_app k (SmartOp t op xs)
Proof
  cheat
QED

val _ = export_theory();
