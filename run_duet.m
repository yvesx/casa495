clc
clear all
close all
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%    setp 1,2,3
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%1. analyze the signals - STFT
%1) Create the spectrogram of the Left and Right channels.
wlen=1024;
timestep=512;
numfreq=1024;
awin=hamming(wlen);%analysis window is a Hamming window Looks like Sine on [0,pi]
[x1,fs,nbits] = wavread('data/x1.wav');
x2 = wavread('data/x2.wav');
% tf1 tf2 look like left right channel
% question: why is it important to two have left right channel
tf1=tfanalysis(x1,awin,timestep,numfreq);%time-freq domain
tf2=tfanalysis(x2,awin,timestep,numfreq);%time-freq domain

tf1(1,:)=[];
tf2(1,:)=[];%remove dc component from mixtures
%eps is the a small constant to avoid dividing by zero frequency in the delay estimation

%calculate pos/neg frequencies for later use in delay calc ??
freq=[(1:numfreq/2) ((-numfreq/2)+1:-1)]*(2*pi/(numfreq)); % freq looks like saw signal
fmat=freq(ones(size(tf1,2),1),:)'; % why just tf1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%2.calculate alpha and delta for each t-f point
%2) For each time/frequency compare the phase and amplitude of the left and
%   right channels. This gives two new coordinates, instead of time-frequency 
%   it is phase-amplitude differences.
R21=(tf2+eps)./(tf1+eps);%time-freqratioofthemixtures

%%%2.1HERE WE ESTIMATE THE RELATIVE ATTENUATION (alpha)%%%
a=abs(R21);%relative attenuation between the two mixtures
alpha=a-1./a;%'alpha' (symmetric attenuation)
%%%2.2HERE WE ESTIMATE THE RELATIVE DELAY (delta)%%%%
delta=-imag(log(R21))./fmat;% imaginary part, 'delta' relative delay
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%3.calculate weighted histogram
%3) Build a 2-d histogram (one dimension is phase, one is amplitude) where 
%   the height at any phase/amplitude is the count of time-frequency bins that
%   have approximately that phase/amplitude.
p=1; q=0; %powers used to weight histogram
tfweight=(abs(tf1).*abs(tf2)).^p.*abs(fmat).^q; %weights vector
maxa=0.7;
maxd=3.6;%histogram boundaries for alpha, delta

abins=35;
dbins=50;%number of hist bins for alpha, delta

%only consider time-freq points yielding estimates in bounds
amask=(abs(alpha)<maxa)&(abs(delta)<maxd);
alphavec=alpha(amask);
deltavec=delta(amask);
tfweight=tfweight(amask);

%determine histogram indices (sampled indices?)
alphaind=round(1+(abins-1)*(alphavec+maxa)/(2*maxa));
deltaind=round(1+(dbins-1)*(deltavec+maxd)/(2*maxd));

%FULL-SPARSE TRICK TO CREATE 2D WEIGHTED HISTOGRAM
%A(alphaind(k),deltaind(k)) = tfweight(k), S is abins-by-dbins
A=full(sparse(alphaind,deltaind,tfweight,abins,dbins));
%smooththehistogram-localaverage3-by-3neighboringbins
A=twoDsmooth(A,3);

%plot2-Dhistogram
mesh(linspace(-maxd,maxd,dbins),linspace(-maxa,maxa,abins),A);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%    step 4,5,6,7
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%4.peak centers (determined from histogram) THIS IS DONE BY HUMAN.
%4) Determine how many peaks there are in the histogram.
%5) Find the location of each peak. 

numsources=5;
peakdelta=[-2 -2 0 2 2];
peakalpha=[.19 -.21 0 .19 -.21];

%convert alpha to a
peaka=(peakalpha+sqrt(peakalpha.^2+4))/2;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%5.determine masks for separation
%6) Assign each time-frequency frame to the nearest peak in phase/amplitude 
%  space. This partitions the spectrogram into sources (one peak per source)

bestsofar=Inf*ones(size(tf1));
bestind=zeros(size(tf1));
for i=1:length(peakalpha)
    score=abs(peaka(i)*exp(-sqrt(-1)*fmat*peakdelta(i))...
        .*tf1-tf2).^2/(1+peaka(i)^2);
    mask=(score<bestsofar);
    bestind(mask)=i;
    bestsofar(mask)=score(mask);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%6.&7.demix with ML alignment and convert to time domain
%7) Then you create a binary mask (1 for each time-frequency point belonging to my source, 0 for all other points)
%8) Mask the spectrogram with the mask created in step 7.
%9) Rebuild the original wave file from 8.
%10) Listen to the result.
est=zeros(numsources,length(x1));%demixtures
for i=1:numsources
    mask=(bestind==i);
    esti=tfsynthesis([zeros(1,size(tf1,2));
        ((tf1+peaka(i)*exp(sqrt(-1)*fmat*peakdelta(i)).*tf2)...
            ./(1+peaka(i)^2)).*mask],...
             sqrt(2)*awin/1024,timestep,numfreq);
    est(i,:)=esti(1:length(x1))';

    %add back into the demix a little bit of the mixture
    %as that eliminates most of the masking artifacts
    soundsc(est(i,:)+0.05*x1',fs);pause;% original code seems to have missed the transpose play demixture
end