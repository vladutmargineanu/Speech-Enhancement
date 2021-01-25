% Implementare factorul de over-substraction alfa

function [overSubstraction] = overSubstractionFactor(valueSNR)
  
  factorSNR = valueSNR;
  
  if valueSNR < (-5)
    factorSNR = (-5);
  else
    if valueSNR > 20
      factorSNR = 20;
    end
  end
  
  overSubstraction = 4 - factorSNR * (3/20);
  
endfunction
