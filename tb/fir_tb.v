`timescale 1ns/1ps

module fir_tb;
  reg clk;
  reg rst;
  reg signed [15:0] x;
  wire signed [15:0] y;

  fir #(.W(16)) dut (.clk(clk), .rst(rst), .x(x), .y(y));

  initial clk = 0;
  always #5 clk = ~clk;

  integer file, status, n, errors;
  integer in_int, exp_int;
  reg signed [15:0] expected_y;

  initial begin
    $dumpfile("build/fir.vcd");
    $dumpvars(0, fir_tb);

    errors = 0;
    rst = 1;
    x = 0;
    $display("=== Iniciando simulacion del FIR ===");

    // Reset SÍNCRONO: dos flancos con rst=1 dejan los registros en 0.
    @(posedge clk); #1;
    @(posedge clk); #1;
    rst = 0;

    file = $fopen("tb/vectors.txt", "r");
    if (file == 0) begin
      $display("ERROR: no se pudo abrir tb/vectors.txt");
      $finish;
    end

    for (n = 0; n < 64; n = n + 1) begin
      status = $fscanf(file, "%d %d", in_int, exp_int);
      if (status != 2) begin
        $display("ERROR: fin de archivo inesperado en ciclo %0d", n);
        $fclose(file);
        $finish;
      end

      // Clave: cambiar x LEJOS del flanco activo.
      @(negedge clk);
      x = in_int;
      expected_y = exp_int;
      #1;   // la lógica combinacional se asienta

      if (y !== expected_y) begin
        $display("ERROR ciclo %0d: x=%0d y=%0d (esperado %0d)", n, x, y, expected_y);
        errors = errors + 1;
      end else begin
        $display("OK ciclo %0d: x=%0d y=%0d", n, x, y);
      end
    end

    $fclose(file);
    $display("=== Fin de la simulacion ===");
    if (errors == 0)
      $display("EXITO: los 64 vectores coinciden con la especificacion de Lean.");
    else
      $display("FALLO: %0d errores encontrados.", errors);
    $finish;
  end
endmodule
