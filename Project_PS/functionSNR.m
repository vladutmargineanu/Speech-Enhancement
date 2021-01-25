% Implementare factor SNR

function [valueSNR] = functionSNR(MatrixFrame, noiseVector)
  % log a/b = log a - log b
  valueSNR = 10 * log10(sum(MatrixFrame)) - 10 * log10(sum(noiseVector));

endfunction
