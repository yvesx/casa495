function x=tfsynthesis(timefreqmat,swin,timestep,numfreq)
%time-frequencysynthesis
%TIMEFREQMATisthecomplexmatrixtime-freqrepresentation
%SWINisthesynthesiswindow
%TIMESTEPisthe#ofsamplesbetweenadjacenttimewindows.
%NUMFREQisthe#offrequencycomponentspertimepoint.
%
%Xcontainsthereconstructedsignal.
swin=swin(:);%makesynthesiswindowgocolumnwise
winlen=length(swin);
[numfreq numtime]=size(timefreqmat);
ind=rem((1:winlen)-1,numfreq)+1;
x=zeros((numtime-1)*timestep+winlen,1);
for i=1:numtime%overlap,window,andadd
    temp=numfreq*real(ifft(timefreqmat(:,i)));
    sind=((i-1)*timestep);
    rind=(sind+1):(sind+winlen);
    x(rind)=x(rind)+temp(ind).*swin;
end