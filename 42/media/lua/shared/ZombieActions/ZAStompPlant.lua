-- LX_BanditsSplit: reemplaza este archivo de Bandits por un cargador que lee el
-- ORIGINAL de Bandits (media/lua/shared/ZombieActions/ZAStompPlant.lua), aplica parches verificados para pantalla
-- dividida y lo ejecuta. Si Bandits cambia y un parche no encaja, se omite y se
-- avisa en console.txt (el archivo original sigue funcionando).
-- Generado por _claude_work/scripts/gen_bandits_split.py - no editar a mano.
require "LXBS_Core"

LXBS.LoadPatched("media/lua/shared/ZombieActions/ZAStompPlant.lua", {
    {
        id = "sin_require_cliente_en_shared",
        count = 1,
        find = [=[
require "Farming/CFarmingSystem"
]=],
        repl = [=[
-- (LX) require "Farming/CFarmingSystem": archivo de cliente aun no cargado; se usa solo en runtime
]=],
    },
    {
        id = "remitente_comando_granja",
        count = 1,
        find = [=[
CFarmingSystem.instance:sendCommand(getSpecificPlayer(0), ]=],
        repl = [=[
CFarmingSystem.instance:sendCommand(LXBS.SenderPlayer(), ]=],
    },
})
