function [K,L,T]=get_fod(G1,method)

G1 = tf([-1, 4],conv([1,1], [1,3]))
method = 1;
get_fod(G1,method);
K=real(dcgain(G1));
if nargin==1
   [Kc,Pm,wc,wcp]=margin(G1); ikey=0; L=1.6*pi/(3*wc); T=0.5*Kc*K*L; 
   if isfinite(Kc) 
       x0=[L;T]; 
       while ikey==0
          ww1=wc*x0(1); ww2=wc*x0(2);
          FF=[K*Kc*(cos(ww1)-ww2*sin(ww1))+1+ww2^2; sin(ww1)+ww2*cos(ww1)];
          J=[-K*Kc*wc*sin(ww1)-K*Kc*wc*ww2*cos(ww1),-K*Kc*wc*sin(ww1)+2*wc*ww2;
              wc*cos(ww1)-wc*ww2*sin(ww1), wc*cos(ww1)]; 
          x1=x0-inv(J)*FF; 
          if norm(x1-x0)<1e-8, ikey=1; else, x0=x1; end
       end
       L=x0(1); T=x0(2);
   end
elseif nargin==2 & method==1
   [nn,dd]=tfdata(G1,'v'); [n1,d1]=tf_derv(nn,dd); [n2,d2]=tf_derv(n1,d1);
   K1=n1(end)/d1(end); K2=n2(end)/d2(end); Tar=-K1/K; T=sqrt(K2/K-Tar^2); L=Tar-T;
end
L=real(L); T=real(T);
%
function [e,f]=tf_derv(b,a)
f=conv(a,a); na=length(a); nb=length(b);
e1=conv((nb-1:-1:1).*b(1:end-1),a);
e2=conv((na-1:-1:1).*a(1:end-1),b);
maxL=max(length(e1),length(e2));
e=[zeros(1,maxL-length(e1)) e1]-[zeros(1,maxL-length(e2)) e2];

