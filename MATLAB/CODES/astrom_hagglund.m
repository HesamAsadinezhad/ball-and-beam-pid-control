function [Gc_Sys,H_Sys,Kp,Ti,Td]=astrom_hagglund(key,typ,vars)
if typ==1
    Td=0; K=vars(1); L=vars(2); T=vars(3); N=vars(4);
    if key==1
        Kp = 0.15/K + (0.35-(L*T)/((L+T)^2))*T/(K*L);
        Ti = 0.35*L + (13*L*T^2)/(T^2+12*L*T+7*L^2);
    elseif key==2
        Kp = (0.2+0.45*T/L)/K;
        Ti = (L*(0.4*L+0.8*T))/(L+0.1*T);
        Td = (0.5*L*T)/(0.3*L+T);
    end
    dd=Ti*[Td/N,1,0]; nn=[Kp*Ti*Td*(N+1)/N, Kp*(Ti+Td/N), Kp]; Gc_Sys=tf(nn,dd); H_Sys=[];
elseif typ==2
    Td=0; K=vars(1); Kc=vars(2); Tc=vars(3); N=vars(4); kappa = 1/(K*Kc);
    if key==1
        Kp = 0.16*Kc;
        Ti = Tc/(1+4.5*kappa);
    elseif key==2
        Kp = (0.3-0.1*kappa^4)*Kc;
        Ti = Tc*0.6/(1+2*kappa);
        Td = Tc*0.15*(1-kappa)/(1-0.95*kappa);
    end
    dd=Ti*[Td/N,1,0]; nn=[Kp*Ti*Td*(N+1)/N, Kp*(Ti+Td/N), Kp]; Gc_Sys=tf(nn,dd); H_Sys=[];
end
end