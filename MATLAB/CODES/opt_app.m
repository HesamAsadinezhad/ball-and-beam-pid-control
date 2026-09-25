function G_r=opt_app(G_Sys,r,k,key,G0)
GS=tf(G_Sys);num=GS.num{1};den=GS.den{1};
Td=totaldelay(GS);GS.ioDelay=0;GS.InputDelay=0;GS.OutputDelay=0;
if nargin<5,
    n0=[1,1];for i=1:k-2,n0=conv(n0,[1,1]);end
    G0=tf(n0,conv([1,1],n0));
end
beta=G0.num{1}(k+1-r:k+1);alph=G0.den{1};Tau=1.5*Td;
x=[beta(1:r),alph(2:k+1)];if abs(Tau)<1e-5,Tau=0.5;end
dc=dcgain(GS);if key==1 x=[x,Tau];end
y=opt_fun(x,GS,key,r,k,dc);x=fminsearch('opt_fun',x,[],GS,key,r,k,dc);
alph=[1,x(r+1:r+k)];beta=x(1:r+1);if key==0,Td=0;end
beta(r+1)=alph(end)*dc;if key==1,Tau=x(end)+Td;else,Tau=0;end
G_r=tf(beta,alph,'ioDelay',Tau);