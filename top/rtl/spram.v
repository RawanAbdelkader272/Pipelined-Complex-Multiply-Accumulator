// Single-port synchronous RAM
// Write and read are mutually exclusive (wren selects direction)

module spram #(
  parameter AW    = 4,    // Address width
  parameter DW    = 32,   // Data width
  parameter DEPTH = 16    // Number of entries
) (
  input  wire           clk,
  input  wire [AW-1:0]  addr,
  inout  wire [DW-1:0]  wr_data,   // Data to write
  input  wire           cs,        // Chip select (active-high)
  input  wire           wren,      // 1 = write, 0 = read
  output reg  [DW-1:0]  rd_data    // Data read out
);

  reg [DW-1:0] mem [0:DEPTH-1];

  // Write port
  always @(posedge clk) begin
    if (cs && wren)
      mem[addr] <= wr_data;
  end

  // Read port
  always @(posedge clk) begin
    if (cs && !wren)
      rd_data <= mem[addr];
  end

endmodule
