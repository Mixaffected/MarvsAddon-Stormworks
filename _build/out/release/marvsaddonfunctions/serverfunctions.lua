-- Author: !true
-- GitHub: https://github.com/nottruenow64bit
-- Workshop: https://steamcommunity.com/id/QuestionmarkTrue/myworkshopfiles/
--
-- Developed & Minimized using LifeBoatAPI - Stormworks Lua plugin for VSCode
-- https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--      By Nameous Changey
-- Minimized Size: 700 (1079 with comment) chars
w=""
v="table"

e=table
m=g_savedata
d=tostring
i=pairs
k=false
g=server
j=g.getPlayers
function q(c)local f=j()local _={id=0,name=w,steam_id=w,auth=k,admin=k}for s,a in i(f)do
if(d(a["id"])==d(c))then
_.id=a.id
_.name=a.name
_.steam_id=d(a.steam_id)_.auth=a.auth
_.admin=a.admin
return _
end
end
end
function p(c)local b=q(c)local steam_id=b.steam_id
local n=m.b[steam_id].n
g.setPopupScreen(c,n,w,true,"$ "..d(m.b[b.steam_id].t),.56,.88)end
function r()local f=j()for u,_ in i(f)do
p(tonumber(_.id))end
end
function o(e)if type(e)~=v then return nil end
local h={}for l,value in i(e)do
if type(value)~=v then
h[l]=value
else
h[l]=o(value)end
end
return h
end
function save()g.save("scriptsave")end
