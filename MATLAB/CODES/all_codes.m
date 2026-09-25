s = tf('s');

Gm = 0.0274/(0.003228*s^2+0.003508*s)/5; % Motor and Gearbox Transfer Function
Gb = 9.81*0.05/3/(7/5*s^2); % Ball and Beam Transfer Function
G = Gm*Gb; % Approximated Plant Transfer Function

% Stablizer

C = 3856.4*((s+0.6614)*(s+0.3708)*(s+0.2079)*(s^2+7.043*s+15.35))/((s+4.683)*(s+5.401)*(s+6.372)*(s^2+13.73*s+50.67));

% Using C Stablizer and values of [K L T N] = [1 0.455 0.267953 100]

[G_AH,H_AH,Kp_AH,Ti_AH,Td_AH]=astrom_hagglund(2,1,[1 0.455 0.267953 100]);
[G_CHR,H_CHR,Kp_CHR,Ti_CHR,Td_CHR]=chr_pid(3,1,[1 0.455 0.267953 100 0]);
[G_CHR20,H_CHR20,Kp_CHR20,Ti_CHR20,Td_CHR20]=chr_pid(3,1,[1 0.455 0.267953 100 1]);
[G_CC,H_CC,Kp_CC,Ti_CC,Td_CC]=cohen_pid(3,1,[1 0.455 0.267953 100]);
[G_CCR,H_CCR,Kp_CCR,Ti_CCR,Td_CCR]=cohen_pid(3,2,[1 0.455 0.267953 100]);
[G_RZN,H_RZN,Kp_RZN,Ti_RZN,Td_RZN,beta]=rziegler_nic([1 0.455 0.267953 100 3.9781 1.3222]);
[G_ZN,H_ZN,Kp_ZN,Ti_ZN,Td_ZN]=ziegler_nic(3,[1 0.455 0.267953 100]);
[G_WJC,Kp_WJC,Ti_WJC,Td_WJC]=wjcpid([1 0.455 0.267953 100]);

Gn = feedback(G*C,1);

figure
step(feedback(Gn,1));
hold on 
step(feedback(Gn*G_AH,1)); % astrom_huggland
step(feedback(Gn*G_CHR,1)); % chr 0% overshoot
step(feedback(Gn*G_CHR20,1)); % chr 20% overshoot
step(feedback(Gn*G_CC,1)); % cohen
step(feedback(Gn*G_CCR,1)); % cohen revisited
step(feedback(Gn*G_RZN,H_RZN)); % refined ziegler nicholes
step(feedback(Gn*G_ZN,1)); % ziegler nicholes
step(feedback(Gn*G_WJC,1)); % wjc

legend('No PID','AH PID','CHR PID','CHR PID20','CC PID','CCR PID','RZN PID','ZN PID','WJC PID')
