-- LX_BanditsSplit: reemplaza este archivo de Bandits por un cargador que lee el
-- ORIGINAL de Bandits (media/lua/shared/BanditUtils.lua), aplica parches verificados para pantalla
-- dividida y lo ejecuta. Si Bandits cambia y un parche no encaja, se omite y se
-- avisa en console.txt (el archivo original sigue funcionando).
-- Generado por _claude_work/scripts/gen_bandits_split.py - no editar a mano.
require "LXBS_Core"

LXBS.LoadPatched("media/lua/shared/BanditUtils.lua", {
    {
        id = "id_por_jugador_local",
        count = 1,
        find = [=[
        if gamemode == "Multiplayer" then
            id = character:getOnlineID()
        else
            id = 1
        end]=],
        repl = [=[
        if gamemode == "Multiplayer" then
            id = character:getOnlineID()
        else
            id = LXBS.LocalPlayerId(character)
        end]=],
    },
    {
        id = "objetivo_solo_vivos",
        count = 1,
        find = [=[
        if player and not BanditPlayer.IsGhost(player) then
            local px, py, pz = player:getX(), player:getY(), player:getZ()
            local dx = cx - px]=],
        repl = [=[
        if player and player:isAlive() and not BanditPlayer.IsGhost(player) then
            local px, py, pz = player:getX(), player:getY(), player:getZ()
            local dx = cx - px]=],
    },
    {
        id = "sync_salud_id_victima",
        count = 1,
        find = [=[
                local id = BanditUtils.GetCharacterID(bandit)
                local args = {id=id, h=h}]=],
        repl = [=[
                local id = BanditUtils.GetCharacterID(victim)
                local args = {id=id, h=h}]=],
    },
    {
        id = "comandos_remitente",
        count = 1,
        find = [=[
sendClientCommand(getSpecificPlayer(0), ]=],
        repl = [=[
sendClientCommand(LXBS.SenderPlayer(), ]=],
    },
    {
        id = "linea_de_fuego_remitente",
        count = 1,
        find = [=[
    local player = getSpecificPlayer(0)
    local piercing = weaponItem:isPiercingBullets()]=],
        repl = [=[
    local player = LXBS.SenderPlayer()
    local piercing = weaponItem:isPiercingBullets()]=],
    },
})
