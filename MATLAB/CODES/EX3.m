clc; clear; close all;
s = tf('s');
G_main = 1/(s+1)^8;

[K,L,T] = get_fod(G_main,1);
G = K*exp(-L*s)/(T*s+1);

N = 10;
[Kc,pp,wg,wp] = margin(G_main);
Tc = 2*pi/wg;
% hold on;
% legend 'show'

% [Gc1,~,~,~,~] = ziegler_nic(1,[K L T N]);
% G_c1 = feedback(Gc1*G_main,1);
% G_c1.name = 'P ZN';
% step(G_c1)
% 
% [Gc2,~,~,~,~] = ziegler_nic(2,[K L T N]);
% G_c2 = feedback(Gc2*G_main,1);
% G_c2.name = 'PI ZN';
% step(G_c2)
% 
% [Gc3,~,~,~,~] = ziegler_nic(3,[K L T N]);
% G_c3 = feedback(Gc3*G_main,1);
% G_c3.name = 'PID ZN';
% step(G_c3)
% 
% [Gc4,~,~,~,~,~] = rziegler_nic([K L T N Kc Tc]);
% G_c4 = feedback(Gc4*G_main,1);
% G_c4.name = 'PID r-ZN';
% step(G_c4)
% 
% [Gc5,~,~,~,~] = astrom_hagglund(2,1,[K L T N]);
% G_c5 = feedback(Gc5*G_main,1);
% G_c5.name = 'PID AH';
% step(G_c5)
% 
% [Gc6,~,~,~,~] = astrom_hagglund(2,2,[K Kc Tc N]);
% G_c6 = feedback(Gc6*G_main,1);
% G_c6.name = 'PID freq-based AH';
% step(G_c6)

[Gc7,H_Sys,Kp,Ti,Td]=cohen_pid(4,1,[K L T N]);