# De la especificación al RTL verificado: validación por traducción y
# refinamiento a punto fijo de núcleos DSP en Lean 4

**Aspirante:** [nombre] · Especialidad en Sistemas Digitales
**Programa:** MCIC, CIC-IPN · LGAC SyTCAD
**Laboratorio:** Microtecnología y Sistemas Embebidos (MICROSE)

## 1. Problema y encaje institucional
El CIC desarrolla una metodología de verificación de hardware con UVM
(SIP 2026). UVM verifica por simulación: cobertura de escenarios y estímulos
aleatorios restringidos; no establece corrección para todas las entradas.
La verificación deductiva cubre ese hueco y es complementaria, no sustituta.
Este trabajo propone cerrar formalmente el último salto de una cadena
especificación -> RTL y aportar certificados verificables por instancia.

## 2. Pregunta de investigación
Puede cerrarse formalmente el salto del modelo de bits al texto Verilog
mediante validación por traducción con certificados comprobables en Lean,
y extenderse el refinamiento ya demostrado a punto fijo con cota de error
de cuantización?

## 3. Objetivo general
Completar una cadena verificada de especificación matemática a RTL para
núcleos DSP, verificando el emisor de Verilog y refinando la aritmética a
punto fijo, y evaluarla como complemento deductivo del flujo de verificación
por simulación, con un núcleo de detección QRS en FPGA.

## 4. Objetivos específicos
1. Dotar de semántica formal a un subconjunto de Verilog y demostrar que el
   netlist emitido es equivalente ciclo a ciclo a `evalB`. Alternativa
   acotada: validación por traducción, con un certificado por instancia
   descargable a `bv_decide` (bitblasting con certificado SAT verificado
   dentro de Lean).
2. Refinar a punto fijo Qm.n y demostrar una cota del error de cuantización
   respecto de la especificación sobre enteros.
3. Componer un banco de filtros wavelet (Haar, Daubechies-4) y demostrar la
   propiedad de reconstrucción perfecta; construir el núcleo QRS.
4. Evaluar el núcleo: comparar cobertura y costo contra un flujo basado en
   simulación, sintetizar en FPGA (área, Fmax, latencia) y medir el detector
   QRS sobre registros MIT-BIH.

## 5. Metodología
Investigación aplicada, formal-experimental, en etapas acumulativas. Cada
etapa entrega (a) artefactos en Lean auditados con `#print axioms` y sin
`sorryAx`, y (b) evidencia empírica independiente por simulación en Icarus
Verilog y síntesis en Yosys. Criterio de éxito doble: prueba aceptada por el
kernel y coincidencia con simulación.

## 6. Trabajo preliminar concluido
Repositorio público, reproducible con `make all`. Sin Mathlib. Lean 4.20.0
anclado por `lean-toolchain`. Teoremas demostrados, ninguno con `sorryAx`:

- `firCircuit_correct`: el circuito del mini-HDL calcula la especificación
  `y[n] = sum h[k]*x[n-k]` para toda lista de coeficientes, toda entrada y
  todo ciclo. Inducción generalizada sobre el índice de la cola de la suma.
- `evalB_ofInt`: **congruencia incondicional**, para todo ancho `w`. La
  semántica de `BitVec w` es exactamente la ideal reducida módulo 2^w. No
  requiere ninguna cota de entrada.
- `evalB_toInt` + `hQT_bound`: **lectura fiel**. Si |x[k]| <= 100 entonces
  |y[n]| <= 600 < 2^15, y leer el bus como signed devuelve exactamente el
  entero ideal. Corolario `hQT_16_correct`.
- Axiomas usados: subconjuntos de {propext, Classical.choice, Quot.sound}.

Evidencia empírica: 64/64 vectores generados desde Lean coinciden con la
simulación; un vector corrompido a propósito es detectado. Síntesis Yosys:
403 celdas, 64 flip-flops, cero multiplicadores.

Experimento de desbordamiento incluido: con impulso de amplitud 20000 el
ideal da 40000 y el bus de 16 bits da -25536 (= 40000 - 65536). La
congruencia módulo 2^16 se cumple; lo que falla es la lectura signed. Esto
separa con precisión los dos teoremas y muestra por qué solo uno necesita
cota.

Durante el desarrollo, el oráculo formal detectó un error de temporización
en el testbench que la inspección de la simulación no había revelado:
evidencia directa de la complementariedad entre ambos métodos.

**Frontera de confianza restante:** el emisor de Verilog (~60 líneas) es
código confiado, validado por simulación y no probado. Es el objetivo 1.

## 7. Cronograma (ingreso B27, agosto 2027)
S1 (ago-dic 2027): núcleo académico; semántica del subconjunto de Verilog;
                   registro del tema.
S2 (ene-jun 2028): objetivo 1 cerrado; objetivo 2 (punto fijo); seminario II.
S3 (ago-dic 2028): objetivo 3 (wavelet, QRS, MIT-BIH); artículo en congreso.
S4 (ene-jun 2029): objetivo 4 (FPGA y comparación), tesis, examen de grado.

## 8. Riesgos y mitigación
Verificar un emisor completo excede una maestría. Mitigación: acotar el
subconjunto de Verilog y sustituir la prueba del compilador por validación
por traducción, que produce un certificado por instancia y es estrictamente
más débil pero suficiente en la práctica. El objetivo 2 es autocontenido y
garantiza resultado publicable aun recortando 1, 3 y 4. La comparación con
UVM del objetivo 4 es la parte más recortable.

## 9. Referencias iniciales
- Lutsig: compilador Verilog verificado en HOL4 (Lööw, CPP 2021).
- Kôika: núcleo de diseño de hardware basado en reglas, en Coq (PLDI 2020).
- Fe-Si: compilador certificado de HDL a circuitos (Braibant y Chlipala).
- CircuitProver: marco de verificación de hardware en Lean 4 (2026).
- Lean 4: bitblasting de BitVec y verificación de certificados SAT.
