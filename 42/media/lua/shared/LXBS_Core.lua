--[[
    LX_BanditsSplit - nucleo.

    1) Helpers "multi jugador local" (pantalla dividida) que usan los parches.
    2) Cargador de parches de texto: lee el archivo ORIGINAL de Bandits (siempre la version
       instalada), aplica sustituciones exactas y verificadas, y lo ejecuta en lugar del
       original. Si una sustitucion no encuentra su texto (porque Bandits se actualizo),
       esa sustitucion se omite y se avisa en console.txt; el resto del archivo funciona
       igual que el original. Nunca se ejecuta un archivo dos veces.
]]

LXBS = LXBS or {}
LXBS.TARGET_MOD = "Bandits2"
LXBS.report = LXBS.report or {}

local function log(msg) print("[LX_BanditsSplit] " .. tostring(msg)) end
LXBS.log = log

-- =====================================================================
-- Helpers de jugadores locales
-- =====================================================================

function LXBS.IsSP()
    local w = getWorld and getWorld()
    if not w then return true end
    return w:getGameMode() ~= "Multiplayer"
end

-- Itera los jugadores locales existentes (slots 0..3 pueden tener huecos).
function LXBS.ForEachLocalPlayer(fn)
    for i = 0, 3 do
        local p = getSpecificPlayer(i)
        if p then
            if fn(p, i) == false then return end
        end
    end
end

function LXBS.FirstLocalPlayer()
    local alive, any = nil, nil
    LXBS.ForEachLocalPlayer(function(p)
        if not any then any = p end
        if not alive and p:isAlive() then alive = p end
    end)
    return alive or any
end

-- Jugador para enviar comandos cliente->servidor. En SP el servidor ignora a quien se
-- usa como "remitente" en estos comandos, pero si es nil el comando se pierde: por eso,
-- si el slot 0 esta vacio (jugador 1 muerto/fuera), usamos otro jugador local.
function LXBS.SenderPlayer()
    return getSpecificPlayer(0) or LXBS.FirstLocalPlayer()
end

function LXBS.NearestLocalPlayer(obj)
    if not obj then return getSpecificPlayer(0) end
    local ox, oy = obj:getX(), obj:getY()
    local best, bestD = nil, math.huge
    LXBS.ForEachLocalPlayer(function(p)
        if p:isAlive() then
            local dx, dy = p:getX() - ox, p:getY() - oy
            local d = dx * dx + dy * dy
            if d < bestD then best, bestD = p, d end
        end
    end)
    return best or getSpecificPlayer(0)
end

