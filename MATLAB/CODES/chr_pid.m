function [Gc_Sys,H_Sys,Kp,Ti,Td]=chr_pid(key,typ,vars)
Ti=0; Td=0; K=vars(1); L=vars(2); T=vars(3); N=vars(4); 
a=K*L/T; ovshoot=vars(5);
if typ==1, TT=T; else TT=L; typ=2;  end
if ovshoot==0, 
   KK=[0.3,0.35,1.2,0.6,1,0.5; 0.3,0.6,4,0.95,2.4,0.42];
else, 
   KK=[0.7,0.6,1,0.95,1.4,0.47; 0.7,0.7,2.3,1.2,2,0.42]; 
end
switch key 
case 1, Kp=KK(typ,1)/a; Gc_Sys=tf(Kp,1); H_Sys=[];
case 2, Kp=KK(typ,2)/a; Ti=KK(typ,3)*TT; Gc_Sys=tf(Kp*[Ti,1],[Ti,0]); H_Sys=[]; 
otherwise
   Kp=KK(typ,4)/a; Ti=KK(typ,5)*TT; Td=KK(typ,6)*L; 
   if key==3
      dd=Ti*[Td/N,1,0]; nn=[Kp*Ti*Td*(N+1)/N, Kp*(Ti+Td/N), Kp]; Gc_Sys=tf(nn,dd); H_Sys=[];
   elseif key==4
      d0=sqrt(Ti*(Ti-4*Td)); Ti0=Ti; Kp=0.5*(Ti+d0)*Kp/Ti; Ti=0.5*(Ti+d0); Td=Ti0-Ti;
      nH=[(1+Kp/N)*Ti*Td, Kp*(Ti+Td/N), Kp]; dH=Kp*conv([Ti,1],[Td/N,1]);
      Gc_Sys=tf(Kp*[Ti,1],[Ti,0]); H_Sys=tf(nH,dH);
   end
end
