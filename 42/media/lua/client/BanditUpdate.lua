-- LX_BanditsSplit: reemplaza este archivo de Bandits por un cargador que lee el
-- ORIGINAL de Bandits (media/lua/client/BanditUpdate.lua), aplica parches verificados para pantalla
-- dividida y lo ejecuta. Si Bandits cambia y un parche no encaja, se omite y se
-- avisa en console.txt (el archivo original sigue funcionando).
-- Generado por _claude_work/scripts/gen_bandits_split.py - no editar a mano.
require "LXBS_Core"

LXBS.LoadPatched("media/lua/client/BanditUpdate.lua", {
    {
        id = "luz_por_jugador",
        count = 1,
        find = [=[
local spottedScore = square:getLightLevel(0)]=],
        repl = [=[
local spottedScore = square:getLightLevel(LXBS.LightIndexFor(player))]=],
    },
    {
        id = "respiracion_jugador_cercano",
        count = 1,
        find = [=[
local function ManageEndurance(bandit)

    local player = getSpecificPlayer(0)]=],
        repl = [=[
local function ManageEndurance(bandit)

    local player = LXBS.NearestLocalPlayer(bandit)]=],
    },
    {
        id = "zombies_sin_jugador1",
        count = 1,
        find = [=[
local function UpdateZombies(zombie)

    local player = getSpecificPlayer(0)
    if not player then return end]=],
        repl = [=[
local function UpdateZombies(zombie)

    local player = LXBS.SenderPlayer()
    if not player then return end]=],
    },
    {
        id = "zombies_cerca_de_cualquier_jugador",
        count = 1,
        find = [=[
    local px, py, pz = player:getX(), player:getY(), player:getZ()
    local distPlayer2 = ((px - zx) * (px - zx)) + ((py - zy) * (py - zy))
    if distPlayer2 < 4 and math.abs(pz - zz) < 0.3 then
        return
    end]=],
        repl = [=[
    if LXBS.AnyLocalPlayerNear(zx, zy, zz, 4, 0.3) then
        return
    end]=],
    },
    {
        id = "sonido_tarea_jugador_cercano",
        count = 1,
        find = [=[
        if task.sound then
            local player = getSpecificPlayer(0)]=],
        repl = [=[
        if task.sound then
            local player = LXBS.NearestLocalPlayer(bandit)]=],
    },
    {
        id = "kills_del_que_mato",
        count = 1,
        find = [=[
        local player = getSpecificPlayer(0)
        local killer = bandit:getAttackedBy()
        if killer then
            if killer == player then
                player:setZombieKills(player:getZombieKills() - 1)
            end
        end]=],
        repl = [=[
        local player = LXBS.SenderPlayer()
        local killer = bandit:getAttackedBy()
        if killer and instanceof(killer, "IsoPlayer") and killer:isLocalPlayer() then
            killer:setZombieKills(killer:getZombieKills() - 1)
        end]=],
    },
    {
        id = "cadaver_remitente",
        count = 1,
        find = [=[
            local player = getSpecificPlayer(0)
            md.isDeadBandit = false]=],
        repl = [=[
            local player = LXBS.SenderPlayer()
            md.isDeadBandit = false]=],
    },
    {
        id = "comandos_remitente",
        count = 2,
        find = [=[
sendClientCommand(getSpecificPlayer(0), ]=],
        repl = [=[
sendClientCommand(LXBS.SenderPlayer(), ]=],
    },
    {
        id = "puerta_square_remitente",
        count = 1,
        find = [=[
local square = getSpecificPlayer(0):getSquare()]=],
        repl = [=[
local square = LXBS.SenderPlayer():getSquare()]=],
    },
})
