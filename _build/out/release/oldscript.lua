aY=""
aX="$"
aW="operator"
aV="scriptsave"
aU="Transfer between "
aT="Transfer in the amount of $"
aS="id"
aR="[MarvinsAddon]"
aQ="Bank"
aP=" to "
aO="Something went wrong! Try again."
aN="[Server]"
aM=" were removed from your bank account!"
aL=" and "
aK=" were sended to your bank account!"

r=true
q=pairs
h=tostring
M=table
C=nil
o=tonumber
t=false
a=g_savedata
l=server
L=l.getPlayers
W=l.notify
E=l.announce
H=l.save
a={V={aD=t,aB=t,ab=aY},Y={U=20000},b={}}X={name=aY,steam_id=aY,f=0,I=0,tags={}}ah={"76561198346789290","76561197976360068"}aC="https://discord.gg/2pcKA74Qgb"
m=0
v=0
D=0
Q=0
N=0
function onCreate(al)if(al)then
a.Y.U=o(property.slider("Start Money",20000,200000,10000,20000))end
X.f=a.Y.U
end
function onDestroy()H(aV)end
function onTick(am)m=m+am
if(m==3600)then
m=0
v=v+1
elseif(m>3600)then
m=m-3600
v=v+1
end
if(v==60)then
v=0
D=D+1
end
if(D==24)then
D=0
Q=Q+1
end
if((m-N)>=60 or(m-N)<0)then
N=m
ak()end
end
function onPlayerJoin(steam_id,name,_,admin,auth)local j=R(_)local steam_id=i(_)local S=l.getMapID()l.addAuth(_)E(aN,name.." joined the game")if(a.b[steam_id]~=C)then
a.b[steam_id].I=S
ac(_)H(aV)return
end
a.b[steam_id]=M.aI(X)a.b[steam_id].name=h(j.name)a.b[steam_id].steam_id=h(steam_id)a.b[steam_id].I=S
for p,d in q(ah)do
if(d==steam_id)then
aa(_,"owner")aa(_,aW)l.addAdmin(_)end
end
W(_,"[Bank]","New bank account created!",8)H(aV)end
function onPlayerLeave(steam_id,name,_,admin,auth)local steam_id=i(_)E(aN,name.." left the game")l.removeMapID(_,a.b[steam_id].I)H(aV)end
function onCustomCommand(ay,_,av,aw,s,e,g,an,aJ,aE)local b=R(_)local steam_id=i(_)if(s=="?help")then
E(aR,"Help not available")elseif(s=="?tags")then
local e=o(e)if(not B(e))then
return
end
announce(aR,"Tags: "..ap(e),_)elseif(s=="?addMoney" and F(_,aW))then
local ag=ao(e,g)if(ag)then
notify(_,"Money Printing Company","Assignment done!",8)notify(e,aQ,aX..g..aK,8)end
elseif(s=="?setMoney" and F(_,aW))then
af(e,g)notify(_,aQ,"The balance of "..e.." was set to $"..g,8)notify(e,aQ,"Your balance was set to "..g,8)elseif(s=="?removeMoney" and F(_,aW))then
as(e,g)notify(_,aQ,aX..g.." were removed from the bank account of "..e,8)notify(e,aQ,aX..g..aM,8)elseif(s=="?transferMoney" and F(_,aW))then
Z(e,g,an)notify(_,aQ,aX..g.." were transfered from "..e..aP..g,8)notify(e,aQ,aX..g..aK,8)notify(g,aQ,aX..g..aM,8)elseif(s=="?sendMoney")then
Z(_,e,g)notify(_,aQ,"You sended $"..g..aP..e,8)notify(e,aQ,aX..g.." were sended to your bank account from "..b.name.."!",8)end
end
function R(_)local G=L()local j={id=0,name=aY,steam_id=aY,auth=t,admin=t}for p,d in q(G)do
if(h(d[aS])==h(_))then
j.id=d.id
j.name=d.name
j.steam_id=h(d.steam_id)j.auth=d.auth
j.admin=d.admin
return j
end
end
end
function i(_)local G=L()for p,d in q(G)do
if(h(d[aS])==h(_))then
return h(G[p].steam_id)end
end
end
function ap(_)local steam_id=i(_)return ar(a.b[steam_id].tags)end
function F(_,A)local steam_id=i(_)for p,d in q(a.b[steam_id].tags)do
if(h(d)==h(A))then
return r
end
end
return t
end
function aa(_,A)local steam_id=i(_)for p,d in q(a.b[steam_id].tags)do
if(h(d)==h(A))then
return
end
end
M.insert(a.b[steam_id].tags,A)return r
end
function aG(_,A)local steam_id=i(_)for p,d in q(a.b[steam_id].tags)do
if(h(d)==h(A))then
M.remove(a.b[steam_id].tags,p)return r
end
end
end
function at(_)local steam_id=i(_)return k(a.b[steam_id].f)end
function af(_,c)local steam_id=i(_)local c=o(c)if(not B(c))then
return
end
a.b[steam_id].f=c
end
function ao(_,c)local _=o(_)local steam_id=i(_)local c=o(c)if(not B(c))then
return
end
a.b[steam_id].f=k(a.b[steam_id].f)+c
return r
end
function as(_,c)local steam_id=i(_)local c=o(c)if(not B(c))then
return
end
a.b[steam_id].f=k(a.b[steam_id].f)-c
return r
end
function Z(_,J,c)local n=i(_)local u=i(J)local c=o(c)if(not B(c))then
return
end
if(a.b[n]==C or a.b[u]==C)then
notify(_,aQ,aT..c.." canceled! Recipient or sender are not found!",8)notify(J,aQ,"Transfer canceled! Recipient or sender are not found!",8)return
end
if(k(a.b[n].f)<k(c))then
notify(_,aQ,aT..c.." canceled! Not enough money!",8)return
end
if(_==J)then
notify(_,aQ,"You cant send your self money!",8)end
local T=k(a.b[n].f)local aq=k(a.b[u].f)a.b[n].f=k(a.b[n].f)-k(c)if((T-a.b[n].f)~=c)then
a.b[n].f=T
notify(_,aQ,aO,8)ad(aU..n..aL..u.." Payment by payer has failed!")end
a.b[u].f=k(a.b[u].f)+k(c)if((a.b[u].f-aq)~=c)then
notify(_,aQ,aO,8)ad(aU..n..aL..u..". Payment by target has failed!")end
end
function aF(P)local K=0
for au in q(P)do K=K+1 end
return K
end
function B(d)if(type(d)==type(0))then
return r
end
return t
end
function aA(d)if(type(d)==type(aY))then
return r
end
return t
end
function notify(_,aj,w,ae)W(_,aj,w,ae)end
function announce(name,w,_)if(_==C)then
l.ax(name,w)elseif(_~=C and B(_))then
E(name,w,_)end
end
function ad(w)a.V.ab=a.V.ab.."|"..w.."| "
end
function aH(_)local steam_id=i(_)return a.b[steam_id]end
function ar(P)local O=aY
for p,d in q(P)do
O=O..h(p)..": "..h(d).."; "
end
return O
end
function k(d)return o(string.format("%.2f",d))end
function ac(_)local steam_id=i(_)l.setPopupScreen(_,a.b[steam_id].I,aY,r,"Balance: $"..at(_),.56,.88)end
function ak()local j=L()for az,j in q(j)do
ac(o(j.id))end
end
