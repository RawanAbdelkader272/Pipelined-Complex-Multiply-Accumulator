// Single-port synchronous ROM
// Initialised at elaboration time from a text file (binary format)

module coeff_rom #(
  parameter AW        = 4,          // Address width
  parameter DW        = 32,         // Data width
  parameter DEPTH     = 16,         // Number of entries
  parameter MEM_FILE  = "mem.txt"   // Initialisation file (binary)
) (
  input  wire           clk,
  input  wire [AW-1:0]  rd_addr,
  input  wire           rd_en,
  output reg  [DW-1:0]  rd_data
);

  reg [DW-1:0] lut [0:DEPTH-1];

  initial begin
    $readmemb(MEM_FILE, lut);
  end

  always @(posedge clk) begin
    if (rd_en)
      rd_data <= lut[rd_addr];
  end

endmodule
