% PID Parameter Settings for Unstable FOPDT Models

function [Gc,Kp,Ti,Td]=ufopdt(key,K,L,T,N)
Tab=[1.32, 0.92, 4.00, 0.47, 3.78, 0.84, 0.95;
     1.38, 0.90, 4.12, 0.90, 3.62, 0.85, 0.93;
     1.35, 0.95, 4.52, 1.13, 3.70, 0.86, 0.97];
a1=Tab(key,1); b1=Tab(key,2); a2=Tab(key,3); b2=Tab(key,4);
a3=Tab(key,5); b3=Tab(key,6); gam=Tab(key,7); A=L/T;
Kp=a1*A^b1/K; Ti=a2*T*A^b2; Td=a3*T*(1-b3*A^(-0.02))*A^gam;
s=tf('s'); Gc=Kp*(1+1/Ti/s+Td*s/(1+Td/N*s));
