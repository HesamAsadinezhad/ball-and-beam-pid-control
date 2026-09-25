function [Gc_Sys,H_Sys,Kp,Ti,Td]=cohen_pid(key,typ,vars)
Ti=0; Td=0; K=vars(1); L=vars(2); T=vars(3); N=vars(4); a=K*L/T; tau=L/(L+T);
if typ==1
    switch key
        case 1, Kp = (1+L/(3*T))/a;
        case 2,
            Kp=(0.9+L/(12*T))/a; Ti=L*(30+3*L/T)/(9+20*L/T);
            Gc_Sys=tf(Kp*[Ti,1],[Ti,0]); H_Sys=[];
        case {3,4}
            Kp = (4/3 + L/(4*T))/a; Ti = L*(32+6*L/T)/(13+8*L/T); Td = L*4/(11+2*L/T);
            if key==3
                dd=Ti*[Td/N,1,0]; nn=[Kp*Ti*Td*(N+1)/N, Kp*(Ti+Td/N), Kp]; Gc_Sys=tf(nn,dd); H_Sys=[];
            elseif key==4
                d0=sqrt(Ti*(Ti-4*Td)); Ti0=Ti; Kp=0.5*(Ti+d0)*Kp/Ti; Ti=0.5*(Ti+d0); Td=Ti0-Ti;
                Gc_Sys=tf(Kp*[Ti,1],[Ti,0]); nH=[(1+Kp/N)*Ti*Td, Kp*(Ti+Td/N), Kp];
                dH=Kp*conv([Ti,1],[Td/N,1]); H_Sys=tf(nH,dH);
            end
    end    
elseif typ==2
    switch key
        case 1, Gc_Sys=tf((1+0.35*tau/(1-tau))/a,1); H_Sys=[];
        case 2,
            Kp=0.9*(1+0.92*tau/(1-tau))/a; Ti=(3.3-3*tau)*L/(1+1.2*tau);
            Gc_Sys=tf(Kp*[Ti,1],[Ti,0]); H_Sys=[];
        case {3,4}
            Kp=1.35*(1+0.18*tau/(1-tau))/a; Ti=(2.5-2*tau)*L/(1-0.39*tau); Td=0.37*(1-tau)*L/(1-0.81*tau);
            if key==3
                dd=Ti*[Td/N,1,0]; nn=[Kp*Ti*Td*(N+1)/N, Kp*(Ti+Td/N), Kp]; Gc_Sys=tf(nn,dd); H_Sys=[];
            elseif key==4
                d0=sqrt(Ti*(Ti-4*Td)); Ti0=Ti; Kp=0.5*(Ti+d0)*Kp/Ti; Ti=0.5*(Ti+d0); Td=Ti0-Ti;
                Gc_Sys=tf(Kp*[Ti,1],[Ti,0]); nH=[(1+Kp/N)*Ti*Td, Kp*(Ti+Td/N), Kp];
                dH=Kp*conv([Ti,1],[Td/N,1]); H_Sys=tf(nH,dH);
            end
        case 5
            Kp=1.24*(1+0.13*tau/(1-tau))/a; Td=(0.27-0.36*tau)*L/(1-0.87*tau);
            dd=[Td/N,1]; nn=Kp*[Td*(N+1)/N, 1]; Gc_Sys=tf(nn,dd); H_Sys=[];
    end
end
end
