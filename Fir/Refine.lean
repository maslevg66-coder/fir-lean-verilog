import Fir.HDL

/-! # Capa 2b: semántica de ancho finito del MISMO mini-HDL -/

/-- Segunda interpretación de `Expr`: valores en `BitVec w`.
    Esta es la semántica que implementa el Verilog emitido.
    No hay traducción de sintaxis: es el mismo árbol. -/
def evalB (w : Nat) : Expr → (Nat → BitVec w) → Nat → BitVec w
  | .input,   x, n => x n
  | .const c, _, _ => BitVec.ofInt w c
  | .add a b, x, n => evalB w a x n + evalB w b x n
  | .mulc c a, x, n => BitVec.ofInt w c * evalB w a x n
  | .reg a,   x, n => if n = 0 then 0 else evalB w a x (n - 1)

/-- **TEOREMA DE CONGRUENCIA (incondicional).**
    El hardware de `w` bits calcula exactamente el ideal reducido módulo 2^w,
    para toda entrada y todo ciclo. Sin ninguna cota. -/
theorem evalB_ofInt (w : Nat) (e : Expr) (x : Nat → Int) :
    ∀ n : Nat,
      evalB w e (fun k => BitVec.ofInt w (x k)) n
        = BitVec.ofInt w (eval e x n) := by
  induction e with
  | input => intro n; simp [evalB, eval]
  | const c => intro n; simp [evalB, eval]
  | add a b iha ihb =>
      intro n
      simp [evalB, eval, iha n, ihb n, BitVec.ofInt_add]
  | mulc c a ih =>
      intro n
      simp [evalB, eval, ih n, BitVec.ofInt_mul]
  | reg a ih =>
      intro n
      by_cases hn : n = 0
      · simp [evalB, eval, hn]
      · simp [evalB, eval, hn, ih (n - 1)]

#print axioms evalB_ofInt

-- 1) El bus de 16 bits reproduce la respuesta al impulso.
#eval (List.range 8).map
  (fun n => (evalB 16 (firCircuit hQT) (fun k => BitVec.ofInt 16 (impulso k)) n).toInt)

-- 2) Y la rampa de los 64 vectores.
def rampa : Nat → Int := fun k => Int.ofNat (k % 10) - 5
#eval (List.range 8).map
  (fun n => (evalB 16 (firCircuit hQT) (fun k => BitVec.ofInt 16 (rampa k)) n).toInt)

-- 3) DESBORDAMIENTO PROVOCADO: impulso de amplitud 20000.
def impulsoGrande : Nat → Int := fun k => if k = 0 then 20000 else 0

-- El ideal matemático:
#eval (List.range 5).map (fir hQT impulsoGrande)
-- Lo que devuelve el bus de 16 bits:
#eval (List.range 5).map
  (fun n => (evalB 16 (firCircuit hQT)
    (fun k => BitVec.ofInt 16 (impulsoGrande k)) n).toInt)

/-! ## Lectura fiel bajo cota -/

/-- El representante balanceado módulo 2^16 es la identidad en la ventana signed. -/
theorem bmod16_eq_self (v : Int) (h1 : -32768 ≤ v) (h2 : v < 32768) :
    v.bmod 65536 = v := Int.bmod_eq_of_le h1 h2

/-- **TEOREMA DE LECTURA FIEL.** Si el valor ideal cabe en la ventana signed
    de 16 bits, leer el bus como signed devuelve exactamente ese entero. -/
theorem evalB_toInt (e : Expr) (x : Nat → Int) (n : Nat)
    (h1 : -32768 ≤ eval e x n) (h2 : eval e x n < 32768) :
    (evalB 16 e (fun k => BitVec.ofInt 16 (x k)) n).toInt = eval e x n := by
  rw [evalB_ofInt, BitVec.toInt_ofInt]
  exact bmod16_eq_self _ h1 h2

/-- **COTA DEL FILTRO.** Con |x[k]| ≤ 100 y Σ|h[k]| = 6, la salida ideal
    queda en [-600, 600] para todo ciclo. -/
theorem hQT_bound (x : Nat → Int) (hx : ∀ k, -100 ≤ x k ∧ x k ≤ 100) (n : Nat) :
    -600 ≤ fir hQT x n ∧ fir hQT x n ≤ 600 := by
  -- Damos las cotas en AMBAS formas sintácticas del índice: la normalizada
  -- y la que produce `firAux` al incrementar k. omega no las identifica.
  have h0 := hx (n - 0)
  have h1 := hx (n - 1)
  have h2 := hx (n - 2)
  have h3 := hx (n - 3)
  have h4 := hx (n - 4)
  have g1 := hx (n - (0 + 1))
  have g2 := hx (n - (0 + 1 + 1))
  have g3 := hx (n - (0 + 1 + 1 + 1))
  have g4 := hx (n - (0 + 1 + 1 + 1 + 1))
  simp only [hQT, fir, firAux]
  split <;> split <;> split <;> split <;> split <;> omega

/-- **COROLARIO FINAL.** El bus de 16 bits calcula exactamente el FIR
    matemático, para TODA entrada acotada por 100 y TODO ciclo. -/
theorem hQT_16_correct (x : Nat → Int) (hx : ∀ k, -100 ≤ x k ∧ x k ≤ 100) (n : Nat) :
    (evalB 16 (firCircuit hQT) (fun k => BitVec.ofInt 16 (x k)) n).toInt
      = fir hQT x n := by
  have hb := hQT_bound x hx n
  have hc := firCircuit_correct hQT x n
  rw [← firCircuit_correct]
  apply evalB_toInt
  · omega
  · omega

#print axioms hQT_16_correct
