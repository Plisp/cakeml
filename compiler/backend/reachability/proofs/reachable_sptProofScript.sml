(*
  Proofs of various closure operations for num_map and num_set
*)

open preamble reachable_sptTheory

val _ = new_theory "reachable_sptProof";

Theorem num_set_tree_union_empty:
     ∀ t1 t2 . isEmpty(num_set_tree_union t1 t2) ⇔ isEmpty t1 ∧ isEmpty t2
Proof
    Induct >> rw[num_set_tree_union_def] >> CASE_TAC >>
    rw[num_set_tree_union_def]
QED

Theorem wf_num_set_tree_union:
     ∀ t1 t2 result . wf t1 ∧ wf t2 ∧ num_set_tree_union t1 t2 = result
  ⇒ wf result
Proof
    Induct >> rw[num_set_tree_union_def, wf_def] >> rw[wf_def] >>
    TRY(CASE_TAC) >>
    rw[wf_def] >>
    TRY(metis_tac[wf_def, num_set_tree_union_empty])
QED

Theorem domain_num_set_tree_union:
     ∀ t1 t2 . domain (num_set_tree_union t1 t2) = domain t1 ∪ domain t2
Proof
    Induct >> rw[num_set_tree_union_def, domain_def] >> CASE_TAC >>
    rw[domain_def, domain_union] >> rw[UNION_ASSOC] >> rw[UNION_COMM] >>
    rw[UNION_ASSOC] >> rw[UNION_COMM] >>
    metis_tac[UNION_ASSOC, UNION_COMM, UNION_IDEMPOT]
QED

Theorem num_set_tree_union_sym:
     ∀ (t1 : num_set num_map) t2 .
        num_set_tree_union t1 t2 = num_set_tree_union t2 t1
Proof
    Induct >> rw[num_set_tree_union_def] >>
    Cases_on `t2` >> fs[num_set_tree_union_def] >>
    fs[union_num_set_sym]
QED

Theorem lookup_domain_num_set_tree_union:
     ∀ n (t1:num_set num_map) t2 x . lookup n t1 = SOME x
  ⇒ ∃ y . lookup n (num_set_tree_union t1 t2) = SOME y ∧ domain x ⊆ domain y
Proof
    Induct_on `t1` >> rw[]
    >- fs[lookup_def]
    >- (fs[lookup_def, num_set_tree_union_def] >> CASE_TAC >>
        fs[lookup_def, domain_union])
    >- (fs[lookup_def, num_set_tree_union_def] >> CASE_TAC >>
        fs[lookup_def, domain_union] >> Cases_on `EVEN n` >> fs[])
    >- (fs[lookup_def, num_set_tree_union_def] >> CASE_TAC >>
        fs[lookup_def, domain_union] >>
        Cases_on `n = 0` >> fs[domain_union] >> Cases_on `EVEN n` >> fs[])
QED

Theorem lookup_NONE_num_set_tree_union:
     ∀ n (t1:num_set num_map) t2 . lookup n t1 = NONE
    ⇒ lookup n (num_set_tree_union t1 t2) = lookup n t2
Proof
    Induct_on `t1` >> rw[] >> fs[lookup_def, num_set_tree_union_def] >>
    Cases_on `t2` >> fs[lookup_def] >> Cases_on `n = 0` >> fs[] >>
    Cases_on `EVEN n` >> fs[]
QED

Theorem lookup_SOME_SOME_num_set_tree_union:
     ∀ n (t1:num_set num_map) x1 t2 x2 .
    lookup n t1 = SOME x1 ∧ lookup n t2 = SOME x2
  ⇒ lookup n (num_set_tree_union t1 t2) = SOME (union x1 x2)
Proof
    Induct_on `t1` >> rw[] >> fs[lookup_def, num_set_tree_union_def] >>
    Cases_on `t2` >> fs[lookup_def] >>
    Cases_on `EVEN n` >> fs[] >>
    Cases_on `n = 0` >> fs[]
QED

