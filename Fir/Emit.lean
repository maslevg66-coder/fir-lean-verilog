import Fir.HDL

/-! # Capa 3: emisor de Verilog (CÓDIGO CONFIADO, no verificado) -/

/-- Literal entero en Verilog, con paréntesis si es negativo. -/
def lit (c : Int) : String :=
  if c < 0 then "(-" ++ toString c.natAbs ++ ")" else toString c.natAbs

/-- Une un array de strings con un separador. -/
def joinSep (sep : String) : Array String → String
  | arr =>
      let l := arr.toList
      match l with
      | []        => ""
      | [a]       => a
      | a :: rest => a ++ sep ++ String.intercalate sep rest

/-- Estado del emisor: contador de nombres y arrays de declaraciones. -/
structure EmitState where
  fuel    : Nat := 0
  wires   : Array String := #[]
  regs    : Array String := #[]
  assigns : Array String := #[]
  blocks  : Array String := #[]

def initState : EmitState := ⟨0, #[], #[], #[], #[]⟩

/-- Emite el netlist de `e`. Devuelve el nombre de la señal que porta
    su valor, más el estado con las declaraciones acumuladas. -/
def emit : Expr → EmitState → String × EmitState
  | .input, s => ("x", s)
  | .const c, s =>
      let w := "w" ++ toString s.fuel
      (w, { s with
            fuel    := s.fuel + 1,
            wires   := s.wires.push w,
            assigns := s.assigns.push ("  assign " ++ w ++ " = " ++ lit c ++ ";") })
  | .mulc c a, s =>
      let ea := emit a s
      let s1 := ea.2
      let w  := "w" ++ toString s1.fuel
      (w, { s1 with
            fuel    := s1.fuel + 1,
            wires   := s1.wires.push w,
            assigns := s1.assigns.push
              ("  assign " ++ w ++ " = " ++ lit c ++ " * " ++ ea.1 ++ ";") })
  | .add a b, s =>
      let ea := emit a s
      let eb := emit b ea.2
      let s1 := eb.2
      let w  := "w" ++ toString s1.fuel
      (w, { s1 with
            fuel    := s1.fuel + 1,
            wires   := s1.wires.push w,
            assigns := s1.assigns.push
              ("  assign " ++ w ++ " = " ++ ea.1 ++ " + " ++ eb.1 ++ ";") })
  | .reg a, s =>
      let ea := emit a s
      let s1 := ea.2
      let r  := "r" ++ toString s1.fuel
      (r, { s1 with
            fuel   := s1.fuel + 1,
            regs   := s1.regs.push r,
            blocks := s1.blocks.push
              ("  always @(posedge clk) begin\n" ++
               "    if (rst) " ++ r ++ " <= 0;\n" ++
               "    else     " ++ r ++ " <= " ++ ea.1 ++ ";\n" ++
               "  end") })

/-- Traduce un circuito a un módulo Verilog completo, con buses de W bits. -/
def verilog (e : Expr) : String :=
  let p   := emit e initState
  let out := p.1
  let s   := p.2
  "// Generado automaticamente desde Lean 4. NO editar a mano.\n" ++
  "// Emitidor confiado: validado por simulacion con Icarus Verilog.\n" ++
  "module fir #(parameter W = 16) (\n" ++
  "  input  wire clk,\n" ++
  "  input  wire rst,\n" ++
  "  input  wire signed [W-1:0] x,\n" ++
  "  output wire signed [W-1:0] y\n" ++
  ");\n" ++
  (if s.wires.isEmpty then ""
   else "  wire signed [W-1:0] " ++ joinSep ", " s.wires ++ ";\n") ++
  (if s.regs.isEmpty then ""
   else "  reg  signed [W-1:0] " ++ joinSep ", " s.regs ++ ";\n") ++
  (s.assigns.toList.map (· ++ "\n") |> String.join) ++
  (if s.blocks.isEmpty then "" else "\n") ++
  (s.blocks.toList.map (· ++ "\n") |> String.join) ++
  "  assign y = " ++ out ++ ";\n" ++
  "endmodule\n"
