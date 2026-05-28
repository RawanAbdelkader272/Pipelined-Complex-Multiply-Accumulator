// Testbench for acc_top
// Drives reset + go pulse, then checks each sum_out against
// the reference file out_result.txt cycle by cycle.

`timescale 1ns/1ps

module acc_top_tb;


  // Parameters
  parameter CLK_HALF  = 5;      // Half clock period (ns) → 100 MHz
  parameter AW        = 7;
  parameter IW        = 6;
  parameter DEPTH     = 100;
  parameter OW        = 12;
  parameter MAX_OUTS  = 19;     // Expected number of valid outputs

  // DUT signals
  reg  clk;
  reg  rst_n;
  reg  go;
  wire signed [OW-1:0] sum_out;
  wire                  result_vld;

  
  // Checker signals
  reg  [100*8:0]        ref_path;
  integer               ref_fid;
  integer               scan_ok;
  integer               vld_cnt;
  reg  signed [OW-1:0]  ref_val;

  // Clock generator
  initial clk = 0;
  always #CLK_HALF clk = ~clk;

  // DUT instantiation
  
  acc_top #(
    .AW    (AW),
    .IW    (IW),
    .DEPTH (DEPTH),
    .OW    (OW)
  ) u_dut (
    .clk        (clk),
    .rst_n      (rst_n),
    .go         (go),
    .sum_out    (sum_out),
    .result_vld (result_vld)
  );
  
  // Stimulus
  initial begin
    $display("===== Simulation start =====");
    vld_cnt = 0;
    rst_n   = 0;
    go      = 0;

    // Assert reset for 100 cycles
    repeat (100) @(posedge clk);
    rst_n = 1;

    // Issue one-cycle go pulse
    @(posedge clk);
    go = 1;
    @(posedge clk);
    go = 0;

    // Open reference file
    $sformat(ref_path, "out_result.txt");
    ref_fid = $fopen(ref_path, "r");
  end


  // Output checker
  always @(posedge clk) begin
    if (result_vld) begin
      vld_cnt = vld_cnt + 1;
      scan_ok = $fscanf(ref_fid, "%d", ref_val);
      if (sum_out === ref_val)
        $display("[%0t] PASS  sum_out=%0d", $time, sum_out);
      else
        $display("[%0t] FAIL  sum_out=%0d  expected=%0d", $time, sum_out, ref_val);
    end

    if (vld_cnt == MAX_OUTS) begin
      $display("===== Simulation end =====");
      $fclose(ref_fid);
      $stop;
    end
  end



endmodule
