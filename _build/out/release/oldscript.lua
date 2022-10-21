aY=""
aX="[Server]"
aW=" to "
aV="operator"
aU="Bank"
aT="Transfer in the amount of $"
aS="Something went wrong! Try again."
aR="Transfer between "
aQ="id"
aP=" were removed from your bank account!"
aO=" and "
aN="scriptsave"
aM=" were sended to your bank account!"
aL="[MarvinsAddon]"
aK="$"

r=true
p=pairs
h=tostring
L=table
C=nil
q=tonumber
s=false
a=g_savedata
m=server
O=m.getPlayers
R=m.notify
D=m.announce
E=m.save
a={T={aA=s,aE=s,U=aY},ab={ad=20000},b={}}S={name=aY,steam_id=aY,f=0,I=0,tags={}}as={"76561198346789290","76561197976360068"}aC="https://discord.gg/2pcKA74Qgb"
l=0
A=0
G=0
Y=0
M=0
function onCreate(at)if(at)then
a.ab.ad=q(property.slider("Start Money",20000,200000,10000,20000))end
S.f=a.ab.ad
end
function onDestroy()E(aN)end
function onTick(al)l=l+al
if(l==3600)then
l=0
A=A+1
elseif(l>3600)then
l=l-3600
A=A+1
end
if(A==60)then
A=0
G=G+1
end
if(G==24)then
G=0
Y=Y+1
end
if((l-M)>=60 or(l-M)<0)then
M=l
ah()end
end
function onPlayerJoin(steam_id,name,_,admin,auth)local j=X(_)local steam_id=i(_)local aa=m.getMapID()m.addAuth(_)D(aX,name.." joined the game")if(a.b[steam_id]~=C)then
a.b[steam_id].I=aa
ac(_)E(aN)return
end
a.b[steam_id]=L.aB(S)a.b[steam_id].name=h(j.name)a.b[steam_id].steam_id=h(steam_id)a.b[steam_id].I=aa
for o,d in p(as)do
if(d==steam_id)then
Z(_,"owner")Z(_,aV)m.addAdmin(_)end
end
R(_,"[Bank]","New bank account created!",8)E(aN)end
function onPlayerLeave(steam_id,name,_,admin,auth)local steam_id=i(_)D(aX,name.." left the game")m.removeMapID(_,a.b[steam_id].I)E(aN)end
function onCustomCommand(ay,_,aJ,aD,u,e,g,ae,az,av)local b=X(_)local steam_id=i(_)if(u=="?help")then
D(aL,"Help not available")elseif(u=="?tags")then
local e=q(e)if(not B(e))then
return
end
announce(aL,"Tags: "..aj(e),_)elseif(u=="?addMoney" and F(_,aV))then
local af=ar(e,g)if(af)then
notify(_,"Money Printing Company","Assignment done!",8)notify(e,aU,aK..g..aM,8)end
elseif(u=="?setMoney" and F(_,aV))then
an(e,g)notify(_,aU,"The balance of "..e.." was set to $"..g,8)notify(e,aU,"Your balance was set to "..g,8)elseif(u=="?removeMoney" and F(_,aV))then
ak(e,g)notify(_,aU,aK..g.." were removed from the bank account of "..e,8)notify(e,aU,aK..g..aP,8)elseif(u=="?transferMoney" and F(_,aV))then
Q(e,g,ae)notify(_,aU,aK..g.." were transfered from "..e..aW..g,8)notify(e,aU,aK..g..aM,8)notify(g,aU,aK..g..aP,8)elseif(u=="?sendMoney")then
Q(_,e,g)notify(_,aU,"You sended $"..g..aW..e,8)notify(e,aU,aK..g.." were sended to your bank account from "..b.name.."!",8)end
end
function X(_)local H=O()local j={id=0,name=aY,steam_id=aY,auth=s,admin=s}for o,d in p(H)do
if(h(d[aQ])==h(_))then
j.id=d.id
j.name=d.name
j.steam_id=h(d.steam_id)j.auth=d.auth
j.admin=d.admin
return j
end
end
end
function i(_)local H=O()for o,d in p(H)do
if(h(d[aQ])==h(_))then
return h(H[o].steam_id)end
end
end
function aj(_)local steam_id=i(_)return am(a.b[steam_id].tags)end
function F(_,v)local steam_id=i(_)for o,d in p(a.b[steam_id].tags)do
if(h(d)==h(v))then
return r
end
end
return s
end
function Z(_,v)local steam_id=i(_)for o,d in p(a.b[steam_id].tags)do
if(h(d)==h(v))then
return
end
end
L.insert(a.b[steam_id].tags,v)return r
end
function aF(_,v)local steam_id=i(_)for o,d in p(a.b[steam_id].tags)do
if(h(d)==h(v))then
L.remove(a.b[steam_id].tags,o)return r
end
end
end
function ag(_)local steam_id=i(_)return k(a.b[steam_id].f)end
function an(_,c)local steam_id=i(_)local c=q(c)if(not B(c))then
return
end
a.b[steam_id].f=c
end
function ar(_,c)local _=q(_)local steam_id=i(_)local c=q(c)if(not B(c))then
return
end
a.b[steam_id].f=k(a.b[steam_id].f)+c
return r
end
function ak(_,c)local steam_id=i(_)local c=q(c)if(not B(c))then
return
end
a.b[steam_id].f=k(a.b[steam_id].f)-c
return r
end
function Q(_,J,c)local n=i(_)local t=i(J)local c=q(c)if(not B(c))then
return
end
if(a.b[n]==C or a.b[t]==C)then
notify(_,aU,aT..c.." canceled! Recipient or sender are not found!",8)notify(J,aU,"Transfer canceled! Recipient or sender are not found!",8)return
end
if(k(a.b[n].f)<k(c))then
notify(_,aU,aT..c.." canceled! Not enough money!",8)return
end
if(_==J)then
notify(_,aU,"You cant send your self money!",8)end
local W=k(a.b[n].f)local aq=k(a.b[t].f)a.b[n].f=k(a.b[n].f)-k(c)if((W-a.b[n].f)~=c)then
a.b[n].f=W
notify(_,aU,aS,8)V(aR..n..aO..t.." Payment by payer has failed!")end
a.b[t].f=k(a.b[t].f)+k(c)if((a.b[t].f-aq)~=c)then
notify(_,aU,aS,8)V(aR..n..aO..t..". Payment by target has failed!")end
end
function au(P)local K=0
for ax in p(P)do K=K+1 end
return K
end
function B(d)if(type(d)==type(0))then
return r
end
return s
end
function aG(d)if(type(d)==type(aY))then
return r
end
return s
end
function notify(_,ao,w,ap)R(_,ao,w,ap)end
function announce(name,w,_)if(_==C)then
m.aI(name,w)elseif(_~=C and B(_))then
D(name,w,_)end
end
function V(w)a.T.U=a.T.U.."|"..w.."| "
end
function aH(_)local steam_id=i(_)return a.b[steam_id]end
function am(P)local N=aY
for o,d in p(P)do
N=N..h(o)..": "..h(d).."; "
end
return N
end
function k(d)return q(string.format("%.2f",d))end
function ac(_)local steam_id=i(_)m.setPopupScreen(_,a.b[steam_id].I,aY,r,"Balance: $"..ag(_),.56,.88)end
function ah()local j=O()for aw,j in p(j)do
ac(q(j.id))end
end
