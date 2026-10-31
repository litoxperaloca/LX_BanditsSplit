--[[
    LX_BanditsSplit - mejoras de IA (opcionales, desde el menu de opciones).

    Investigar ruidos: cuando CUALQUIER jugador local hace un ruido fuerte (disparo,
    alarma, golpe a una puerta...), los bandidos hostiles que lo escucharon guardan esa
    posicion como "ultima posicion conocida". Bandits ya usa ese dato cuando no ve a nadie:
    caminan hasta ahi a buscar. Asi buscan a los dos jugadores, no solo al jugador 1.
]]

require "LXBS_Core"

LXBS.opt = LXBS.opt or { investigate = true, minRadius = 12 }

local lastByPlayer = {}

local function onWorldSound(x, y, z, radius, volume, source)
    if not LXBS.opt.investigate or not source then return end
    if not radius or radius < LXBS.opt.minRadius then return end
    if not instanceof(source, "IsoPlayer") then return end
    local okL, isLocal = pcall(source.isLocalPlayer, source)
    if not okL or not isLocal then return end
    if not BanditZombie or not BanditZombie.CacheLightB or not BanditUtils then return end

    -- como mucho una vez cada 1.5 s por jugador (los disparos en rafaga generan muchos eventos)
    local now = getTimestampMs()
    local pn = source:getPlayerNum() or 0
    if lastByPlayer[pn] and now - lastByPlayer[pn] < 1500 then return end
    lastByPlayer[pn] = now

    local r2 = radius * radius
    local pid = BanditUtils.GetCharacterID(source)
    local dir = source:getDirectionAngle()
    for id, light in pairs(BanditZombie.CacheLightB) do
        if light and light.x and math.abs((light.z or 0) - z) < 1.5 then
            local dx, dy = light.x - x, light.y - y
            if dx * dx + dy * dy <= r2 then
                local bandit = BanditZombie.Cache[id]
                local brain = bandit and BanditBrain.Get(bandit)
                if brain and (brain.hostile or brain.hostileP) and not brain.master then
                    brain.lastPost = { x = x, y = y, z = z, id = pid, d = dir }
                end
            end
        end
    end
end

Events.OnWorldSound.Add(function(x, y, z, radius, volume, source)
    local ok, err = pcall(onWorldSound, x, y, z, radius, volume, source)
    if not ok then LXBS.log("OnWorldSound: " .. tostring(err)) end
end)

-- Resumen de parches al iniciar partida (queda en console.txt)
Events.OnGameStart.Add(function()
    local total, okCount = 0, 0
    for rel, r in pairs(LXBS.report or {}) do
        total = total + #r.applied + #r.skipped
        okCount = okCount + #r.applied
    end
    LXBS.log("parches de pantalla dividida activos: " .. okCount .. "/" .. total)
end)

-- Opciones
if PZAPI and PZAPI.ModOptions then
    local opts = PZAPI.ModOptions:create("LXBanditsSplit", getText("UI_LXBS_name"))
    opts:addDescription(getText("UI_LXBS_desc"))
    local tInv = opts:addTickBox("INVESTIGATE", getText("UI_LXBS_investigate"), true, getText("UI_LXBS_investigate_tip"))
    local sRad = opts:addSlider("MIN_RADIUS", getText("UI_LXBS_radius"), 6, 40, 1, 12, getText("UI_LXBS_radius_tip"))
    opts.apply = function(self)
        LXBS.opt.investigate = tInv:getValue() == true
        LXBS.opt.minRadius = sRad:getValue()
    end
    Events.OnMainMenuEnter.Add(function() opts:apply() end)
    Events.OnGameStart.Add(function() opts:apply() end)
end
