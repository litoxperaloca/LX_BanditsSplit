-- LX_BanditsSplit: reemplaza este archivo de Bandits por un cargador que lee el
-- ORIGINAL de Bandits (media/lua/client/ISUI/BanditCharacterScreen.lua), aplica parches verificados para pantalla
-- dividida y lo ejecuta. Si Bandits cambia y un parche no encaja, se omite y se
-- avisa en console.txt (el archivo original sigue funcionando).
-- Generado por _claude_work/scripts/gen_bandits_split.py - no editar a mano.
require "LXBS_Core"

LXBS.LoadPatched("media/lua/client/ISUI/BanditCharacterScreen.lua", {
    {
        id = "require_ruta_correcta",
        count = 1,
        find = [=[
require "ISUI/ISCharacterScreen"]=],
        repl = [=[
require "XpSystem/ISUI/ISCharacterScreen"]=],
    },
    {
        id = "kills_por_jugador",
        count = 1,
        find = [=[
local function getBanditKillCount()
    local gmd = GetBanditModData()
    local id = BanditUtils.GetCharacterID(getSpecificPlayer(0))]=],
        repl = [=[
local function getBanditKillCount(lxPlayer)
    local gmd = GetBanditModData()
    local id = BanditUtils.GetCharacterID(lxPlayer or getSpecificPlayer(0))]=],
    },
    {
        id = "kills_del_jugador_de_esta_pantalla",
        count = 1,
        find = [=[
        local banditKills = getBanditKillCount()]=],
        repl = [=[
        local banditKills = getBanditKillCount(self.char or (self.playerNum and getSpecificPlayer(self.playerNum)))]=],
    },
})
