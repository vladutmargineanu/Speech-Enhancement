% Implementare metoda PSS

function [signalPSS] = functionPSS(MatrixFrame, hanningSize, samplingFreq)
  
  spectralFloorBeta = 0.002;         # parametrul spectral floor beta
  noiseTotalAprox = 10;             # aproximarea zgomotului de intrare
  
  % Calculez zgomotul de la inceput, o estimare al zgomotului prezent in speech signal
  noiseVector = MatrixFrame(:, 1)';    # primul vector coloana din matrice (zgomotul)
  signalPSS = MatrixFrame;
  
  sizeMatrixFrame = size(MatrixFrame);
  
  % Calculez zgomotul mediu pe tot semnalul
 powerAvgNoise = sum(MatrixFrame(:, 1))/sizeMatrixFrame(1);
 powerAvgSpeechSignal = sum(MatrixFrame(:, 2:11)) / (10 * sizeMatrixFrame(1));
 
 % Calculze SNR global, pentru verificarea zgomotului in fiecare frame
 globalSNRValue = functionSNR(powerAvgSpeechSignal, powerAvgNoise);
  
  for i = [2:sizeMatrixFrame(2)]
   
    % Verific pentru frame-ul curent
    snrValue = functionSNR(MatrixFrame(:, i), noiseVector);
    
    % Actualizez noise frame-ul daca este cazul
    noiseVectorNext = noiseVector;
    
    isSpeech = 0;
    
    % Verific daca frame-ul curent contine maimult zgomot sau speech
    if snrValue > globalSNRValue
      isSpeech = 1;
    else
      noiseVectorNext = MatrixFrame(:, i)';
    endif
    
    # Aflam factorul alfa - over substraction factor
    [overSubstraction] = overSubstractionFactor(snrValue);
    
    if isSpeech == 1
     
      # Aplicam formula mtodei MBSS
      signalPSS(:, i) = MatrixFrame(:, i) - (overSubstraction.* noiseVector)';
      
      # Verificam valorile negative din spectru - spectral floor
      signalPSS(:, i) = spectralFloor(signalPSS(:, i), noiseVector, spectralFloorBeta);
      
    else
      
      # Calculam noul frame cu zgomot (updatam noise frame-ul)
      noiseVector = ((noiseTotalAprox - 1) / noiseTotalAprox) .* noiseVector + (1 / noiseTotalAprox) .* noiseVectorNext;
      
      # Aplicam formula mtodei PSS
      signalPSS(:, i) = MatrixFrame(:, i) - (overSubstraction .* noiseVector)';
      
      # Verificam valorile negative din spectru - spectral floor
      signalPSS(:, i) = spectralFloor(signalPSS(:, i), noiseVector, spectralFloorBeta);
      
      # Plotam spectrul semnalului zgomotos
      figure 4;
      plot(noiseVector);
      hold on;
      title('Noise Power Spectral PSS');
      
    endif
   
  endfor
  
endfunction


