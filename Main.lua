local Module = loadstring(game:HttpGet("https://raw.githubusercontent.com/RegularVynixu/Utilities/main/Discord%20Inviter/Source.lua"))()

Module.Prompt({ invite = "https://discord.com/invite/3PWnew539M", name = "Gravity Hub" }) -- name is optional

Module.Join("https://discord.com/invite/3PWnew539M")

if game.PlaceId == 286090429 then
   loadstring(game:HttpGet('https://raw.githubusercontent.com/SpinnyMemer/Gravity-Hub/refs/heads/main/Arsenal.lua'))()
elseif game.PlaceId == 17625359962 then
   loadstring(game:HttpGet('https://raw.githubusercontent.com/SpinnyMemer/Gravity-Hub/refs/heads/main/RIVALS.lua'))()
elseif game.PlaceId == 101435587895051 or 9441238005 or 17856909502 or 8255927517 then
   loadstring(game:HttpGet('https://raw.githubusercontent.com/SpinnyMemer/Gravity-Hub/refs/heads/main/RIVALS.lua'))()
elseif game.PlaceId = 893973440 then
   loadstring(game:HttpGet('https://raw.githubusercontent.com/SpinnyMemer/Gravity-Hub/refs/heads/main/Flee-The-Facility.lua'))()
else
   print("Game not supported :/")
end
