/-
  Capa 1: especificación matemática del filtro FIR.
  Aquí NO hay hardware: solo y[n] = Σ h[k] · x[n-k].
-/

/-- `firAux h k x n` acumula la suma desde el coeficiente k-ésimo. -/
def firAux : List Int → Nat → (Nat → Int) → Nat → Int
  | [],      _, _, _ => 0
  | c :: cs, k, x, n =>
      (if k ≤ n then c * x (n - k) else 0) + firAux cs (k + 1) x n

/-- El filtro FIR completo. -/
def fir (h : List Int) (x : Nat → Int) (n : Nat) : Int :=
  firAux h 0 x n

/-- Derivada del detector QRS de Pan-Tompkins. -/
def hQT : List Int := [1, 2, 0, -2, -1]

/-- Impulso unitario: x[0] = 1, el resto 0. -/
def impulso : Nat → Int := fun n => if n = 0 then 1 else 0

-- La respuesta al impulso debe ser la propia lista de coeficientes.
#eval (List.range 8).map (fir hQT impulso)

-- Entrada constante 1: la ganancia en DC debe ser 0, porque Σ h[k] = 0.
#eval (List.range 8).map (fir hQT (fun _ => 1))