Theorem lookup_num_set_tree_union:
     ∀ (t1 : num_set num_map) t2 n .
        lookup n (num_set_tree_union t1 t2) = case (lookup n t1) of
            | NONE => lookup n t2
            | SOME s1 => case (lookup n t2) of
                | NONE => SOME s1
                | SOME s2 => SOME (union s1 s2)
Proof
    rw[] >> Cases_on `lookup n t1` >> fs[]
    >-  fs[lookup_NONE_num_set_tree_union]
    >- (Cases_on `lookup n t2` >> fs[]
        >- (fs[lookup_NONE_num_set_tree_union, num_set_tree_union_sym] >>
            imp_res_tac lookup_NONE_num_set_tree_union >>
            pop_assum (qspec_then `t1` mp_tac) >> rw[] >>
            fs[num_set_tree_union_sym])
        >-  fs[lookup_SOME_SOME_num_set_tree_union])
QED


(**************************** REACHABILITY LEMMAS *****************************)

Theorem subspt_superdomain:
   ∀ t1 a t2 . subspt (superdomain t1) (superdomain (BS t1 a t2)) ∧
               subspt (superdomain t2) (superdomain (BS t1 a t2)) ∧
               subspt a (superdomain (BS t1 a t2)) ∧
               subspt (superdomain t1) (superdomain (BN t1 t2)) ∧
               subspt (superdomain t2) (superdomain (BN t1 t2))
Proof
    fs[subspt_domain, superdomain_def] >>
    fs[SUBSET_DEF, domain_lookup, lookup_spt_fold_union_STRONG, lookup_def] >>
    rw[]
    >- (
      qexists_tac `2 * n1 + 2` >>
      fs[EVEN_DOUBLE, EVEN_ADD] >>
      once_rewrite_tac[MULT_COMM] >> fs[DIV_MULT]
      )
    >- (
      qexists_tac `2 * n1 + 1` >>
      fs[EVEN_DOUBLE, EVEN_ADD] >>
      once_rewrite_tac[MULT_COMM] >> fs[MULT_DIV]
      )
    >- (
      qexists_tac `0` >>
      fs[]
      )
    >- (
      qexists_tac `2 * n1 + 2` >>
      fs[EVEN_DOUBLE, EVEN_ADD] >>
      once_rewrite_tac[MULT_COMM] >> fs[DIV_MULT]
      )
    >- (
      qexists_tac `2 * n1 + 1` >>
      fs[EVEN_DOUBLE, EVEN_ADD] >>
      once_rewrite_tac[MULT_COMM] >> fs[MULT_DIV]
      )
QED

Theorem superdomain_thm:
   ∀ x y (tree : unit spt spt) . lookup x tree = SOME y
  ⇒ domain y ⊆ domain (superdomain tree)
Proof
    fs[superdomain_def, domain_lookup, SUBSET_DEF] >>
    fs[lookup_spt_fold_union_STRONG, lookup_def] >>
    rw[] >> metis_tac[]
QED

Theorem superdomain_inverse_thm:
   ∀ n tree . n ∈ domain (superdomain tree)
  ⇒ ∃ k aSet . lookup k tree = SOME aSet ∧ n ∈ domain aSet
Proof
    fs[superdomain_def, domain_lookup] >>
    fs[lookup_spt_fold_union_STRONG, lookup_def]
QED

Theorem superdomain_not_in_thm:
   ∀ n tree . n ∉ domain (superdomain tree)
  ⇒ ∀ k aSet . lookup k tree = SOME aSet ⇒ n ∉ domain aSet
Proof
    fs[superdomain_def, domain_lookup] >>
    fs[lookup_spt_fold_union_STRONG, lookup_def] >>
    rw[] >> metis_tac[]
QED

Theorem mk_wf_set_tree_domain:
     ∀ tree . domain tree ⊆ domain (mk_wf_set_tree tree)
Proof
    Induct >>
    rw[mk_wf_set_tree_def, domain_map, domain_mk_wf, domain_union, SUBSET_DEF]
QED

Theorem mk_wf_set_tree_thm:
     ∀ x tree . x = mk_wf_set_tree tree ⇒ wf_set_tree x
