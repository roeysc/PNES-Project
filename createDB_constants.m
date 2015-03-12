% createDB_constants holds constants used by the function createDB
timeFromColumn = 2;
timeEndColumn = 1;
interpolationColumn = 3;
drugsColumn = 4;
titlesRow = 1;
markerSampleColumn = 1;
markerNameColumn = 3;
sampleStartColumn = 5;
signalColumn = 1;
interpolatedElectrodesColumn = 7;
segmentStartinSerialColumn = 8;

% the following constants should be removes, since filtering should occure
% in a different function (preferably a fieldtrip function)
%                     ALL_FREQ = 256;
                    highpass = 0.1;
                    lowpass = 48;
                    notch = 50;
                    gain = 1;
                    downfactor = 1;