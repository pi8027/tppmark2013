Require Import ssreflect ssrfun ssrbool eqtype ssrnat seq fintype finfun.

Set Implicit Arguments.
Unset Strict Implicit.
Unset Printing Implicit Defensive.

Section propositional_logic.

Variable V : finType.

Inductive formula :=
  | f_top | f_bot
  | f_var of V
  | f_neg of formula
  | f_and of formula & formula
  | f_or of formula & formula.

Fixpoint eval (f : formula) (a : {ffun V -> bool}) : bool :=
  match f with
  | f_top => true
  | f_bot => false
  | f_var x => a x
  | f_neg f' => ~~ eval f' a
  | f_and f1 f2 => eval f1 a && eval f2 a
  | f_or f1 f2 => eval f1 a || eval f2 a
  end.

Definition normal_form' (a : {ffun V -> bool}) : formula :=
  foldr f_and f_top
        [seq if a x then f_var x else f_neg (f_var x) | x <- enum V].

Definition normal_form (f : formula) : formula :=
  foldr f_or f_bot [seq normal_form' a | a <- enum {ffun V -> bool} & eval f a].

Lemma all_in_enum (T : finType) x : x \in enum T.
Proof. by rewrite mem_enum. Qed.

Lemma nf'_correct a a' : eval (normal_form' a) a' = (a == a').
Proof.
  apply Bool.eq_iff_eq_true; rewrite /normal_form'; split => H.
  - apply/eqP/ffunP => x.
    elim: (enum V) x (all_in_enum x) H => //= x xs IH y; rewrite inE; case/orP.
    + by move/eqP => -> /andP []; case: (a x) => //=; case: (a' x).
    + by move => H /andP [H0] /IH ->.
  - by rewrite -(eqP H); elim: (enum V) => //= x xs IH;
      apply/andP; split => //; case_eq (a x) => /= ->.
Qed.

Lemma nf_correct f : eval f =1 eval (normal_form f).
Proof.
  move => a; apply Bool.eq_iff_eq_true; rewrite /normal_form; split => H.
  - elim: (enum _) (all_in_enum a) => //= a' al IH; rewrite inE; case/orP.
    + by move/eqP <-; rewrite /= H /= nf'_correct eqxx.
    + by move/IH; case: (eval f a') => //= ->; rewrite orbT.
  - elim: (enum _) H => //= a' al IH; case_eq (eval f a') => //= H /orP [] //.
    by rewrite nf'_correct => /eqP H0; move: H0 H => <-.
Qed.

Lemma nf_uniq f f' : eval f =1 eval f' -> normal_form f = normal_form f'.
Proof.
  rewrite /normal_form => H; elim: (enum _) => //= a al H0.
  by case_eq (eval f a) => //; rewrite H => -> //=; rewrite H0.
Qed.

End propositional_logic.