Proof
    rw[mk_wf_set_tree_def, wf_set_tree_def] >> fs[lookup_map] >>
    rw[domain_map, domain_union] >> fs[lookup_union] >>
    Cases_on `lookup x' tree` >> fs[] >- fs[lookup_map] >> rw[] >>
    qspecl_then [`x'`, `x`, `tree`] mp_tac superdomain_thm >> rw[SUBSET_DEF]
QED

Theorem lookup_mk_wf_set_tree:
     ∀ n tree x . lookup n tree = SOME x
  ⇒ ∃ y . lookup n (mk_wf_set_tree tree) = SOME y ∧ domain x = domain y
Proof
    rw[mk_wf_set_tree_def] >> rw[lookup_map] >> rw[lookup_union]
QED

Theorem lookup_domain_mk_wf_set_tree:
     ∀ n t x y . lookup n (mk_wf_set_tree t) = SOME x ⇒
        lookup n t = SOME y ⇒ domain y = domain x
Proof
    rw[mk_wf_set_tree_def] >> fs[lookup_map, lookup_union] >>
    metis_tac[domain_mk_wf]
QED

Theorem wf_closure_spt:
  ∀ reachable tree.
    wf reachable ∧
    (∀ n x . lookup n tree = SOME x ⇒ wf x)
  ⇒ wf (closure_spt reachable tree)
Proof
    recInduct closure_spt_ind >> rw[] >>
    once_rewrite_tac [closure_spt_def] >> rw[] >> fs[] >>
    last_x_assum irule >> goal_assum drule >>
    irule wf_union >> simp[] >>
    irule wf_spt_fold_tree >> simp[wf_def, lookup_inter] >>
    rw[] >> EVERY_CASE_TAC >> gvs[] >> res_tac
QED


(**************************** OTHER LEMMAS *****************************)

Theorem domain_superdomain_num_set_tree_union:
     ∀ t1 t2 . domain (superdomain t1)
        ⊆ domain (superdomain (num_set_tree_union t1 t2))
Proof
    fs[SUBSET_DEF] >> rw[] >> imp_res_tac superdomain_inverse_thm >>
    imp_res_tac lookup_domain_num_set_tree_union >>
    pop_assum (qspec_then `t2` mp_tac) >>
    rw[] >> imp_res_tac superdomain_thm >> metis_tac[SUBSET_DEF]
QED

Theorem domain_superdomain_num_set_tree_union_STRONG:
     ∀ t1 t2 . domain (superdomain t1) ∪ domain (superdomain t2) =
        domain (superdomain (num_set_tree_union t1 t2))
Proof
    fs[EXTENSION] >> rw[] >> EQ_TAC >> rw[]
    >- metis_tac[domain_superdomain_num_set_tree_union,
                 SUBSET_DEF, num_set_tree_union_sym]
    >- metis_tac[domain_superdomain_num_set_tree_union,
                 SUBSET_DEF, num_set_tree_union_sym]
    >- (imp_res_tac superdomain_inverse_thm >> fs[lookup_num_set_tree_union] >>
        EVERY_CASE_TAC >> fs[]
        >- (disj1_tac >> imp_res_tac superdomain_thm >> fs[SUBSET_DEF])
        >- (disj2_tac >> imp_res_tac superdomain_thm >> fs[SUBSET_DEF])
        >- (rveq >> imp_res_tac superdomain_thm >>
            fs[SUBSET_DEF, domain_union])
       )
QED

Theorem mk_wf_set_tree_num_set_tree_union:
     ∀ t1 t2 . mk_wf_set_tree (num_set_tree_union t1 t2) =
        num_set_tree_union (mk_wf_set_tree t1) (mk_wf_set_tree t2)