function LXBS.RandomLocalPlayer()
    local list = {}
    LXBS.ForEachLocalPlayer(function(p) if p:isAlive() then list[#list + 1] = p end end)
    if #list == 0 then return getSpecificPlayer(0) end
    return list[ZombRand(#list) + 1]
end

-- ID estable de un jugador LOCAL en SP: 1..4 (jugador 1 conserva el 1 -> partidas viejas OK).
-- El original devolvia 1 para todos: el jugador 2 era indistinguible del 1.
function LXBS.LocalPlayerId(character)
    local ok, n = pcall(character.getPlayerNum, character)
    if ok and type(n) == "number" and n >= 0 and n <= 3 then return n + 1 end
    return 1
end

-- Indice de luz a usar para "que tan visible es" un personaje: la luz se calcula POR
-- jugador (incluye su cono de vision). El original usaba siempre la del jugador 1.
function LXBS.LightIndexFor(character)
    if character and instanceof(character, "IsoPlayer") then
        local ok, isLocal = pcall(character.isLocalPlayer, character)
        if ok and isLocal then
            local n = character:getPlayerNum()
            if n and n >= 0 and n <= 3 then return n end
        end
    end
    local p = LXBS.NearestLocalPlayer(character)
    if p then
        local n = p:getPlayerNum()
        if n and n >= 0 and n <= 3 then return n end
    end
    return 0
end

function LXBS.AnyLocalPlayerNear(x, y, z, distSq, maxDz)
    local found = false
    LXBS.ForEachLocalPlayer(function(p)
        if p:isAlive() then
            local dx, dy = p:getX() - x, p:getY() - y
            if dx * dx + dy * dy < distSq and math.abs(p:getZ() - z) < maxDz then
                found = true
                return false
            end
        end
    end)
    return found
end

-- El empujon solo afecta al jugador que realmente esta al lado del bandido.
function LXBS.InShoveRange(bandit, player)
    if not bandit or not player then return false end
    if math.abs(player:getZ() - bandit:getZ()) >= 0.5 then return false end
    local dx, dy = player:getX() - bandit:getX(), player:getY() - bandit:getY()
    return (dx * dx + dy * dy) < 2.25 -- 1.5 tiles
end

-- Companero: sigue a quien lo recluto (si vive); si no, al jugador local mas cercano.
function LXBS.MasterPlayer(bandit)
    local id = Bandit and Bandit.GetMaster and Bandit.GetMaster(bandit)
    if type(id) == "number" and BanditPlayer and BanditPlayer.GetPlayerById then
        local p = BanditPlayer.GetPlayerById(id)
        if p and p:isAlive() then return p end
    end
    return LXBS.NearestLocalPlayer(bandit)
end

-- =====================================================================
-- Cargador de parches de texto
-- =====================================================================

local function readModFile(modId, rel)
    local ok, reader = pcall(getModFileReader, modId, rel, false)
    if not ok or not reader then return nil end
    local lines = {}
    local line = reader:readLine()
    while line ~= nil do
        lines[#lines + 1] = line
        line = reader:readLine()
    end
    reader:close()
    return table.concat(lines, "\n") .. "\n"
end

local function escapePattern(s)
    return (string.gsub(s, "[%^%$%(%)%%%.%[%]%*%+%-%?]", function(c) return "%" .. c end))
end

-- Reemplazo literal (sin patrones). Devuelve texto nuevo y cantidad de reemplazos.
local function plainReplace(src, find, repl)
    local pat = escapePattern(find)
    local parts, pos, count = {}, 1, 0
    while true do
        local s, e = string.find(src, pat, pos)
        if not s then break end
        parts[#parts + 1] = string.sub(src, pos, s - 1)
        parts[#parts + 1] = repl
        pos = e + 1
        count = count + 1
    end
    parts[#parts + 1] = string.sub(src, pos)
    return table.concat(parts), count
end

local function countOccurrences(src, find)
    local _, n = plainReplace(src, find, "")
    return n
end

LXBS._plainReplace = plainReplace -- expuesto para pruebas

-- rel: ruta dentro del mod Bandits (p.ej. "media/lua/client/BanditUpdate.lua")
-- patches: lista de { id=, find=, repl=, count= } (count = ocurrencias exactas esperadas)
function LXBS.LoadPatched(rel, patches)
    local src = readModFile(LXBS.TARGET_MOD, rel)
    if not src then
        log("ERROR: no pude leer " .. rel .. " de " .. LXBS.TARGET_MOD .. ". Bandits activo? (archivo NO cargado)")
        return false
    end

    local applied, skipped = {}, {}
    local patched = src
    for _, p in ipairs(patches) do
        local expected = p.count or 1
        local n = countOccurrences(patched, p.find)
        if n == expected then
            patched = plainReplace(patched, p.find, p.repl)
            applied[#applied + 1] = p.id
        else
            skipped[#skipped + 1] = p.id .. " (encontrado " .. n .. ", esperado " .. expected .. ")"
        end
    end

    local chunk, err = loadstring(patched, "@Bandits/" .. rel)
    if not chunk then
        log("ERROR compilando " .. rel .. " parcheado: " .. tostring(err) .. " -> uso el ORIGINAL sin parches")
        chunk, err = loadstring(src, "@Bandits/" .. rel)
        applied = {}
        if not chunk then
            log("ERROR compilando original " .. rel .. ": " .. tostring(err))
            return false
        end
    end

    LXBS.report[rel] = { applied = applied, skipped = skipped }
    if #skipped > 0 then
        log(rel .. ": " .. #applied .. " parches OK, OMITIDOS: " .. table.concat(skipped, "; "))
    else
        log(rel .. ": " .. #applied .. "/" .. #patches .. " parches OK")
    end

    if LXBS.DRY_RUN then return true end -- usado solo por el test offline
    chunk()
    return true
end
