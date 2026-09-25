clc; clear; close all; 
figure;
hold on;
s = tf('s');
G_main = (-s+3)/((s)*(s+2)*(s^2 + 2*s + 4));
step(G_main);
N = 10;

G = opt_app(G_main,1,2,1);
step(G);
legend