Proof
    rw[] >>
    `wf (mk_wf_set_tree (num_set_tree_union t1 t2))`
        by metis_tac[mk_wf_set_tree_thm, wf_set_tree_def] >>
    `wf (num_set_tree_union (mk_wf_set_tree t1) (mk_wf_set_tree t2))` by
        metis_tac[mk_wf_set_tree_thm, wf_set_tree_def,
                  wf_num_set_tree_union] >>
    rw[spt_eq_thm] >> simp[mk_wf_set_tree_def] >> fs[lookup_map] >>
    fs[lookup_union] >> fs[lookup_map] >>
    fs[lookup_num_set_tree_union] >> fs[lookup_map] >>
    fs[lookup_union] >> fs[lookup_map] >>
    fs[OPTION_MAP_COMPOSE, mk_wf_def] >> Cases_on `lookup n t1` >>
    Cases_on `lookup n t2` >> fs[] >>
    EVERY_CASE_TAC >> fs[mk_wf_def, union_def] >>
    fs[lookup_NONE_domain, GSYM domain_lookup] >>
    qspecl_then [`t1`, `t2`] mp_tac
        domain_superdomain_num_set_tree_union_STRONG >>
    strip_tac >> fs[EXTENSION]
    >-  metis_tac[]
    >- (qsuff_tac `n ∈ domain (superdomain (num_set_tree_union t1 t2))`
        >- rw[domain_lookup]
        >> imp_res_tac domain_lookup >> metis_tac[])
    >- (qsuff_tac `n ∈ domain (superdomain (num_set_tree_union t1 t2))`
        >- rw[domain_lookup]
        >> imp_res_tac domain_lookup >> metis_tac[])
    >- (qsuff_tac `n ∈ domain (superdomain (num_set_tree_union t1 t2))`
        >- rw[domain_lookup]
        >> imp_res_tac domain_lookup >> metis_tac[])
QED


(************************** ADJACENCY/REACHABILITY ***************************)

Theorem adjacent_domain:
     ∀ tree x y . is_adjacent tree x y ⇒ x ∈ domain tree
Proof
    rw[is_adjacent_def] >> rw[domain_lookup]
QED

Theorem reachable_domain:
     ∀ tree x y . is_reachable tree x y
  ⇒ (x = y ∨ x ∈ domain tree)
Proof
    simp[is_reachable_def] >> strip_tac >> ho_match_mp_tac RTC_INDUCT_RIGHT1 >>
    metis_tac[adjacent_domain]
QED

Theorem rtc_is_adjacent:
     s ⊆ t ∧ (∀ k . k ∈ t ⇒ ∀ n . (is_adjacent fullTree k n ⇒ n ∈ t)) ⇒
    ∀ x y . RTC(is_adjacent fullTree) x y ⇒ x ∈ s ⇒ y ∈ t
Proof
    strip_tac >>
    ho_match_mp_tac RTC_INDUCT_RIGHT1 >>
    fs[SUBSET_DEF] >>
    metis_tac []
QED

Theorem is_adjacent_num_set_tree_union:
     ∀ t1 t2 n m .
        is_adjacent t1 n m ⇒ is_adjacent (num_set_tree_union t1 t2) n m
Proof
    rw[is_adjacent_def] >> imp_res_tac lookup_domain_num_set_tree_union >>
    first_x_assum (qspec_then `t2` mp_tac) >> rw[] >>
    goal_assum drule >>
    fs[SUBSET_DEF, domain_lookup]
QED

Theorem is_adjacent_wf_set_tree_num_set_tree_union:
     ∀ t1 t2 n m .
        is_adjacent (mk_wf_set_tree t1) n m
        ⇒ is_adjacent (mk_wf_set_tree (num_set_tree_union t1 t2)) n m
Proof
    rw[is_adjacent_def] >> fs[mk_wf_set_tree_def] >> fs[lookup_map] >>
    fs[lookup_union] >> fs[lookup_map] >> fs[PULL_EXISTS] >>
    fs[lookup_num_set_tree_union] >>
    Cases_on `lookup n t1` >> fs[] >> Cases_on `lookup n t2` >> fs[] >>
    rveq >> fs[lookup_def, mk_wf_def, lookup_union] >>
    EVERY_CASE_TAC >> fs[] >>
    qspecl_then [`t1`, `t2`] mp_tac domain_superdomain_num_set_tree_union >>
    rw[SUBSET_DEF, domain_lookup]
QED

