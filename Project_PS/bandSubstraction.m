% Calculam factorul delta - band substraction factor 
% Se foloseste doar in algoritmul MBSS
function [deltaVector] = bandSubstraction(hanningFrameSize, samplingFreq, numberBands)
  
  # Calculez frecventa de sampling in functie de banda
  bandFreq = zeros(1, numberBands);
  
  # Initializez pentru toate benzile
  for i = 1:numberBands
    
    bandFreq(1, i) = samplingFreq * (i / numberBands);
    
  endfor
  
  # Numarul total de sample-uri pe o banda
  numberSampleBands = floor(hanningFrameSize / (2 * numberBands));
  
  # Initializam vectorul auxiliar pentru fiecare banda
  deltaVectorAux2 = zeros(1, numberSampleBands * numberBands);
  
  # Initializam vectorul de iesire 
  deltaVector = 1.5 .* ones(1, hanningFrameSize);
  
  # Calculam band substraction dupa formula
  deltaVectorAux = bandFreq <= 1000;
  deltaVectorAux = deltaVectorAux + 2.5 .* ((1000 < bandFreq) .* (bandFreq <= samplingFreq / 2 - 2000));
  deltaVectorAux = deltaVectorAux + 1.5 * ((samplingFreq / 2 - 2000 < bandFreq));
    
  for i = 1:numberBands
    for j = 1:numberSampleBands
        deltaVectorAux2((i - 1) * numberSampleBands + j) = deltaVectorAux(i); 
    endfor
  endfor
  
  deltaVector(1:numberBands * numberSampleBands) = deltaVectorAux2;
  % flip - returneaza o copie a elementelor rasturnate
  deltaVector(end - (numberBands * numberSampleBands - 1):end) = flip(deltaVectorAux2, 2);
  
endfunction
