# Del entero ideal al bit: refinamiento verificado de un núcleo DSP en Lean 4

**Aspirante:** [Gustavo Abraham Mas Levario] · Especialidad en Sistemas Digitales
**Programa:** MCC / MCIC, CIC-IPN · LGAC SyTCAD

## 1. Problema
Los núcleos de procesamiento digital se validan hoy por simulación con un
conjunto finito de vectores. La corrección se argumenta, no se demuestra.
Además, la cadena HDL -> netlist descansa en compiladores no verificados.
Existe trabajo maduro en Coq y HOL4 (Fe-Si, Koika, Lutsig), pero el ecosistema
Lean 4 apenas comienza a aplicarse a hardware.

## 2. Pregunta de investigación
Puede demostrarse en Lean 4 que un filtro FIR emitido a Verilog con buses de
W bits satisface su especificacion sobre enteros, bajo una cota de entrada
explicita, y que el traductor que genera ese Verilog preserva la semantica?

## 3. Objetivo general
Construir y verificar en Lean 4 una cadena completa especificacion -> mini-HDL
-> Verilog para un banco de filtros FIR, con refinamiento demostrado de Int a
BitVec W y verificacion del emisor, culminando en un nucleo de deteccion QRS
evaluado con registros reales y sintetizado en FPGA.

## 4. Objetivos especificos
1. Refinar la semantica del mini-HDL de Int a BitVec W y demostrar el teorema
   de refinamiento bajo la condicion de no desbordamiento sum|h[k]|*B < 2^(W-1).
2. Verificar el emisor: dotar de semantica formal a un subconjunto de Verilog
   y demostrar que el netlist generado es equivalente ciclo a ciclo a `eval`.
3. Extender a punto fijo Qm.n con cota de error de cuantizacion demostrada.
4. Componer un banco Haar/Daubechies-4, demostrar reconstruccion perfecta y
   evaluar el detector QRS sobre MIT-BIH y en FPGA (area, Fmax, latencia).

## 5. Metodologia
Investigacion aplicada de caracter experimental-formal, en cuatro etapas
acumulativas. Cada etapa produce (a) un artefacto en Lean con teoremas sin
`sorry`, auditados con `#print axioms`, y (b) evidencia empirica independiente
por simulacion en Icarus Verilog y sintesis en Yosys. El criterio de exito es
doble: prueba formal verificable por el kernel y coincidencia con simulacion.

## 6. Trabajo preliminar ya realizado
Prototipo funcional de tres capas, disponible en repositorio:
- Especificacion `y[n] = sum h[k]*x[n-k]` sobre enteros.
- Mini-HDL inductivo `Expr` con semantica ciclo a ciclo.
- Teorema `firCircuit_correct` demostrado por induccion generalizada sobre la
  lista de coeficientes; sin `sorryAx` (solo propext y Quot.sound).
- Emisor a Verilog y testbench: 64 vectores generados desde Lean coinciden con
  la simulacion; al corromper un vector, el testbench lo detecta.
- Sintesis Yosys: 403 celdas, 64 flip-flops, sin multiplicadores.
Caso de estudio: derivada del detector QRS de Pan-Tompkins, h = [1,2,0,-2,-1].

## 7. Cronograma (4 semestres)
S1: asignaturas nucleo; objetivo 1 (BitVec); registro del tema.
S2: objetivo 2 (emisor verificado); seminario II.
S3: objetivos 3 y 4 (punto fijo, banco wavelet, MIT-BIH); articulo en congreso.
S4: implementacion FPGA, redaccion de tesis, examen de grado.

## 8. Riesgos y mitigacion
Verificar un emisor completo es ambicioso para una maestria. Mitigacion:
acotar el subconjunto de Verilog y, si el tiempo aprieta, sustituir la prueba
del compilador por *translation validation* (un certificado por instancia).
El objetivo 1 es autocontenido y garantiza un resultado publicable aun si los
objetivos 2 y 4 se recortan.

## 9. Referencias iniciales
- Lutsig: compilador Verilog verificado en HOL4 (Loow, CPP 2021).
- Koika: nucleo de diseno de hardware basado en reglas, en Coq (PLDI 2020).
- Fe-Si: compilador certificado de HDL a circuitos (Braibant y Chlipala).
- Lean 4: bitblasting de BitVec en Init.Data.BitVec.Bitblast.
