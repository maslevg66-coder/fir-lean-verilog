// Generado automaticamente desde Lean 4. NO editar a mano.
// Emitidor confiado: validado por simulacion con Icarus Verilog.
module fir #(parameter W = 16) (
  input  wire clk,
  input  wire rst,
  input  wire signed [W-1:0] x,
  output wire signed [W-1:0] y
);
  wire signed [W-1:0] w0, w1, w2, w3, w4, w5, w7, w9, w11, w13, w15;
  reg  signed [W-1:0] r6, r8, r10, r12, r14;
  assign w0 = 1 * x;
  assign w1 = 2 * x;
  assign w2 = 0 * x;
  assign w3 = (-2) * x;
  assign w4 = (-1) * x;
  assign w5 = 0;
  assign w7 = w4 + r6;
  assign w9 = w3 + r8;
  assign w11 = w2 + r10;
  assign w13 = w1 + r12;
  assign w15 = w0 + r14;

  always @(posedge clk) begin
    if (rst) r6 <= 0;
    else     r6 <= w5;
  end
  always @(posedge clk) begin
    if (rst) r8 <= 0;
    else     r8 <= w7;
  end
  always @(posedge clk) begin
    if (rst) r10 <= 0;
    else     r10 <= w9;
  end
  always @(posedge clk) begin
    if (rst) r12 <= 0;
    else     r12 <= w11;
  end
  always @(posedge clk) begin
    if (rst) r14 <= 0;
    else     r14 <= w13;
  end
  assign y = w15;
endmodule
