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

| Teorema | Enunciado |
|---|---|
| `firCircuit_correct` | `eval (firCircuit h) x n = fir h x n`, para toda `h`, `x`, `n` |
| `evalB_ofInt` | `evalB w e (ofInt w ∘ x) n = ofInt w (eval e x n)` — **incondicional**, todo `w` |
| `evalB_toInt` | la lectura signed es exacta si el ideal está en `[-2^15, 2^15)` |
| `hQT_bound` | `|x[k]| ≤ 100` implica `|fir hQT x n| ≤ 600` |
| `hQT_16_correct` | el bus de 16 bits devuelve exactamente `fir hQT x n`, para toda entrada acotada por 100 y todo ciclo |

Ninguno depende de `sorryAx`. Los axiomas usados son subconjuntos de
`{propext, Classical.choice, Quot.sound}`, todos estándar. `lake build` imprime
los axiomas de cada teorema; audítalos ahí.

## El desbordamiento, con números

`Fir/Refine.lean` incluye un impulso de amplitud 20000:

    ideal:   [20000,  40000, 0, -40000, -20000]
    bus 16:  [20000, -25536, 0,  25536, -20000]

`40000 - 65536 = -25536`. La congruencia módulo 2^16 **se cumple**: ambos son el
mismo `BitVec 16`. Lo que falla es la lectura signed, porque 40000 no cabe en la
ventana representable. Por eso `evalB_ofInt` no necesita cota y `evalB_toInt` sí.

## Resultados empíricos

- Simulación (Icarus Verilog 12.0): 64/64 vectores generados desde Lean coinciden.
  Un vector corrompido a propósito es detectado.
- Síntesis (Yosys 0.52): 403 celdas, 64 flip-flops, cero multiplicadores
  (los productos por constante se pliegan a desplazamientos y sumas).

## Correr

    make all     # compila Lean, genera Verilog, simula
    make syn     # sintetiza con Yosys y reporta área

Requisitos: elan (Lean 4.20.0 vía `lean-toolchain`), Icarus Verilog, Yosys, make.
Sin Mathlib: no hay dependencias que descargar.

## Frontera de confianza

Lo único no verificado es el **emisor de Verilog** (`Fir/Emit.lean`, ~60 líneas).
La cadena `fir ↔ eval ↔ evalB 16 ↔ lectura signed` está demostrada. El salto de
`evalB 16` al *texto* Verilog está validado por simulación, no probado.

## Trabajo futuro

- Verificar el emisor, o validación por traducción con certificado por instancia.
- Punto fijo Qm.n con cota de error de cuantización demostrada.
- Banco de filtros wavelet (Haar, Daubechies-4) y reconstrucción perfecta.
- Pipelining con prueba de preservación semántica salvo latencia.
