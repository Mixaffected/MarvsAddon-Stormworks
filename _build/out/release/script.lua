-- Author: !true
-- GitHub: https://github.com/nottruenow64bit
-- Workshop: https://steamcommunity.com/id/QuestionmarkTrue/myworkshopfiles/
--
-- Developed & Minimized using LifeBoatAPI - Stormworks Lua plugin for VSCode
-- https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--      By Nameous Changey
-- Minimized Size: 1695 (2076 with comment) chars
Q=""
P="scriptsave"
O="[Server]"
N="table"

w=nil
q=table
E=tonumber
c=g_savedata
f=tostring
i=pairs
B=false
d=server
l=d.announce
D=d.save
C=d.getPlayers
function n(_)local r=C()local e={id=0,name=Q,steam_id=Q,auth=B,admin=B}for L,g in i(r)do
if(f(g["id"])==f(_))then
e.id=g.id
e.name=g.name
e.steam_id=f(g.steam_id)e.auth=g.auth
e.admin=g.admin
return e
end
end
end
function o(_)local a=n(_)local steam_id=a.steam_id
local b=c.a[steam_id].b
d.setPopupScreen(_,b,Q,true,"$ "..f(c.a[a.steam_id].A),.56,.88)end
function H()local r=C()for K,e in i(r)do
o(E(e.id))end
end
function s(q)if type(q)~=N then return w end
local m={}for p,value in i(q)do
if type(value)~=N then
m[p]=value
else
m[p]=s(value)end
end
return m
end
function save()D(P)end
c={M={},v={t=20000},a={}}u={name=Q,steam_id=Q,A=0,b=-1}admin={"76561198346789290","76561197976360068"}j=0
k=0
function onCreate(F)if F then
c.v.t=E(property.slider("Start Money",5000,200000,5000,35000))end
u.A=c.v.t
end
function onDestroy()save()end
function onTick(J)j=j+1
if j>=60 then
j=0
H()end
k=k+1
if k>=300 then
k=0
save()end
end
function onPlayerJoin(steam_id,name,_,G,I)local a=n(_)local steam_id=a.steam_id
local b=d.getMapID()d.addAuth(_)l(O,name.." joined the game")for p,value in i(admin)do
if f(value)==f(steam_id)then
d.addAdmin(_)l(O,"You are now Admin",_)return
end
end
if c.a[steam_id]~=w then
c.a[steam_id].b=b
o(_)D(P)return
end
local h=s(u)h.name=a.name
h.steam_id=f(steam_id)h.b=b
c.a[steam_id]=h
o(_)d.notify(_,"[Bank]","New bank account created!",8)save()end
function onPlayerLeave(steam_id,name,_,G,I)local a=n(_)local steam_id=a.steam_id
d.removeMapID(_,c.a[steam_id].b)c.a[steam_id].b=-1
l(O,name.." left the game")save()end
