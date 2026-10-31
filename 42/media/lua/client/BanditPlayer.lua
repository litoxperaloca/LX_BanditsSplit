-- LX_BanditsSplit: reemplaza este archivo de Bandits por un cargador que lee el
-- ORIGINAL de Bandits (media/lua/client/BanditPlayer.lua), aplica parches verificados para pantalla
-- dividida y lo ejecuta. Si Bandits cambia y un parche no encaja, se omite y se
-- avisa en console.txt (el archivo original sigue funcionando).
-- Generado por _claude_work/scripts/gen_bandits_split.py - no editar a mano.
require "LXBS_Core"

LXBS.LoadPatched("media/lua/client/BanditPlayer.lua", {
    {
        id = "buscar_jugador_por_id_sp",
        count = 1,
        find = [=[
BanditPlayer.GetPlayerById = function(id)
    local playerList = BanditPlayer.GetPlayers()]=],
        repl = [=[
BanditPlayer.GetPlayerById = function(id)
    if LXBS.IsSP() and type(id) == "number" and id >= 1 and id <= 4 then
        local lxp = getSpecificPlayer(id - 1)
        if lxp then return lxp end
    end
    local playerList = BanditPlayer.GetPlayers()]=],
    },
    {
        id = "companero_sigue_a_su_jugador",
        count = 1,
        find = [=[
        master = getSpecificPlayer(0)]=],
        repl = [=[
        master = LXBS.MasterPlayer(bandit)]=],
    },
    {
        id = "estado_online_todos_los_jugadores",
        count = 1,
        find = [=[
    local player = getSpecificPlayer(0)
    if player then
        local playerData = {}
        playerData.id = BanditUtils.GetCharacterID(player)
        playerData.name = player:getDisplayName()
        playerData.isGhost = player:isGhostMode()
        sendClientCommand(player, 'Players', 'PlayerUpdate', playerData)
    end]=],
        repl = [=[
    LXBS.ForEachLocalPlayer(function(player)
        local playerData = {}
        playerData.id = BanditUtils.GetCharacterID(player)
        playerData.name = player:getDisplayName()
        playerData.isGhost = player:isGhostMode()
        sendClientCommand(player, 'Players', 'PlayerUpdate', playerData)
    end)]=],
    },
})
