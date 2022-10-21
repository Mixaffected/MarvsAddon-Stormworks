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

f=table
j=g_savedata
c=tostring
g=pairs
n=false
h=server
l=h.getPlayers
function p(d)local i=l()local _={id=0,name=w,steam_id=w,auth=n,admin=n}for u,a in g(i)do
if(c(a["id"])==c(d))then
_.id=a.id
_.name=a.name
_.steam_id=c(a.steam_id)_.auth=a.auth
_.admin=a.admin
return _
end
end
end
function o(d)local b=p(d)local steam_id=b.steam_id
local k=j.b[steam_id].k
h.setPopupScreen(d,k,w,true,"$ "..c(j.b[b.steam_id].t),.56,.88)end
function s()local i=l()for r,_ in g(i)do
o(tonumber(_.id))end
end
function q(f)if type(f)~=v then return nil end
local e={}for m,value in g(f)do
if type(value)~=v then
e[m]=value
else
e[m]=q(value)end
end
return e
end
function save()h.save("scriptsave")end
