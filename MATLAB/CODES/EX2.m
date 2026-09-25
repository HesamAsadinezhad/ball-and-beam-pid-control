clc; clear; close all;
G_main = tf(1,[1 2 0]);

[Kv,L] = get_ipd(G_main);
G1 = tf(Kv,[1 0]);
G1.ioDelay = L;

step(G_main,G1)
legend 'show'