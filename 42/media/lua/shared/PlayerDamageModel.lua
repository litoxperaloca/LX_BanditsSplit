-- LX_BanditsSplit: reemplaza este archivo de Bandits por un cargador que lee el
-- ORIGINAL de Bandits (media/lua/shared/PlayerDamageModel.lua), aplica parches verificados para pantalla
-- dividida y lo ejecuta. Si Bandits cambia y un parche no encaja, se omite y se
-- avisa en console.txt (el archivo original sigue funcionando).
-- Generado por _claude_work/scripts/gen_bandits_split.py - no editar a mano.
require "LXBS_Core"

LXBS.LoadPatched("media/lua/shared/PlayerDamageModel.lua", {
    {
        id = "rasguno_melee",
        count = 1,
        find = [=[
        scratched = scratched,
        cut = cut,
        deepWound = deepWound,
        healthDrop = hitDmg,
    }
    sendClientCommand(player, "Commands", "PlayerDamage", args)

end]=],
        repl = [=[
        scratched = scratch,
        cut = cut,
        deepWound = deepWound,
        healthDrop = hitDmg,
    }
    sendClientCommand(player, "Commands", "PlayerDamage", args)

end]=],
    },
})
