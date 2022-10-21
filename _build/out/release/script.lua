-- Author: !true
-- GitHub: https://github.com/nottruenow64bit
-- Workshop: https://steamcommunity.com/id/QuestionmarkTrue/myworkshopfiles/
--
-- Developed & Minimized using LifeBoatAPI - Stormworks Lua plugin for VSCode
-- https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--      By Nameous Changey
-- Minimized Size: 1695 (2076 with comment) chars
Q=""
P="table"
O="[Server]"
N="scriptsave"

t=nil
l=table
s=tonumber
c=g_savedata
f=tostring
h=pairs
A=false
d=server
m=d.announce
D=d.save
v=d.getPlayers
function o(_)local p=v()local e={id=0,name=Q,steam_id=Q,auth=A,admin=A}for K,g in h(p)do
if(f(g["id"])==f(_))then
e.id=g.id
e.name=g.name
e.steam_id=f(g.steam_id)e.auth=g.auth
e.admin=g.admin
return e
end
end
end
function q(_)local a=o(_)local steam_id=a.steam_id
local b=c.a[steam_id].b
d.setPopupScreen(_,b,Q,true,"$ "..f(c.a[a.steam_id].E),.56,.88)end
function I()local p=v()for J,e in h(p)do
q(s(e.id))end
end
function C(l)if type(l)~=P then return t end
local n={}for r,value in h(l)do
if type(value)~=P then
n[r]=value
else
n[r]=C(value)end
end
return n
end
function save()D(N)end
c={M={},u={w=20000},a={}}B={name=Q,steam_id=Q,E=0,b=-1}admin={"76561198346789290","76561197976360068"}i=0
k=0
function onCreate(G)if G then
c.u.w=s(property.slider("Start Money",5000,200000,5000,35000))end
B.E=c.u.w
end
function onDestroy()save()end
function onTick(L)i=i+1
if i>=60 then
i=0
I()end
k=k+1
if k>=300 then
k=0
save()end
end
function onPlayerJoin(steam_id,name,_,F,H)local a=o(_)local steam_id=a.steam_id
local b=d.getMapID()d.addAuth(_)m(O,name.." joined the game")for r,value in h(admin)do
if f(value)==f(steam_id)then
d.addAdmin(_)m(O,"You are now Admin",_)return
end
end
if c.a[steam_id]~=t then
c.a[steam_id].b=b
q(_)D(N)return
end
local j=C(B)j.name=a.name
j.steam_id=f(steam_id)j.b=b
c.a[steam_id]=j
q(_)d.notify(_,"[Bank]","New bank account created!",8)save()end
function onPlayerLeave(steam_id,name,_,F,H)local a=o(_)local steam_id=a.steam_id
d.removeMapID(_,c.a[steam_id].b)c.a[steam_id].b=-1
m(O,name.." left the game")save()end
