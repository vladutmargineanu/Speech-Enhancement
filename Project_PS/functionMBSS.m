% Implementare metoda MBSS

function [signalMBSS] = functionMBSS(MatrixFrame, hanningSize, samplingFreq)
  
  numberBands = 8;              # numarul de benzi folosite in algoritm
  spectralFloorBeta = 0.01;     # parametrul spectral floor 
  noiseTotalAprox = 10;         # aproximarea zgomotului de intrare
  
  % Calculez zgomotul de la inceput, o estimare al zgomotului prezent in speech signal
  noiseVector = MatrixFrame(:, 1)';    # primul vector coloana din matrice (zgomotul)
  signalMBSS = MatrixFrame;
  
  sizeMatrixFrame = size(MatrixFrame);
  
  % Calculez zgomotul mediu pe tot semnalul
  sizeFrame = size(MatrixFrame);
  powerNoise = sum(MatrixFrame(:, 1))/sizeFrame(1);       # primul vector din matrice
  powerSpeechSignal = sum(MatrixFrame(:, 2:11))/(10 * sizeFrame(1));
  
  % Calculze SNR global, pentru verificarea zgomotului in fiecare frame
  globalSNRValue = functionSNR(powerSpeechSignal, powerSpeechSignal);
  
  % Calculez factorul band-substraction - beta
  [bandSubstractionFactor] = bandSubstraction(hanningSize, samplingFreq, numberBands);
  
  for i = [2:sizeMatrixFrame(2)]
   
    % Verific pentru frame-ul curent
    snrValue = functionSNR(MatrixFrame(:, i), noiseVector);
    
    % Actualizez noise frame-ul daca este cazul
    noiseVectorNext = noiseVector;
    
    isSpeech = 0;
    
    % Verific daca frame-ul curent contine mai mult zgomot sau speech
    if snrValue > globalSNRValue
      isSpeech = 1;
    else
      noiseVectorNext = MatrixFrame(:, i)';
    endif
    
    # Aflam factorul alfa - over substraction factor
    [overSubstraction] = overSubstractionFactor(snrValue);
    
    if isSpeech == 1
     
      # Aplicam formula mtodei MBSS
      signalMBSS(:, i) = MatrixFrame(:, i) - (overSubstraction .* bandSubstractionFactor .* noiseVector)';
      
      # Verificam valorile negative din spectru - spectral floor
      signalMBSS(:, i) = spectralFloor(signalMBSS(:, i), noiseVector, spectralFloorBeta);
      
    else
      
      # Calculam noul frame cu zgomot (la fiecare banda, updatam noise frame-ul)
      noiseVector = ((noiseTotalAprox - 1) / noiseTotalAprox) .* noiseVector + (1 / noiseTotalAprox) .* noiseVectorNext;
      
      # Aplicam formula mtodei MBSS
      signalMBSS(:, i) = MatrixFrame(:, i) - (overSubstraction .* bandSubstractionFactor .* noiseVector)';
      
      # Verificam valorile negative din spectru - spectral floor
      signalMBSS(:, i) = spectralFloor(signalMBSS(:, i), noiseVector, spectralFloorBeta);
      
      # Plotam spectrul semnalului zgomotos
      figure 4;
      plot(noiseVector);
      hold on;
      title('Noise Power Spectral MBSS');
    endif
   
  endfor
  
endfunction

