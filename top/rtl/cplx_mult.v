// Complex Multiplier
// Performs (Ar + j*Ai) * (Br + j*Bi)
// Optional conjugate mode on second operand

module cplx_mult #(
  parameter A_DW = 17,   // Bit-width of operand A
  parameter B_DW = 17,   // Bit-width of operand B
  parameter CONJ = 0     // 0 = normal, 1 = conjugate B before multiply
) (
  input  wire                       clk,
  input  wire                       rst_n,
  // Operand A
  input  wire signed [A_DW-1:0]    a_re,
  input  wire signed [A_DW-1:0]    a_im,
  // Operand B
  input  wire signed [B_DW-1:0]    b_re,
  input  wire signed [B_DW-1:0]    b_im,
  // Input handshake
  input  wire                       din_vld,
  // Result
  output reg  signed [A_DW+B_DW-1:0] out_re,
  output reg  signed [A_DW+B_DW-1:0] out_im,
  output reg                        dout_vld
);

  // Pipeline stage 1 – partial products
  reg signed [A_DW+B_DW-1:0] pp_rere;
  reg signed [A_DW+B_DW-1:0] pp_reim;
  reg signed [A_DW+B_DW-1:0] pp_imre;
  reg signed [A_DW+B_DW-1:0] pp_imim;
  reg                          vld_pipe;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      pp_rere  <= 0;
      pp_reim  <= 0;
      pp_imre  <= 0;
      pp_imim  <= 0;
      vld_pipe <= 0;
    end else begin
      vld_pipe <= din_vld;
      if (din_vld) begin
        pp_rere <= a_re * b_re;
        pp_reim <= a_re * b_im;
        pp_imre <= a_im * b_re;
        pp_imim <= a_im * b_im;
      end
    end
  end

  // Pipeline stage 2 – combine partial products
  always @(*) begin
    dout_vld = vld_pipe;
    if (CONJ) begin
      // (Ar+jAi)(Br-jBi) = ArBr+AiBi + j(AiBr-ArBi)
      out_re = pp_rere + pp_imim;
      out_im = pp_imre - pp_reim;
    end else begin
      // (Ar+jAi)(Br+jBi) = ArBr-AiBi + j(AiBr+ArBi)
      out_re = pp_rere - pp_imim;
      out_im = pp_imre + pp_reim;
    end
  end

endmodule
