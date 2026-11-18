# FIR verificado en Lean 4 → Verilog

Cadena de verificación formal de un núcleo DSP: de la especificación matemática
al bus de 16 bits, con generación de Verilog validada por simulación.

Caso de estudio: derivada del detector QRS de Pan-Tompkins, `h = [1, 2, 0, -2, -1]`.

## Capas

| Capa | Archivo | Contenido |
|---|---|---|
| 1. Especificación | `Fir/Spec.lean` | `y[n] = Σ h[k]·x[n-k]` sobre `Int` |
| 2. Mini-HDL | `Fir/HDL.lean` | `Expr`, `eval`, `firCircuit` |
| 2b. Ancho finito | `Fir/Refine.lean` | `evalB w` sobre `BitVec w`, refinamiento |
| 3. Emisor | `Fir/Emit.lean` | traducción a Verilog (confiado) |

## Teoremas

Enunciados esenciales (omitidos los cuantificadores universales):

```lean
firCircuit_correct : eval (firCircuit h) x n = fir h x n

evalB_ofInt        : evalB w e (fun k => BitVec.ofInt w (x k)) n
                       = BitVec.ofInt w (eval e x n)

evalB_toInt        : -32768 ≤ eval e x n → eval e x n < 32768 →
                     (evalB 16 e (fun k => BitVec.ofInt 16 (x k)) n).toInt
                       = eval e x n

hQT_bound          : (∀ k, -100 ≤ x k ∧ x k ≤ 100) →
                     -600 ≤ fir hQT x n ∧ fir hQT x n ≤ 600

hQT_16_correct     : (∀ k, -100 ≤ x k ∧ x k ≤ 100) →
                     (evalB 16 (firCircuit hQT)
                        (fun k => BitVec.ofInt 16 (x k)) n).toInt = fir hQT x n
