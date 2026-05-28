
%% ==========================================================================
%% Purpose  : Generates binary ROM initialisation files and a reference
%%            output file used by the hardware testbench.
%%
%% Algorithm
%%   For each index k = 1 … 100:
%%     n1(k) = abs(floor(cos(k))) + j*abs(floor(sin(k)))
%%     n2(k) = floor(log10(k))   + j*floor(log2(k))
%%     prod  = n1(k) * n2(k)
%%
%%   Every 5th product (k mod 5 == 0) → store real(prod) in z array.
%%   After the loop, output the running sum of z into out_result.txt.
%% ==========================================================================

clc;
clear all;

%% ---- Output file names ---------------------------------------------------
f_n1_re   = "n1_real.txt";
f_n1_im   = "n1_imag.txt";
f_n2_re   = "n2_real.txt";
f_n2_im   = "n2_imag.txt";
f_ref_out = "out_result.txt";

%% ---- Open files for writing ----------------------------------------------
fh_n1_re   = fopen(f_n1_re,   "w");
fh_n1_im   = fopen(f_n1_im,   "w");
fh_n2_re   = fopen(f_n2_re,   "w");
fh_n2_im   = fopen(f_n2_im,   "w");
fh_ref_out = fopen(f_ref_out, "w");

%% ---- Configuration -------------------------------------------------------
WORD_BITS = 6;   % ROM word width in bits

%% ---- Main generation loop ------------------------------------------------
store_idx   = 1;
accum       = 0;

for k = 1 : 1 : 100

  %% Operand 1 : trig-based complex number
  n1 = abs(floor(cos(k))) + 1i * abs(floor(sin(k)));
  fprintf(fh_n1_re, '%d\n', str2num(dec2bin(real(n1), WORD_BITS)));
  fprintf(fh_n1_im, '%d\n', str2num(dec2bin(imag(n1), WORD_BITS)));

  %% Operand 2 : log-based complex number
  n2 = floor(log10(k)) + 1i * floor(log2(k));
  fprintf(fh_n2_re, '%d\n', str2num(dec2bin(real(n2), WORD_BITS)));
  fprintf(fh_n2_im, '%d\n', str2num(dec2bin(imag(n2), WORD_BITS)));

  %% Complex multiplication
  cx_prod = n1 * n2;

  %% Capture every 5th real result
  if (mod(k, 5) == 0)
    z(store_idx) = real(cx_prod);
    store_idx    = store_idx + 1;
  endif

endfor

%% ---- Close ROM files -----------------------------------------------------
fclose(fh_n1_re);
fclose(fh_n1_im);
fclose(fh_n2_re);
fclose(fh_n2_im);

%% ---- Write running-sum reference output ----------------------------------
for m = 1 : length(z)
  accum = accum + z(m);
  fprintf(fh_ref_out, '%d\n', accum);
endfor

fclose(fh_ref_out);
