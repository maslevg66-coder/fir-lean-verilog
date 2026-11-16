import Fir.Spec

/-! # Capa 2: mini-HDL embebido en Lean -/

/-- Sintaxis de circuitos: entrada, constante, suma, producto por
    constante y registro (retardo de 1 ciclo, con reset en 0). -/
inductive Expr where
  | input : Expr
  | const : Int → Expr
  | add   : Expr → Expr → Expr
  | mulc  : Int → Expr → Expr
  | reg   : Expr → Expr

/-- Semántica ciclo a ciclo. -/
def eval : Expr → (Nat → Int) → Nat → Int
  | .input,   x, n => x n
  | .const c, _, _ => c
  | .add a b, x, n => eval a x n + eval b x n
  | .mulc c a, x, n => c * eval a x n
  | .reg a,   x, n => if n = 0 then 0 else eval a x (n - 1)

/-- FIR en forma directa: y = h₀·x + z⁻¹(resto del filtro). -/
def firCircuit : List Int → Expr
  | []      => .const 0
  | c :: cs => .add (.mulc c .input) (.reg (firCircuit cs))

/-- Auxiliar: si el índice `k` ya rebasó el ciclo `n`, la suma es 0. -/
theorem firAux_zero (x : Nat → Int) :
    ∀ (h : List Int) (k n : Nat), n < k → firAux h k x n = 0 := by
  intro h
  induction h with
  | nil => intro k n _; rfl
  | cons c cs ih =>
      intro k n hn
      have h1 : ¬ (k ≤ n) := by omega
      have h2 : firAux cs (k + 1) x n = 0 := ih (k + 1) n (by omega)
      simp only [firAux]
      rw [if_neg h1]
      omega

/-- Lema clave, generalizado en `k`: el circuito calcula la cola de la suma. -/
theorem firCircuit_eval (x : Nat → Int) :
    ∀ (h : List Int) (k n : Nat), eval (firCircuit h) x n = firAux h k x (n + k) := by
  intro h
  induction h with
  | nil => intro k n; rfl
  | cons c cs ih =>
      intro k n
      have e1 : firAux (c :: cs) k x (n + k)
          = c * x n + firAux cs (k + 1) x (n + k) := by
        simp only [firAux]
        rw [if_pos (Nat.le_add_left k n), Nat.add_sub_cancel]
      rw [e1]
      simp only [firCircuit, eval]
      cases n with
      | zero =>
          simp [firAux_zero x cs (k + 1) k (Nat.lt_succ_self k)]
      | succ m =>
          rw [if_neg (Nat.succ_ne_zero m), Nat.succ_sub_one, ih (k + 1) m]
          have e2 : m + (k + 1) = Nat.succ m + k := by omega
          rw [e2]

/-- **TEOREMA CENTRAL**: el circuito implementa exactamente la especificación,
    para cualquier lista de coeficientes, cualquier entrada y cualquier ciclo. -/
theorem firCircuit_correct (h : List Int) (x : Nat → Int) (n : Nat) :
    eval (firCircuit h) x n = fir h x n :=
  firCircuit_eval x h 0 n

#print axioms firCircuit_correct

-- El circuito debe reproducir los mismos vectores que la especificación.
#eval (List.range 8).map (eval (firCircuit hQT) impulso)
#eval (List.range 8).map (eval (firCircuit hQT) (fun _ => 1))
