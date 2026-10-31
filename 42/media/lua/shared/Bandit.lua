-- LX_BanditsSplit: reemplaza este archivo de Bandits por un cargador que lee el
-- ORIGINAL de Bandits (media/lua/shared/Bandit.lua), aplica parches verificados para pantalla
-- dividida y lo ejecuta. Si Bandits cambia y un parche no encaja, se omite y se
-- avisa en console.txt (el archivo original sigue funcionando).
-- Generado por _claude_work/scripts/gen_bandits_split.py - no editar a mano.
require "LXBS_Core"

LXBS.LoadPatched("media/lua/shared/Bandit.lua", {
    {
        id = "habla_cerca_de_cualquier_jugador",
        count = 1,
        find = [=[
    local player = getSpecificPlayer(0)
    if not player then return end

    local dist = BanditUtils.DistTo(player:getX(), player:getY(), zombie:getX(), zombie:getY())]=],
        repl = [=[
    local player = LXBS.NearestLocalPlayer(zombie)
    if not player then return end

    local dist = BanditUtils.DistTo(player:getX(), player:getY(), zombie:getX(), zombie:getY())]=],
    },
    {
        id = "comandos_remitente",
        count = 1,
        find = [=[
sendClientCommand(getSpecificPlayer(0), ]=],
        repl = [=[
sendClientCommand(LXBS.SenderPlayer(), ]=],
    },
})
