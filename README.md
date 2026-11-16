# FIR verificado en Lean 4 → Verilog

Prototipo de verificación formal de hardware en tres capas.

1. **Especificación** (`Fir/Spec.lean`): `y[n] = Σ h[k]·x[n-k]` sobre enteros.
2. **Mini-HDL** (`Fir/HDL.lean`): tipo inductivo `Expr` con semántica ciclo a ciclo.
   Teorema `firCircuit_correct`: el circuito implementa la especificación para
   **toda** lista de coeficientes, **toda** entrada y **todo** ciclo. Sin `sorry`.
3. **Emisor** (`Fir/Emit.lean`): traduce `Expr` a Verilog. Código confiado,
   validado por simulación contra 64 vectores generados desde Lean.

Ejemplo: derivada del detector QRS de Pan-Tompkins, `h = [1, 2, 0, -2, -1]`.

## Correr
    make all     # compila Lean, genera Verilog, simula
    make syn     # sintetiza con Yosys y reporta área

## Requisitos
elan (Lean 4.20.0 vía `lean-toolchain`), Icarus Verilog, Yosys, make.

## Frontera de confianza (trabajo futuro)
- El emisor de Verilog no está verificado, solo validado por simulación.
- El teorema vale sobre `Int` ideal; el hardware es módulo 2^16. Coinciden
  mientras no haya desbordamiento. Falta refinar a `BitVec W` con cota de entrada.
