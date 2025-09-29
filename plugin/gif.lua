dgsLogLuaMemory()
dgsRegisterPluginType("dgs-dxgif")
local strByte = string.byte
local strSub = string.sub
local strChar = string.char
local mathFloor = math.floor
local mathMax = math.max
local mathMin = math.min
local mathClamp = math.clamp
local tableConcat = table.concat
local powTable = {1,2,4,8,16,32,64,128,256,512,1024,2048,4096,8192,16384,32768,65536,131072,262144,524288,1048576,2097152,4194304,8388608,16777216,33554432,67108864,134217728,268435456,536870912,1073741824,2147483648}

addEvent("onDgsGIFPlay", true)
addEvent("onDgsGIFStop", true)

local MAX_FRAMES_DEFAULT = math.huge

local function readLE16(s, pos)
    local a, b = strByte(s, pos, pos + 1)
    return a + (b or 0) * 256
end

-- LZW Decoder (unchanged - outputs indices as numbers)
local function lzwDecode(minCodeSize, data, expectedSize)
    local dataBytes
    if type(data) == "table" then
        dataBytes = data
    else
        dataBytes = {}
        for i = 1, #data do
            dataBytes[i] = strByte(data, i)
        end
    end
    local dataLen = #dataBytes
    local dataPos = 1
    local bitBuffer = 0
    local bitCount = 0

    local dictSize = powTable[minCodeSize + 1]
    local clearCode = dictSize
    local endCode = clearCode + 1
    local nextCodeInit = endCode + 1
    local codeSizeInit = minCodeSize + 1
    local limitInit = powTable[codeSizeInit + 1]

    local dict = {}
    for i = 1, dictSize do
        dict[i] = {i-1}
    end
    local nextCode = nextCodeInit
    local codeSize = codeSizeInit
    local limit = limitInit
    local prev = nil
    local out = {}
    local outLen = 0

    while true do
        local code
        do
            while bitCount < codeSize and dataPos <= dataLen do
                local b = dataBytes[dataPos] or 0
                bitBuffer = bitBuffer + b * powTable[bitCount + 1]
                dataPos = dataPos + 1
                bitCount = bitCount + 8
            end
            local mask = powTable[codeSize + 1]
            code = bitBuffer % mask
            bitBuffer = bitBuffer / mask
            bitBuffer = bitBuffer - bitBuffer % 1
            bitCount = bitCount - codeSize
        end
        if code == clearCode then
            dict = {}
            for i = 1, dictSize do
                dict[i] = {i-1}
            end
            nextCode = nextCodeInit
            codeSize = codeSizeInit
            limit = limitInit
            prev = nil
        elseif code == endCode then
            break
        else
            local entry = dict[code+1]
            if not entry then
                if code == nextCode and prev then
                    local e = {}
                    for k = 1, #prev do e[k] = prev[k] end
                    e[#e+1] = prev[1]
                    entry = e
                else
                    break
                end
            end
            for k = 1, #entry do
                outLen = outLen + 1
                out[outLen] = entry[k]
            end
            if prev then
                local newEntry = {}
                for k = 1, #prev do newEntry[k] = prev[k] end
                newEntry[#newEntry+1] = entry[1]
                nextCode = nextCode + 1
                dict[nextCode] = newEntry
                if nextCode >= limit and codeSize < 12 then
                    codeSize = codeSize + 1
                    limit = limit * 2
                end
            end
            prev = entry
        end
        if expectedSize and outLen >= expectedSize then break end
    end
    return out
end

local function deinterlace(indices, w, h)
    local out = {}
    local idx = 1
    local function pass(start, step)
        for y = start, h - 1, step do
            for x = 0, w - 1 do
                out[y * w + x + 1] = indices[idx]
                idx = idx + 1
            end
        end
    end
    pass(0, 8)
    pass(4, 8)
    pass(2, 4)
    pass(1, 2)
    return out
end

-- ✅ MODIFIED: palette now stores BGRA strings
local function parseColorTable(data, pos, count)
    local palette = {}
    for i = 1, count do
        local r = strByte(data, pos)
        local g = strByte(data, pos + 1)
        local b = strByte(data, pos + 2)
        palette[i - 1] = strChar(b, g, r, 255)  -- BGRA
        pos = pos + 3
    end
    return palette, pos
end

-- ✅ MODIFIED: backup/restore for string-based canvas
local function backupRegion(c, left, top, iw, ih, w, h)
    local rows = {}
    local x0 = mathMax(0, left)
    local y0 = mathMax(0, top)
    local x1 = mathMin(w - 1, left + iw - 1)
    local y1 = mathMin(h - 1, top + ih - 1)
    for y = y0, y1 do
        local rowPixels = {}
        for x = x0, x1 do
            rowPixels[#rowPixels + 1] = c[y * w + x + 1]
        end
        rows[#rows + 1] = {y, x0, x1, tableConcat(rowPixels)}
    end
    return rows
end

local function restoreRegion(c, backup, w)
    if not backup then return end
    for i = 1, #backup do
        local entry = backup[i]
        local y, x0, x1, data = entry[1], entry[2], entry[3], entry[4]
        local idx = 1
        for x = x0, x1 do
            c[y * w + x + 1] = strSub(data, idx, idx + 3)
            idx = idx + 4
        end
    end
end

-- ✅ MODIFIED: buildDDS now trivial
local function writeLE32(n)
    local a = n % 0x100
    n = (n-a)/0x100
    local b = n % 0x100
    n = (n-b)/0x100
    local c = n % 0x100
    n = (n-c)/0x100
    local d = n % 0x100
    return strChar(a,b,c,d)
end

function buildDDS(w, h, canvas)   -- canvas is table of BGRA strings
    local DDSD_CAPS = 0x1
    local DDSD_HEIGHT = 0x2
    local DDSD_WIDTH = 0x4
    local DDSD_PITCH = 0x8
    local DDSD_PIXELFORMAT = 0x1000
    local DDPF_ALPHAPIXELS = 0x1
    local DDPF_RGB = 0x40
    local DDSCAPS_TEXTURE = 0x1000

    local LE32D0 = writeLE32(0)
    local parts = {
        "DDS ",
        writeLE32(124),
        writeLE32(DDSD_CAPS + DDSD_HEIGHT + DDSD_WIDTH + DDSD_PIXELFORMAT + DDSD_PITCH),
        writeLE32(h),
        writeLE32(w),
        writeLE32(w * 4),
        LE32D0, LE32D0,
        LE32D0,LE32D0,LE32D0,LE32D0,LE32D0,LE32D0,
        LE32D0,LE32D0,LE32D0,LE32D0,LE32D0,
        writeLE32(32),
        writeLE32(DDPF_ALPHAPIXELS + DDPF_RGB),
        LE32D0,
        writeLE32(32),
        writeLE32(0x00FF0000),
        writeLE32(0x0000FF00),
        writeLE32(0x000000FF),
        writeLE32(0xFF000000),
        writeLE32(DDSCAPS_TEXTURE), LE32D0, LE32D0, LE32D0, LE32D0,
    }
    parts[#parts + 1] = tableConcat(canvas)
    return tableConcat(parts)
end

-- ✅ MODIFIED: dgsGIFDecode uses string-based canvas
function dgsGIFDecode(input, maxFrames)
    maxFrames = maxFrames or MAX_FRAMES_DEFAULT
    if type(input) ~= "string" then error(dgsGenAsrt(input,"dgsGIFDecode",1,"string or binary string")) end
    local raw
    local sR = sourceResource or resource
    local name = getResourceName(sR)
    local finalPath = input
    if not input:find(":") then
        local firstOne = input:sub(1,1)
        if firstOne == "/" then input = input:sub(2) end
        finalPath = ":"..name.."/"..input
    end
    if fileExists(finalPath) then
        local f = fileOpen(finalPath)
        local fileSize = fileGetSize(f)
        raw = fileRead(f, fileSize)
        fileClose(f)
    else
        local hdr = input:sub(1,6)
        if hdr == "GIF87a" or hdr == "GIF89a" then
            raw = input
        else
            error(dgsGenAsrt(input,"dgsGIFDecode",1,_,_,_,'input is neither an existing file nor GIF binary data'))
        end
    end
    local pos = 1
    local header = raw:sub(pos, pos+5); pos = pos + 6
    if header ~= "GIF87a" and header ~= "GIF89a" then error("Unsupported GIF header") end
    local width = readLE16(raw, pos); pos = pos + 2
    local height = readLE16(raw, pos); pos = pos + 2
    local packed = strByte(raw, pos); pos = pos + 1
    local gctFlag = mathFloor(packed / 128) % 2 == 1
    local gctSize = 2 ^ ((packed % 8) + 1)
    local bgIndex = strByte(raw, pos); pos = pos + 1
    local pixelAspect = strByte(raw, pos); pos = pos + 1
    local globalPalette = nil
    if gctFlag then
        globalPalette, pos = parseColorTable(raw, pos, gctSize)
    end
    local totalPixels = width * height
    local prevCanvas = {}
    local bgPixel = globalPalette and globalPalette[bgIndex] or "\0\0\0\255"
    for i = 1, totalPixels do
        prevCanvas[i] = bgPixel
    end

    local framesMeta = {}
    local delays = {}
    local gce = {delay = 0, transparent = false, transIndex = 0, disposal = 0}

    local function readSubBlocks()
        local out = {}
        local outLen = 0
        while true do
            local blockSize = strByte(raw, pos); pos = pos + 1
            if blockSize == 0 then break end
            for i = 0, blockSize - 1 do
                outLen = outLen + 1
                out[outLen] = strByte(raw, pos + i)
            end
            pos = pos + blockSize
        end
        return out
    end

    while pos <= #raw do
        local b = strByte(raw, pos); pos = pos + 1
        if not b then break end
        if b == 0x2C then
            local left = readLE16(raw, pos); pos = pos + 2
            local top = readLE16(raw, pos); pos = pos + 2
            local iw = readLE16(raw, pos); pos = pos + 2
            local ih = readLE16(raw, pos); pos = pos + 2
            local ipacked = strByte(raw, pos); pos = pos + 1
            local lctFlag = mathFloor(ipacked / 128) % 2 == 1
            local interlaced = mathFloor(ipacked / 64) % 2 == 1
            local lctSize = powTable[(ipacked % 8) + 1+1]
            local palette = globalPalette
            if lctFlag then palette, pos = parseColorTable(raw, pos, lctSize) end
            local lzwMin = strByte(raw, pos); pos = pos + 1
            local imgData = readSubBlocks()

            if #framesMeta < maxFrames then
                framesMeta[#framesMeta+1] = {
                    left = left,
                    top = top,
                    iw = iw,
                    ih = ih,
                    lctFlag = lctFlag,
                    interlaced = interlaced,
                    lctSize = lctSize,
                    palette = palette,
                    lzwMin = lzwMin,
                    imgData = imgData,
                    gce = { delay = gce.delay, transparent = gce.transparent, transIndex = gce.transIndex, disposal = gce.disposal }
                }
                delays[#delays+1] = gce.delay
            end
            gce = {delay = 0, transparent = false, transIndex = 0, disposal = 0}
        elseif b == 0x21 then
            local label = strByte(raw, pos); pos = pos + 1
            if label == 0xF9 then
                local blockSize,packed,delayL,delayH,transIndex,terminator = strByte(raw, pos, pos + 5)
                local delay = delayL+delayH*256
                pos = pos+6
                gce.delay = delay <= 1 and 1 or delay
                gce.transparent = (packed % 2) == 1
                gce.transIndex = transIndex
                gce.disposal = mathFloor(packed / 4) % 8
            else
                local _ = readSubBlocks()
            end
        else
            break
        end
    end
    return framesMeta, delays, width, height, prevCanvas, globalPalette, bgIndex
end

-- ✅ MODIFIED: ensureDecodedUpTo uses string canvas
local function ensureDecodedUpTo(gif, target)
    if not isElement(gif) then return end
    local data = dgsElementData[gif]
    if not data then return end
    local framesMeta = data.framesMeta or {}
    local textures = data.frames or {}
    local size = data.size or {0,0}
    local width, height = size[1] or 0, size[2] or 0
    if width == 0 or height == 0 then return end
    local prevCanvas = data.prevCanvas or {}
    local globalPalette = data.globalPalette
    local bgIndex = data.bgIndex
    local decodedUpTo = data.decodedUpTo or 0
    target = math.min(target, #framesMeta)
    for i = decodedUpTo + 1, target do
        local meta = framesMeta[i]
        if not meta then break end
        local prevBackup
        if meta.gce and meta.gce.disposal == 3 then
            prevBackup = backupRegion(prevCanvas, meta.left, meta.top, meta.iw, meta.ih, width, height)
        end

        local profiling = dgsElementData[gif] and dgsElementData[gif].profiling
        local frameStart = profiling and getTickCount()
        local t0 = profiling and getTickCount()
        local indices = lzwDecode(meta.lzwMin, meta.imgData, meta.iw * meta.ih)
        local t1 = profiling and getTickCount()
        local t2 = t1
        if meta.interlaced then
            indices = deinterlace(indices, meta.iw, meta.ih)
            if profiling then t2 = getTickCount() end
        end

        -- ✅ Write pixels as BGRA strings
        local idx = 1
        local t_pixels_start = profiling and getTickCount()
        for outY = meta.top, meta.top + meta.ih - 1 do
            if outY >= 0 and outY < height then
                for outX = meta.left, meta.left + meta.iw - 1 do
                    if outX >= 0 and outX < width then
                        local paletteIndex = indices[idx]
                        local pixelPos = outY * width + outX + 1
                        if meta.gce and meta.gce.transparent and paletteIndex == (meta.gce.transIndex or 0) then
                            prevCanvas[pixelPos] = "\0\0\0\0"  -- fully transparent
                        else
                            local pal = meta.palette or globalPalette
                            local colStr = pal and pal[paletteIndex]
                            if colStr then
                                prevCanvas[pixelPos] = colStr
                            else
                                prevCanvas[pixelPos] = "\0\0\0\255"
                            end
                        end
                    end
                    idx = idx + 1
                end
            else
                idx = idx + meta.iw
            end
        end
        local t_pixels_end = profiling and getTickCount()

        local t3 = profiling and getTickCount()
        local dds = buildDDS(width, height, prevCanvas)
        local t_dds_built = profiling and getTickCount()
        local tex = dxCreateTexture(dds)
        local t_texture_created = profiling and getTickCount()
        local t4 = profiling and getTickCount()
        textures[i] = tex
        if isElement(tex) then
            pcall(dgsAttachToAutoDestroy, tex, gif)
        end

        -- apply disposal
        local t_disposal_start = profiling and getTickCount()
        if meta.gce and meta.gce.disposal == 2 then
            local bgPixel = globalPalette and globalPalette[bgIndex] or "\0\0\0\255"
            for y = meta.top, meta.top + meta.ih - 1 do
                for x = meta.left, meta.left + meta.iw - 1 do
                    if y >= 0 and y < height and x >= 0 and x < width then
                        prevCanvas[y * width + x + 1] = bgPixel
                    end
                end
            end
        elseif meta.gce and meta.gce.disposal == 3 then
            if prevBackup then restoreRegion(prevCanvas, prevBackup, width) end
        end
        local t_disposal_end = profiling and getTickCount()

        data.prevCanvas = prevCanvas
        data.frames = textures
        data.decodedUpTo = i

        if profiling then
            local stats = dgsElementData[gif].profileStats or {frames = {}, totals = {lzw=0, deint=0, tex=0, total=0}}
            local LZW = (t1 and t0) and (t1 - t0) or 0
            local DEINT = (t2 and t1) and (t2 - t1) or 0
            local PIXELS = (t_pixels_end and t_pixels_start) and (t_pixels_end - t_pixels_start) or 0
            local DDS_BUILD = (t_dds_built and t3) and (t_dds_built - t3) or 0
            local TEXTURE_CREATE = (t_texture_created and t_dds_built) and (t_texture_created - t_dds_built) or 0
            local DISPOSAL = (t_disposal_end and t_disposal_start) and (t_disposal_end - t_disposal_start) or 0
            local TOTAL = (frameStart and t4) and (t4 - frameStart) or 0
            stats.frames[#stats.frames+1] = {frame = i, lzw = LZW, deint = DEINT, pixels = PIXELS, dds = DDS_BUILD, texCreate = TEXTURE_CREATE, disposal = DISPOSAL, tex = TEXTURE_CREATE, total = TOTAL}
            stats.totals.lzw = (stats.totals.lzw or 0) + LZW
            stats.totals.deint = (stats.totals.deint or 0) + DEINT
            stats.totals.pixels = (stats.totals.pixels or 0) + PIXELS
            stats.totals.dds = (stats.totals.dds or 0) + DDS_BUILD
            stats.totals.texCreate = (stats.totals.texCreate or 0) + TEXTURE_CREATE
            stats.totals.disposal = (stats.totals.disposal or 0) + DISPOSAL
            stats.totals.tex = (stats.totals.tex or 0) + TEXTURE_CREATE
            stats.totals.total = (stats.totals.total or 0) + TOTAL
            dgsSetData(gif, 'profileStats', stats)
            iprint("Frame "..i..": LZW="..LZW.."ms, Deinterlace="..DEINT.."ms, Pixels="..PIXELS.."ms, DDS="..DDS_BUILD.."ms, TextureCreate="..TEXTURE_CREATE.."ms, Disposal="..DISPOSAL.."ms, Total="..TOTAL.."ms")
        end

        if data.decodedUpTo == #framesMeta then
            data.prevCanvas = nil
            data.globalPalette = nil
            data.bgIndex = nil
            collectgarbage()
            print("Decoded, Clear")
        end
    end
end

-- DGS GIF Interface (unchanged logic, but uses new internals)
function dgsCreateGIF(pathOrData)
    if type(pathOrData) ~= "string" then error(dgsGenAsrt(pathOrData,"dgsCreateGIF",1,"string or binary data")) end
    local framesMeta, delays, width, height, initialPrevCanvas, globalPalette, bgIndex = dgsGIFDecode(pathOrData)
    local gif = createElement("dgs-dxgif")
    dgsSetData(gif, "asPlugin", "dgs-dxgif")
    local placeholders = {}
    for i = 1, #framesMeta do placeholders[i] = nil end
    dgsSetData(gif, "frames", placeholders)
    dgsSetData(gif, "profiling", true)
    dgsSetData(gif, "framesMeta", framesMeta)
    dgsSetData(gif, "delays", delays)
    dgsSetData(gif, "size", {width, height})
    dgsSetData(gif, "imageCount", #framesMeta)
    dgsSetData(gif, "decodedUpTo", 0)
    dgsSetData(gif, "prevCanvas", initialPrevCanvas or {})
    dgsSetData(gif, "globalPalette", globalPalette)
    dgsSetData(gif, "bgIndex", bgIndex)
    dgsSetData(gif, "currentFrame", 1)
    dgsSetData(gif, "playing", false)
    dgsSetData(gif, "loop", true)
    dgsTriggerEvent("onDgsPluginCreate",gif,sourceResource)
    return gif
end

-- Helper functions (unchanged)
function dgsGIFGetSize(gif)
    if not dgsGetPluginType(gif) == "dgs-dxgif" then error(dgsGenAsrt(gif,"dgsGIFGetSize",1,"plugin dgs-dxgif")) end
    local s = dgsElementData[gif].size or {0,0}
    return s[1], s[2]
end

function dgsGIFGetImageCount(gif)
    if not dgsGetPluginType(gif) == "dgs-dxgif" then error(dgsGenAsrt(gif,"dgsGIFGetImageCount",1,"plugin dgs-dxgif")) end
    return dgsElementData[gif].imageCount or 0
end

function dgsGIFGetImages(gif)
    if not dgsGetPluginType(gif) == "dgs-dxgif" then error(dgsGenAsrt(gif,"dgsGIFGetImages",1,"plugin dgs-dxgif")) end
    local meta = dgsElementData[gif]
    if meta then
        ensureDecodedUpTo(gif, meta.imageCount or (#(meta.framesMeta or {})))
    end
    return dgsElementData[gif].frames or {}
end

function dgsGIFPlay(gif, speed, frame)
    if not isElement(gif) or dgsGetPluginType(gif) ~= "dgs-dxgif" then error(dgsGenAsrt(gif,"dgsGIFPlay",1,"plugin dgs-dxgif")) end
    local imageCount = dgsElementData[gif].imageCount or 0
    if imageCount == 0 then return false end

    local delays = dgsElementData[gif].delays or {}
    local spd = speed or dgsElementData[gif].speed or 1
    dgsSetData(gif, 'speed', spd)

    local cur = (type(frame)=="number" and mathClamp(frame,1,imageCount)) or dgsElementData[gif].currentFrame or 1
    cur = mathClamp(cur, 1, imageCount)
    dgsSetData(gif, 'currentFrame', cur)

    local sum = 0
    for i=1, cur-1 do
        local ms = (delays[i] or 1) * 10 / spd
        if ms < 10 then ms = 10 end
        sum = sum + ms
    end
    dgsSetData(gif, 'startTick', getTickCount() - sum)
    dgsSetData(gif, 'pausedElapsed', nil)
    dgsSetData(gif, 'playing', true)
    dgsTriggerEvent("onDgsGIFPlay", gif)
    return true
end

function dgsGIFStop(gif)
    if not isElement(gif) or dgsGetPluginType(gif) ~= "dgs-dxgif" then error(dgsGenAsrt(gif,"dgsGIFStop",1,"plugin dgs-dxgif")) end
    if dgsElementData[gif].playing then
        local startTick = dgsElementData[gif].startTick or getTickCount()
        dgsSetData(gif, 'pausedElapsed', getTickCount() - startTick)
    end
    dgsSetData(gif, 'playing', false)
    dgsTriggerEvent("onDgsGIFStop", gif)
    return true
end

function dgsGIFSetSpeed(gif, speed)
    if not isElement(gif) or dgsGetPluginType(gif) ~= "dgs-dxgif" then error(dgsGenAsrt(gif,"dgsGIFSetSpeed",1,"plugin dgs-dxgif")) end
    dgsSetData(gif, 'speed', speed)
    return true
end

function dgsGIFGetSpeed(gif)
    if not isElement(gif) or dgsGetPluginType(gif) ~= "dgs-dxgif" then error(dgsGenAsrt(gif,"dgsGIFGetSpeed",1,"plugin dgs-dxgif")) end
    return dgsElementData[gif].speed
end

function dgsGIFGetPlaying(gif)
    if not isElement(gif) or dgsGetPluginType(gif) ~= "dgs-dxgif" then error(dgsGenAsrt(gif,"dgsGIFGetPlaying",1,"plugin dgs-dxgif")) end
    return dgsElementData[gif].playing
end

function dgsGIFSetLooped(gif, looped)
    if not isElement(gif) or dgsGetPluginType(gif) ~= "dgs-dxgif" then error(dgsGenAsrt(gif,"dgsGIFSetLooped",1,"plugin dgs-dxgif")) end
    dgsSetData(gif, 'loop', looped)
    return true
end

function dgsGIFGetLooped(gif)
    if not isElement(gif) or dgsGetPluginType(gif) ~= "dgs-dxgif" then error(dgsGenAsrt(gif,"dgsGIFGetLooped",1,"plugin dgs-dxgif")) end
    return dgsElementData[gif].loop
end

function dgsGIFSetFrameID(gif, frame)
    if not isElement(gif) or dgsGetPluginType(gif) ~= "dgs-dxgif" then error(dgsGenAsrt(gif,"dgsGIFSetFrameID",1,"plugin dgs-dxgif")) end
    local imageCount = dgsElementData[gif].imageCount or 0
    frame = frame - frame % 1
    frame = mathClamp(frame, 1, imageCount)
    local delays = dgsElementData[gif].delays or {}
    local sum = 0
    local spd = dgsElementData[gif].speed or 1
    for i=1, frame-1 do
        local ms = (delays[i] * 10) / spd
        if ms < 10 then ms = 10 end
        sum = sum + ms
    end
    dgsSetData(gif,'pausedElapsed', sum)
    if dgsElementData[gif].playing then
        dgsSetData(gif,'startTick', getTickCount() - sum)
    end
    dgsSetData(gif,'currentFrame',frame)
    return true
end

function dgsGIFGetFrameID(gif)
    if not isElement(gif) or dgsGetPluginType(gif) ~= "dgs-dxgif" then error(dgsGenAsrt(gif,"dgsGIFGetFrameID",1,"plugin dgs-dxgif")) end
    local cur = 1
    if dgsElementData[gif].playing then
        cur = dgsGIFCalculateCurrentFrameID(gif)
        dgsSetData(gif,'currentFrame',cur)
    else
        cur = dgsElementData[gif].currentFrame or 1
    end
    return cur
end

function dgsGIFCalculateCurrentFrameID(gif)
    local data = dgsElementData[gif]
    if not data then return 1 end
    local imageCount = data.imageCount or (#(data.framesMeta or {}))
    if imageCount == 0 then return 1 end
    local delays = data.delays or {}
    local speed = data.speed or 1
    local loop = data.loop
    local msDelays = {}
    local total = 0
    for i=1,#delays do
        local ms = (delays[i] * 10) / speed
        if ms < 10 then ms = 10 end
        msDelays[i] = ms
        total = total + ms
    end
    if total == 0 then return 1 end
    local elapsed = 0
    if data.playing then
        local startTick = data.startTick or getTickCount()
        elapsed = getTickCount() - startTick
    else
        elapsed = data.pausedElapsed or 0
    end
    if loop then
        elapsed = elapsed % total
    else
        if elapsed >= total then
            return imageCount
        end
    end
    local acc = 0
    for i=1,#msDelays do
        acc = acc + msDelays[i]
        if elapsed < acc then
            return i
        end
    end
    return imageCount
end

-- Custom renderer (unchanged)
dgsCustomTexture["dgs-dxgif"] = function(posX,posY,width,height,u,v,usize,vsize,image,rotation,rotationX,rotationY,color,postGUI,isInRndTgt)
    local data = dgsElementData[image]
    if not data then return end
    local imageCount = data.imageCount or (#(data.framesMeta or {}))
    if imageCount == 0 then return end
    local idx
    if data.playing then
        idx = dgsGIFCalculateCurrentFrameID(image)
        dgsSetData(image,'currentFrame', idx)
    else
        idx = data.currentFrame or 1
    end
    idx = mathClamp(idx, 1, imageCount)
    ensureDecodedUpTo(image, idx)
    local tex = (dgsElementData[image].frames or {})[idx]
    if not isElement(tex) then return end
    return __dxDrawImage(posX,posY,width,height,tex,rotation,rotationX,rotationY,color,postGUI)
end