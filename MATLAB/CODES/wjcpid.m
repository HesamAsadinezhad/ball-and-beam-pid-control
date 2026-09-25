function [Gc,Kp,Ti,Td]=wjcpid(v)
K=v(1);L=v(2);T=v(3);N=v(4);
Td=0.5*L*T/(T+0.5*L);
Kp=(0.7303+0.5307*T/L)*(T+0.5*L)/K/(T+L);
Ti=T+0.5*L;
s=tf('s');Gc=Kp*(1+1/Ti/s+Td*s/(1+Td*s/N));