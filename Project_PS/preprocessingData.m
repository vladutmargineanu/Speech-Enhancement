% Preprocesarea datelor de intrare
% pkg load signal
close all;
clear all;

% Variabile - procentajul de overlap, dimensiunea unei ferestre, numarul de benzi
overlapPercentage = 50/100;   # se divizeaza vectorul audio - overlapped frames 50% MBSS
                              # pentru PSS este 40/100
                              
hanningSize = 0.02;           # 20 ms window pentru Hamming MBSS
                              # 10 ms window pentru Hamming PSS

% Citim datele de intrare - vectorul audio
[audioData, samplingFreq] = audioread('noisecut1.wav');

% Redam vectorul audio original
sound(audioData, samplingFreq)

% Generam fereastra Hanning pentru numarul de smples
hanningFrameSize = floor(samplingFreq * hanningSize);
hanningAudioData = hanning(hanningFrameSize);

figure 1;
plot(hanningAudioData, 'm');
title('Fereastra Hamming');

% Segmentarea semnalului audio in frame-uri
sizeAudioData = length(audioData);
overlapNumber = floor(overlapPercentage * hanningFrameSize);

% Calculez cate frame-uri voi avea in matrice
numberFrames = floor((sizeAudioData - hanningFrameSize) / overlapNumber) + 1;

% Fac o matrice cu frame-urile pe care se aplica Hanning Window pe fiecare frame
# cele doua matrici au aceleasi dimensiuni
# prima matrice este o initializare cu valori consecutive pe coloana
matrixFrameHanning = repmat((1:hanningFrameSize)', 1, numberFrames);

# a doua matrice initializeaza fiecare frame pe linii cu dimenziunea unei ferestre Hanning
matrixFrameOverlap = repmat((0:overlapNumber:(numberFrames - 1) * overlapNumber), hanningFrameSize, 1);

# adunam cele doua matrici initializate
matrixFrame = matrixFrameHanning + matrixFrameOverlap;

# cream o matrice cu ferestre Hanning
hanningMatrix = repmat(hanningAudioData, 1, numberFrames);

# aplicam fereastra hanning pe fiecare linie din matrixFrame pentru audioData
matrixFrameHanning = audioData(matrixFrame) .* hanningMatrix;

% Plotam o parte din semnalul prelucrat cu ferestre Hanning
figure 2;
plot(matrixFrameHanning(:, 100), 'b');
title('Audio Data preprocesat cu fereastra Hanning');

% Aplicam FFT pe fiecare frame din matrice (din timp -> in frecventa)
fftMatrixFrame = fft(matrixFrameHanning, hanningFrameSize);
fftSize = size(fftMatrixFrame);

% Weighted Spectral Average - aplicam filtrul
absFftMatrixFrame = abs(fftMatrixFrame);
weightMatrixFrame = absFftMatrixFrame;

% Calculam media spectrului, aplicand filtrul Weight
% W = [0.09, 0.25, 0.32, 0.25, 0.09]
for i = [1:fftSize(2) - 4]
  weightMatrixFrame(:, i + 2) = 0.09 * absFftMatrixFrame(:, i) + 0.25 * absFftMatrixFrame(:, i + 1) + 0.32 * absFftMatrixFrame(:, i + 2) + 0.25 * absFftMatrixFrame(:, i + 3) + 0.09 * absFftMatrixFrame(:, i + 4);
end

% Calculez patratul fiecarei valori din matrice => spectral power
finalMatrixFrame = weightMatrixFrame .^ 2;

figure 3;
plot(finalMatrixFrame(:,40), 'b');
hold on;
plot(abs(fftMatrixFrame(:,40)),'r');
legend( 'red - before Weighted Spectral Average', 'blue - after Weighted Spectral Average' );
title('Weighted Spectral Average');

% Alegem metoda dorita pentru speech enhancement

signalFinal = functionMBSS(finalMatrixFrame, hanningFrameSize, samplingFreq);

% signalFinal = functionPSS(finalMatrixFrame, hanningFrameSize, samplingFreq);

% Reconstruim semnalul
signalMBSSbuild = sqrt(signalFinal);
fftPhaseSegmMatrix = angle(fftMatrixFrame);

% Phase original adaugat, formula euler
signalMBSSbuildNew = signalMBSSbuild .* exp(j * fftPhaseSegmMatrix);

sizeNewFFT = size(signalMBSSbuildNew);
numberFramesBuild = sizeNewFFT(2);

signalBuild = zeros(1, ((numberFramesBuild - 1) * overlapNumber + hanningFrameSize));

% Overlap Add pentru frame-uri, reconstruim semnalul
for i = 1:numberFramesBuild
  
  position = (i - 1) * overlapNumber + 1;
  signalBuild(position:position +  hanningFrameSize - 1) = signalBuild(position:position + hanningFrameSize - 1) + real(ifft(signalMBSSbuildNew(:, i), hanningFrameSize))';
  
endfor

% Cream semnalul de iesire de tip wav
audiowrite('outputSignal.wav', signalBuild, samplingFreq);

% Redam semnalul construit
sound(signalBuild, samplingFreq)

% Original Spectrum si Enhaced Spectrum
figure 5;
plot(abs(fftMatrixFrame(:,floor(fftSize(2)/2))),'r');
hold on;
plot(sqrt(signalFinal(:,floor(fftSize(2)/2))), 'b');
title('Enhaced Spectrum');
legend( 'red - Original Spectrum', 'blue - Enhaced Spectrum' );

% Impartim cu window pentru afisarea spectogramelor
window = 8;
sizeTotalBands = floor(sizeAudioData/window);
% Afisam evolutia spectrala a semnalelor - original si rezultat -> spectograma
figure 6;
specgram(audioData, sizeTotalBands, samplingFreq);
title('Spectograma - Spectrul Semnalului Original');

figure 7;
specgram(signalBuild, sizeTotalBands, samplingFreq);
title('Spectograma - Spectrul Semnalului Rezultat');

