% Implementare factor spectral floor beta

function [floorFrame] = spectralFloor(frameVector, noiseVector, spectralFloor)
  
  floorValue = frameVector - noiseVector' .* spectralFloor;
  
  % Extragem valorile negative si le salvam intr-un vector
  negativeValue = (floorValue < 0);
  
  % cautam indici valorilor diferiti de 0 (strict valorile negative)
  indexNegativeValue = find(negativeValue);
  
  % Eliminam valorile negative, dupa formula cu beta
  floorFrame = frameVector;
  sizeIndexNegativeValue = length(indexNegativeValue);
  
  % Pentru fiecare valoare negativa, facem spectral floor
  for i = 1:sizeIndexNegativeValue
    
    floorFrame(indexNegativeValue(i)) = noiseVector(indexNegativeValue(i)) * spectralFloor;
    
  endfor
  
endfunction
