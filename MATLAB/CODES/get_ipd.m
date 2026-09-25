function [Kv,L] = get_ipd(G)
[Num,Den] = tfdata(G);
syms s;
G_sys = poly2sym(cell2mat(Num),s)/poly2sym(cell2mat(Den),s);
G_t=ilaplace(G_sys*1/s);
Kv=diff(G_t);
t=10000;
Kv=subs(Kv);
Kv=eval(Kv);
Gt10000=subs(G_t);
Gt10000=eval(Gt10000);
L=(Kv*10000-Gt10000)/Kv;
end


