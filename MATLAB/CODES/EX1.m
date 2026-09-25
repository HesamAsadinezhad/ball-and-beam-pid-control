clc; clear; close all;
s = tf('s');
G_main = 1/(s+1)^8;

[K1,L1,T1] = get_fod(G_main);
G_freq = K1*exp(-L1*s)/(T1*s+1);

[K,L,T] = get_fod(G_main,1);
G_tf = K*exp(-L*s)/(T*s+1);

step(G_main,G_freq,G_tf)
legend 'show'