Theorem is_reachable_wf_set_tree_num_set_tree_union:
     ∀ t1 t2 n m .
        is_reachable (mk_wf_set_tree t1) n m
      ⇒ is_reachable (mk_wf_set_tree (num_set_tree_union t1 t2)) n m
Proof
    simp[is_reachable_def] >> strip_tac >> strip_tac >>
    ho_match_mp_tac RTC_INDUCT_RIGHT1 >> rw[] >>
    simp[Once RTC_CASES2] >> disj2_tac >> qexists_tac `m` >> fs[] >>
    imp_res_tac is_adjacent_wf_set_tree_num_set_tree_union >> fs[]
QED

Theorem is_reachable_LHS_NOTIN:
  ∀tree n x. is_reachable tree n x ∧ n ∉ domain tree ⇒ n = x
Proof
  rw[is_reachable_def] >> gvs[Once RTC_CASES1, is_adjacent_def, domain_lookup]
QED

Theorem rtc_is_adjacent2:
  ∀r s tree.
    (∀k. k ∈ r ⇒ ∀n. is_adjacent tree k n ⇒ n ∈ s) ∧
    (∀l. l ∈ s ∧ l ∉ r ⇒ l ∉ domain tree) ∧
    r ⊆ s
  ⇒ ∀x y. (is_adjacent tree)꙳ x y ⇒ x ∈ r ⇒ y ∈ s
Proof
  rpt gen_tac >> strip_tac >>
  ho_match_mp_tac RTC_INDUCT_RIGHT1 >> fs[SUBSET_DEF] >>
  rw[] >> gvs[] >>
  reverse (Cases_on `y ∈ r`)
  >- (res_tac >> gvs[is_adjacent_def, domain_lookup]) >>
  metis_tac[]
QED


(**************************** MAIN LEMMAS *****************************)

Theorem closure_spt_lemma:
  ∀ reachable tree closure (roots : num set).
    closure_spt reachable tree = closure ∧
    roots ⊆ domain reachable ∧
    (∀k. k ∈ domain reachable ⇒ ∃n. n ∈ roots ∧ is_reachable tree n k)
  ⇒ domain closure = {a | ∃n. n ∈ roots ∧ is_reachable tree n a}
Proof
  recInduct closure_spt_ind >> rw[] >>
  once_rewrite_tac[closure_spt_def] >> simp[] >>
  IF_CASES_TAC
  >- (
    gvs[domain_difference, domain_spt_fold_union_eq, PULL_EXISTS,
        EXTENSION, SUBSET_DEF, superdomain_rewrite, subspt_domain] >>
    rw[] >> eq_tac >> rw[] >>
    gvs[DISJ_EQ_IMP, PULL_EXISTS] >>
    irule rtc_is_adjacent >>
    irule_at Any SUBSET_REFL >> gvs[SUBSET_DEF, is_reachable_def] >>
    goal_assum (drule_at Any) >> gvs[] >> rw[] >>
    first_x_assum irule >>
    gvs[lookup_inter, is_adjacent_def, domain_lookup] >>
    qexistsl_tac [`aSetx`,`k`] >> simp[]
    ) >>
  first_x_assum irule >> simp[] >> reverse (rw[])
  >- gvs[domain_union, SUBSET_DEF] >>
  gvs[domain_union, domain_spt_fold_union_eq,
      superdomain_rewrite, lookup_inter] >>
  EVERY_CASE_TAC >> gvs[] >> rename1 `lookup r reachable` >>
  gvs[domain_lookup] >>
  first_x_assum drule >> strip_tac >>
  goal_assum drule >> gvs[is_reachable_def] >>
  irule (iffRL RTC_CASES2) >> DISJ2_TAC >>
  goal_assum drule >> simp[is_adjacent_def]
QED

Theorem closure_spt_thm:
  ∀ tree start.
    domain (closure_spt start tree) =
      {a | ∃n. n ∈ domain start ∧ is_reachable tree n a}
Proof
  rw[] >> irule closure_spt_lemma >>
  irule_at Any EQ_REFL >> simp[] >> rw[] >>
  goal_assum drule >> simp[is_reachable_def]
QED


val _ = export_theory();
