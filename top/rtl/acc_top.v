// Accumulator Top-Level
// Streams two complex coefficient vectors from ROM, multiplies them
// element-wise, stores every 5th real result in RAM, then sums all
// stored values and presents the final accumulation on sum_out.

module acc_top #(
  parameter AW       = 7,   // Address width (covers DEPTH entries)
  parameter IW       = 6,   // Input data width (per ROM word)
  parameter DEPTH    = 100, // Number of coefficient pairs
  parameter OW       = 12   // Output / accumulator width
) (
  input  wire                    clk,
  input  wire                    rst_n,
  input  wire                    go,        // Single-cycle start pulse
  output reg  signed [OW-1:0]   sum_out,   // Accumulated result
  output wire                    result_vld // Pulses while sum_out is updating
);

  
  // Input-valid pipeline
  reg  iv;        // Input valid (active while reading ROM)
  reg  iv_d;      // One-cycle delayed iv (feeds multiplier)

  // ROM address counter
  reg [AW-1:0] rom_ptr;
  wire         rom_rd_en;

  // ROM outputs
  wire signed [IW-1:0] c1_re, c1_im;   // Coefficient vector 1
  wire signed [IW-1:0] c2_re, c2_im;   // Coefficient vector 2

  // Multiplier handshake
  wire                      mul_din_vld;
  wire                      mul_dout_vld;
  wire signed [OW-1:0]      mul_re;     // Real part of product
  wire signed [OW-1:0]      mul_im;     // Imaginary part (unused in sum)

  // RAM bookkeeping
  reg  [AW-1:0] wr_cnt;          // Counts multiplier outputs (0-4 cycle)
  wire signed [OW-1:0] ram_din;
  wire signed [OW-1:0] ram_dout;

  reg  wr_en;
  reg  wr_en_r;
  reg  rd_en;
  reg  [AW-1:0] wr_addr;
  reg  [AW-1:0] rd_addr;
  reg  [AW-1:0] ram_addr;
  reg  wr_done;                  // All 20 results written

  reg  rd_en_d, rd_en_d2;

 
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      iv   <= 1'b0;
      iv_d <= 1'b0;
    end else begin
      iv_d <= iv;
      if (go)
        iv <= 1'b1;
      if (rom_ptr == DEPTH - 1)
        iv <= 1'b0;
    end
  end

  // ROM address counter
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      rom_ptr <= 'd0;
    end else begin
      if (rom_rd_en)
        rom_ptr <= rom_ptr + 'd1;
      if (rom_ptr == DEPTH - 1)
        rom_ptr <= 'd0;
    end
  end

  assign rom_rd_en    = iv;
  assign mul_din_vld  = iv_d;

  // -----------------------------------------------------------------------
  // ROM instances – four channels (c1 real, c1 imag, c2 real, c2 imag)
  // -----------------------------------------------------------------------
  coeff_rom #(.AW(AW), .DW(IW), .DEPTH(DEPTH), .MEM_FILE("../rom/n1_real.txt"))
    u_rom_c1_re (.clk(clk), .rd_addr(rom_ptr), .rd_en(rom_rd_en), .rd_data(c1_re));

  coeff_rom #(.AW(AW), .DW(IW), .DEPTH(DEPTH), .MEM_FILE("../rom/n1_imag.txt"))
    u_rom_c1_im (.clk(clk), .rd_addr(rom_ptr), .rd_en(rom_rd_en), .rd_data(c1_im));

  coeff_rom #(.AW(AW), .DW(IW), .DEPTH(DEPTH), .MEM_FILE("../rom/n2_real.txt"))
    u_rom_c2_re (.clk(clk), .rd_addr(rom_ptr), .rd_en(rom_rd_en), .rd_data(c2_re));

  coeff_rom #(.AW(AW), .DW(IW), .DEPTH(DEPTH), .MEM_FILE("../rom/n2_imag.txt"))
    u_rom_c2_im (.clk(clk), .rd_addr(rom_ptr), .rd_en(rom_rd_en), .rd_data(c2_im));

  // -----------------------------------------------------------------------
  // Complex multiplier instance
  // -----------------------------------------------------------------------
  cplx_mult #(.A_DW(IW), .B_DW(IW), .CONJ(0)) u_mul (
    .clk      (clk),
    .rst_n    (rst_n),
    .a_re     (c1_re),
    .a_im     (c1_im),
    .b_re     (c2_re),
    .b_im     (c2_im),
    .din_vld  (mul_din_vld),
    .out_re   (mul_re),
    .out_im   (mul_im),
    .dout_vld (mul_dout_vld)
  );

  // -----------------------------------------------------------------------
  // RAM write control – store every 5th multiplier output (wr_cnt rolls 0-4)
  // -----------------------------------------------------------------------
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      wr_cnt   <= 'd0;
      wr_en    <= 'd0;
      wr_en_r  <= 'd0;
      wr_addr  <= 'd0;
      rd_addr  <= 'd0;
      wr_done  <= 1'b0;
      rd_en    <= 1'b0;
      rd_en_d  <= 1'b0;
      rd_en_d2 <= 1'b0;
      sum_out  <= 'd0;
    end else begin
      rd_en_d  <= rd_en;
      rd_en_d2 <= rd_en_d;

      // Count multiplier outputs; latch on count == 3 (4th beat)
      if (mul_dout_vld)
        wr_cnt <= wr_cnt + 'd1;

      if (wr_cnt == 'd3) begin
        wr_en   <= 1'b1;
        wr_en_r <= 1'b1;
      end else if (wr_cnt == 'd4) begin
        wr_cnt  <= 'd0;
        wr_en   <= 1'b0;
        wr_en_r <= 1'b0;
      end

      if (wr_en)
        wr_addr <= wr_addr + 'd1;

      // All 20 entries written?
      if (wr_addr == 'd20) begin
        wr_done <= 1'b1;
        rd_addr <= 'd0;
      end

      // Clear wr_done on next go
      if (go)
        wr_done <= 1'b0;

      // Read phase
      if (wr_done) begin
        rd_en   <= 1'b1;
        wr_en_r <= 1'b0;
      end

      if (rd_en)
        rd_addr <= rd_addr + 'd1;

      // Accumulate RAM output
      if (rd_en_d)
        sum_out <= sum_out + ram_dout;
    end
  end

  assign result_vld = rd_en_d2;
  assign ram_din    = mul_re;

  // RAM address mux
  always @(*) begin
    if (wr_en)
      ram_addr = wr_addr;
    else if (rd_en)
      ram_addr = rd_addr;
    else
      ram_addr = 'd0;
  end

  // -----------------------------------------------------------------------
  // Single-port RAM instance
  // -----------------------------------------------------------------------
  spram #(.AW(AW), .DW(OW), .DEPTH(DEPTH)) u_ram (
    .clk     (clk),
    .addr    (ram_addr),
    .wr_data (ram_din),
    .cs      (1'b1),
    .wren    (wr_en_r),
    .rd_data (ram_dout)
  );

endmodule
