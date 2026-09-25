function y=opt_fun(x,G,key,r,k,dc)
ff0=1e10;a=[1,x(r+1:r+k)];b=x(1:r+1);b(end)=a(end)*dc;g=tf(b,a);
if key==1
    tau=x(end); if tau<=0,tau=eps;end,[n,d]=pade(tau,3);gp=tf(n,d);
else,gp=1;end
G_e=G-g*gp;G_e.num{1}=[0,G_e.num{1}(1:end-1)];
[y,ierr]=geth2(G_e);if ierr==1,y=10*ff0;else, ff0=y; end
function[v,ierr]=geth2(G)
G=tf(G);num=G.num{1};den=G.den{1};ierr=0;v=0;n=length(den);
if abs(num(1))>eps
    disp('system not strictly proper');
    ierr=1;return
else, a1=den;b1=num(2:length(num));end
for k=1:n-1
    if (a1(k+1)<=eps),ierr=1; return
    else,
        aa=a1(k)/a1(k+1);bb=b1(k)/a1(k+1);v=v+bb*bb/aa;k1=k+2;
        for i=k1:2:n-1
            a1(i)=a1(i)-aa*a1(i+1);b1(i)=b1(i)-bb*a1(i+1);
        end,end,end
v=sqrt(0.5*v);

