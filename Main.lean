import Fir.Emit

def main : IO Unit := do
  -- 1. Generar el Verilog
  let v := verilog (firCircuit hQT)
  IO.FS.writeFile "build/fir.v" v
  IO.println ("build/fir.v escrito (" ++ toString v.length ++ " caracteres)")

  -- 2. Generar 64 vectores de prueba
  -- Entrada: una rampa que oscila entre -5 y 4 (x[n] = (n % 10) - 5)
  let x : Nat → Int := fun k => Int.ofNat (k % 10) - 5
  
  let mut lines : Array String := #[]
  let mut n : Nat := 0
  while n < 64 do
    let in_val := x n
    let out_val := eval (firCircuit hQT) x n
    lines := lines.push (toString in_val ++ " " ++ toString out_val)
    n := n + 1
  
  IO.FS.writeFile "tb/vectors.txt" (String.join (lines.toList.map (· ++ "\n")))
  IO.println "tb/vectors.txt escrito con 64 vectores"
