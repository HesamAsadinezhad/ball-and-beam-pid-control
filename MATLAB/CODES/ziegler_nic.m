function [Gc_Sys,H_Sys,Kp,Ti,Td]=ziegler_nic(key,vars)
Ti=0; Td=0;
switch length(vars)
case 3, 
   K=vars(1); Tc=vars(2); N=vars(3);
   switch key
   case 1, Kp=0.5*K; 
   case 2, Kp=0.4*K; Ti=0.8*Tc; 
   case {3,4}, Kp=0.6*K; Ti=0.5*Tc; Td=0.12*Tc; 
   end
case 4, 
   K=vars(1); L=vars(2); T=vars(3); N=vars(4); a=K*L/T; 
   switch key
   case 1, key==1,  Kp=1/a; 
   case 2, Kp=0.9/a; Ti=3.33*L; 
   case {3,4}, Kp=1.2/a; Ti=2*L; Td=L/2; 
   end
case 5, 
   K=vars(1); Tc=vars(2); rb=vars(3); pb=pi*vars(4)/180; 
   N=vars(5); Kp=K*rb*cos(pb); 
   if key==2, Ti=-Tc/(2*pi*tan(pb)); 
   elseif key==3 | key==4, Ti=Tc*(1+sin(pb))/(pi*cos(pb)); Td=Ti/4; end
end
switch key
case 1, Gc_Sys=tf(Kp,1); H_Sys=[];
case 2, Gc_Sys=tf(Kp*[Ti,1],[Ti,0]); H_Sys=[];
case 3
   dd=Ti*[Td/N,1,0]; nn=[Kp*Ti*Td*(N+1)/N, Kp*(Ti+Td/N), Kp];
   Gc_Sys=tf(nn,dd); H_Sys=[];
case 4
   d0=sqrt(Ti*(Ti-4*Td)); Ti0=Ti; 
   Kp=0.5*(Ti+d0)*Kp/Ti; Ti=0.5*(Ti+d0); Td=Ti0-Ti; nn=Kp*[Ti,1]; dd=[Ti,0]; 
   nH=[(1+Kp/N)*Ti*Td, Kp*(Ti+Td/N), Kp]; dH=Kp*conv([Ti,1],[Td/N,1]);
   Gc_Sys=tf(nn,dd); H_Sys=tf(nH,dH);
end