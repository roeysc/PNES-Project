function outsig = simplefilter(insig,fs,downfactor,highpass,lowpass,notch,gain)
% simplefilter
% Version: 1.00
% 
% Description:
% ------------
% This function filter a given signal simply.



% 
% Input:
% ------
% insig - vector/matrix of signal
%
% fs - sampling frequency
%
% downfactor - downsampling factor (1 for no downsampling)
%
% highpass - pass higher frequencies than highpass in hz (-inf for no
% highpass)
%
% lowpass - pass lower frequencies than lowpass in hz (inf for no lowpass)
%
% notch - notch frequency to remove ([] for no notch)
%
% gain - gain factor (scalar multiply 1 for nothing)
%

 
% Output:
% -------
% outsig - the processed signal

% Order of prcoessing:
% --------------------
% 1. High pass
% 2. Notch
% 3. Downsampling
% 4. Low pass
% 5. Gain 

% Check arguments
if (isempty(insig))
    error('Empty input signal...');
end

if (fs<=0)
    error('Errornous sampling frequency');
end

if (downfactor<1)
    error('Downsampling factor must be 1 or higher');
end   
   
if (highpass>lowpass)
    error('Lowpass frequency cutoff must be higher than highpass');
end

% Init
nyquist = fs/2; % Nyquist frequency
pass_order = 2; % Low pass and high pass order
notch_order = 2; % Notch order
notchmargin = 1; % Margin of notch 

nrows = size(insig,1);
ncols = size(insig,2);


% 1. High pass
if (highpass~=-inf)
    
    [z,p,k] = butter(pass_order,(highpass/nyquist),'high');
    [sos,g] = zp2sos(z,p,k);      % Convert to SOS form
    Hd = dfilt.df2tsos(sos,g);
    
    for i=1:ncols
    
        insig(:,i) = filter(Hd,insig(:,i));
               
    end
    
end

% 2. Notch
if (~isempty(notch))
    
    [b,a] = butter(notch_order,([notch-notchmargin notch+notchmargin]./nyquist),'stop');
    
    for i=1:ncols
        cwd = pwd;
        cd('C:\Program Files\MATLAB\R2013a\toolbox\signal\signal');
        insig(:,i) = filtfilt(b,a,insig(:,i));
        cd(cwd);
    end
    
end

% 3. Downsampling
if (downfactor~=1)
   
    for i=1:ncols
       
        if (i==1)
        
         tempsig = downsample(insig(:,i),downfactor);
        
        else
           
         tempsig(:,i) = downsample(insig(:,i),downfactor);
            
        end
         
    end
    
    insig = tempsig;
    
end

% 4. Low pass
if (lowpass~=inf)
   
    
    [z,p,k] = butter(pass_order,(lowpass/nyquist),'low');
    [sos,g] = zp2sos(z,p,k);      % Convert to SOS form
    Hd = dfilt.df2tsos(sos,g);
    
    for i=1:ncols
    
        insig(:,i) = filter(Hd,insig(:,i));
               
    end
    
end

% 5. Gain
if (gain~=1)

    insig = insig.*gain;
    
end

% Return the modificated signal
outsig = insig;

end