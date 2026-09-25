% PD and PID Parameter Setting for IPDT Models
% IPDT: integrator plus dead time

function [Gc,Kp,Ti,Td]=ipdtctrl(key,key1,K,L,N)
a=[1.03,0.49,1.37,1.49,0.59; 0.96,0.45,1.36,1.66,0.53;
   0.9,0.45,1.34,1.83,0.49]; s=tf('s'); Ti=inf;
if key==1
   Kp=a(key1,1)/K/L; Td=a(key1,2)*L; Gc=Kp*(1+Td*s/(1+Td/N*s));
else
   Kp=a(key1,3)/K/L; Ti=a(key1,4)*L; Td=a(key1,5)*L;
   Gc=Kp*(1+1/Ti/s+Td*s/(1+Td/N*s));
end