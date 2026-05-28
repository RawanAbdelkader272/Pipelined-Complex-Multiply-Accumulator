# Pipelined Complex Multiply Accumulator Algorithm — Modelling & FPGA Implementation

This project implements a hardware accelerator that performs complex multiplication on two coefficient vectors, stores every 5th result, and accumulates the stored values.
### What This Design Does
Reads **100 complex-number pairs** stored in ROM, passes them through a **pipelined complex multiplier**, selects every 5th real-part output (giving 20 values), stores them in a single-port RAM, then **accumulates all 20 intoa single signed integer** — fully in hardware at 100 MHz.

### Pipeline Latency
- ROM read: 1 cycle
- Complex multiplier: 2 cycles
- Total from ROM to valid product: 3 cycles

### Data Flow
```
ROM (4 channels) → Complex Multiplier → Every-5th Selector → RAM → Accumulator
   n1_re/n1_im         (c1 × c2)           (wr_cnt 0-4)      (20     (sum_out)
   n2_re/n2_im                                               entries)
```

### Key Specifications
- **Input Vectors**: 100 complex coefficient pairs
- **Storage Strategy**: Every 5th real product (20 values total)
- **Clock Frequency**: 100 MHz (10 ns period)
- **Data Widths**:
  - ROM Input: 6-bit signed per component
  - Multiplier Output: 12-bit signed
  - Accumulator: 12-bit signed

### Algorithm
For k = 1 to 100:
1. Read n1[k] = (n1_re + j·n1_im) from ROM
2. Read n2[k] = (n2_re + j·n2_im) from ROM
3. Compute product = n1[k] × n2[k]
4. If (k mod 5 == 0): store real(product) in RAM
5. After all writes: sum all 20 RAM values

### Pre-computation
`n1` and `n2` are pre-computed in **MATLAB** (`gen_rom_data.m`) and stored as 6-bit binary text files loaded into ROM at simulation time via`$readmemb`.

---

## Project Structure

```
Pipelined-Complex-Multiply-Accumulator/
├── matlab/
│   ├── gen_rom_data.m         # MATLAB script for ROM generation
│   ├── n1_real.txt            # Generated ROM data (coefficient 1 real)
│   ├── n1_imag.txt            # Generated ROM data (coefficient 1 imag)
│   ├── n2_real.txt            # Generated ROM data (coefficient 2 real)
│   ├── n2_imag.txt            # Generated ROM data (coefficient 2 imag)
│   └── out_result.txt         # Reference output for verification
│
└── top/
    ├── rom/                       ← ROM init files (binary)
    ├── rtl/
    │   ├── acc_top.v              # Top-level accumulator module
    │   ├── coeff_rom.v            # Synchronous ROM with $readmemb initialization
    │   ├── cplx_mult.v            # Pipelined complex multiplier
    │   └── spram.v                # Single-port synchronous RAM
    └── tb/
    │   ├── acc_top_tb.v           # self-checking testbench
    │   ├── run.do                 # QuestaSim compile & run script
    │   └── wave.do                # Waveform configuration
    └──
```




## Simulation Results - Simulator: QuestaSim-64 2021.1

| # | Time (ns) | `sum_out` | Status |
|---|---|---|---|
| 1 | 2085 | -2 | ✅ PASS |
| 2 | 2095 | -4 | ✅ PASS |
| 3 | 2105 | -3 | ✅ PASS |
| 4 | 2115 | -3 | ✅ PASS |
| 5 | 2125 | -7 | ✅ PASS |
| 6 | 2135 | -11 | ✅ PASS |
| 7 | 2145 | -15 | ✅ PASS |
| 8 | 2155 | -14 | ✅ PASS |
| 9 | 2165 | -14 | ✅ PASS |
| 10 | 2175 | -19 | ✅ PASS |
| 11 | 2185 | -24 | ✅ PASS |
| 12 | 2195 | -28 | ✅ PASS |
| 13 | 2205 | -27 | ✅ PASS |
| 14 | 2215 | -27 | ✅ PASS |
| 15 | 2225 | -33 | ✅ PASS |
| 16 | 2235 | -38 | ✅ PASS |
| 17 | 2245 | -43 | ✅ PASS |
| 18 | 2255 | -42 | ✅ PASS |
| 19 | 2265 | -42 | ✅ PASS |

### Final Results
- **Total Valid Outputs**: 20
- **Final Accumulated Value**: -42
- **All Tests**: ✅ PASS

## Waveform Signals
![Simulation Results](../{sim_results}.png)
Key signals to monitor:
- `/acc_top_tb/u_dut/rom_ptr` - ROM address counter (0-99)
- `/acc_top_tb/u_dut/wr_cnt` - Write counter (0-4, rolls every 5th)
- `/acc_top_tb/u_dut/wr_addr` - RAM write address (0-19)
- `/acc_top_tb/u_dut/rd_addr` - RAM read address (0-19)
- `/acc_top_tb/u_dut/ram_dout` - Data read from RAM
- `/acc_top_tb/u_dut/sum_out` - Running accumulation
- `/acc_top_tb/result_vld` - Pulses when sum_out updates









