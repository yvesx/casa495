function tfmat=tfanalysis(x,awin,timestep,numfreq)
%time-frequency analysis
%X is the time domain signal
%AWIN is an analysis window
%TIMESTEP is the # of samples between adjacent time windows.
%NUMFREQ is the # of frequency components per time point.
%
%TFMAT complex matrix time-freq representation
x=x(:); 
awin=awin(:);%make inputs go column-wise
nsamp=length(x);
wlen=length(awin);
%calc size and init output t-f matrix
numtime=ceil((nsamp-wlen+1)/timestep);
tfmat=zeros(numfreq,numtime+1);

% so this loop samples x, I though x is already a sample.
for i=1:numtime
    sind=((i-1)*timestep)+1; % current start index
    tfmat(:,i)=fft(x(sind:(sind+wlen-1)).*awin,numfreq);
end
% below is inelegant... but apparently works.
i=i+1;
sind=((i-1)*timestep)+1;
lasts=min(sind,length(x));
laste=min((sind+wlen-1),length(x));
tfmat(:,end)=fft([x(lasts:laste);
                    zeros(wlen-(laste-lasts+1),1)].*awin,numfreq);