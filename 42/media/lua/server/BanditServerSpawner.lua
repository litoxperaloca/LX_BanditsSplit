-- LX_BanditsSplit: reemplaza este archivo de Bandits por un cargador que lee el
-- ORIGINAL de Bandits (media/lua/server/BanditServerSpawner.lua), aplica parches verificados para pantalla
-- dividida y lo ejecuta. Si Bandits cambia y un parche no encaja, se omite y se
-- avisa en console.txt (el archivo original sigue funcionando).
-- Generado por _claude_work/scripts/gen_bandits_split.py - no editar a mano.
require "LXBS_Core"

LXBS.LoadPatched("media/lua/server/BanditServerSpawner.lua", {
    {
        id = "incursiones_alrededor_de_cualquier_jugador",
        count = 1,
        find = [=[
        day = getWorldAge()
        player = getSpecificPlayer(0)]=],
        repl = [=[
        day = getWorldAge()
        player = LXBS.RandomLocalPlayer()]=],
    },
})
