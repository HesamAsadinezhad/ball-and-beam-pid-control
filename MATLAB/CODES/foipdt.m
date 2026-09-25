% PD and PID Parameters for FOIPDT Models
% FOIPDT: first-order lag and integrator plus dead time

function [Gc,Kp,Ti,Td]=foipdt(key,K,L,T,N)
s=tf('s');
if key==1
   Kp=2/3/K/L; Td=T; Ti=inf; Gc=Kp*(1+Td*s/(1+Td*s/N));
else
   a=(T/L)^0.65; Kp=1.111*T/(K*L^2)/(1+a)^2;
   Ti=2*L*(1+a); Td=Ti/4; Gc=Kp*(1+1/Ti/s+Td*s/(1+Td*s/N));
end