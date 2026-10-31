-- LX_BanditsSplit: reemplaza este archivo de Bandits por un cargador que lee el
-- ORIGINAL de Bandits (media/lua/shared/ZombieActions/ZAPush.lua), aplica parches verificados para pantalla
-- dividida y lo ejecuta. Si Bandits cambia y un parche no encaja, se omite y se
-- avisa en console.txt (el archivo original sigue funcionando).
-- Generado por _claude_work/scripts/gen_bandits_split.py - no editar a mano.
require "LXBS_Core"

LXBS.LoadPatched("media/lua/shared/ZombieActions/ZAPush.lua", {
    {
        id = "empujon_solo_al_cercano",
        count = 1,
        find = [=[
                    if player:isAlive() and eid == task.eid then
                        ShovePlayer (bandit, player)]=],
        repl = [=[
                    if player:isAlive() and eid == task.eid and LXBS.InShoveRange(bandit, player) then
                        ShovePlayer (bandit, player)]=],
    },
})
