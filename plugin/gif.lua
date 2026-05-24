dgsLogLuaMemory()
dgsRegisterPluginType("dgs-dxgif")
local strByte = string.byte
local strSub = string.sub
local strChar = string.char
local strRev = string.reverse
local mathFloor = math.floor
local mathMax = math.max
local mathMin = math.min
local mathClamp = math.clamp
local tableConcat = table.concat
local powTable = {1,2,4,8,16,32,64,128,256,512,1024,2048,4096,8192,16384,32768,65536,131072,262144,524288,1048576,2097152,4194304,8388608,16777216,33554432,67108864,134217728,268435456,536870912,1073741824,2147483648}
local TRANSPARENT_PIXEL = "\0\0\0\0"
local DEFAULT_PIXEL = "\0\0\0\255"

addEvent("onDgsGIFPlay", true)
addEvent("onDgsGIFStop", true)

local MAX_FRAMES_DEFAULT = math.huge

local function readLE16(s, pos)
    local a, b = strByte(s, pos, pos + 1)
    return a + (b or 0) * 256
end

local decodeStack = {}
local stackTop = 0

local yieldEnabled = true  -- toggled per-GIF by processDecodeQueue

local function tryYield()
    if yieldEnabled and coroutine.running() then coroutine.yield() end
end

local function lzwDecode(minCodeSize, data, expectedSize)
    local dataLen = #data
    local dataPos = 1
    local bitBuffer = 0
    local bitCount = 0

    local dictSize = powTable[minCodeSize + 1]
    local clearCode = dictSize
    local endCode = clearCode + 1
    local nextCodeInit = endCode + 1
    local codeSizeInit = minCodeSize + 1
    local limitInit = powTable[codeSizeInit + 1]

    local dictPrefix = {}
    local dictByte = {}
    dictPrefix[dictSize-1] = nil
    dictByte[dictSize-1] = nil
    for i = 0, dictSize-1 do
        dictPrefix[i] = -1
        dictByte[i] = i
    end

    local nextCode = nextCodeInit
    local codeSize = codeSizeInit
    local limit = limitInit
    local prevCode = -1
    local out = {}
    out[8192] = nil
    local outLen = 0
    local iterCount = 0
    while true do
        local code
        do
            while bitCount < codeSize and dataPos <= dataLen do
                local b = data[dataPos] or 0
                bitBuffer = bitBuffer + b * powTable[bitCount + 1]
                dataPos = dataPos + 1
                bitCount = bitCount + 8
            end
            local mask = powTable[codeSize + 1]
            code = bitBuffer % mask
            bitBuffer = (bitBuffer - code) / mask
            bitCount = bitCount - codeSize
        end
        if code == clearCode then
            nextCode = nextCodeInit
            codeSize = codeSizeInit
            limit = limitInit
            prevCode = -1
        elseif code == endCode then
            break
        else
            local firstByte
            stackTop = 0
            local cur = code
            if cur >= nextCode then
                cur = prevCode
                stackTop = stackTop + 1
                decodeStack[stackTop] = firstByte or dictByte[cur]
            end
            while cur >= 0 do
                local b = dictByte[cur]
                stackTop = stackTop + 1
                decodeStack[stackTop] = b
                firstByte = b
                cur = dictPrefix[cur]
            end
            for i = stackTop, 1, -1 do
                outLen = outLen + 1
                out[outLen] = decodeStack[i]
            end
            if prevCode >= 0 then
                dictPrefix[nextCode] = prevCode
                dictByte[nextCode] = firstByte
                nextCode = nextCode + 1
                if nextCode >= limit and codeSize < 12 then
                    codeSize = codeSize + 1
                    limit = limit * 2
                end
            end
            prevCode = code
        end
        iterCount = iterCount + 1
        if iterCount % 4000 == 0 then
            tryYield()
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

local function parseColorTable(data, pos, count)
    local palette = {}
    palette[count] = nil
    for i = 0, count-1 do
        local r,g,b = strByte(data, pos, pos+2)
        palette[i] = strChar(b, g, r, 255)  -- BGRA
        pos = pos + 3
    end
    return palette, pos
end

local function backupRegion(c, left, top, iw, ih, w, h)
    local x0 = left >= 0 and left or 0
    local y0 = top >= 0 and top or 0
    local x1 = mathMin(w-1, left+iw-1)
    local y1 = mathMin(h-1, top+ih-1)
    if x0 > x1 or y0 > y1 then return nil end

    local width = x1 - x0 + 1
    local height = y1 - y0 + 1
    local totalPixels = width * height
    if totalPixels == 0 then return nil end

    local buffer = {y0,x0,width,height}
    local idx = 5

    for y = y0, y1 do
        for x = x0, x1 do
            buffer[idx] = c[y * w + x + 1]  -- BGRA string
            idx = idx + 1
        end
    end

    return buffer  -- {y0, x0, width, height, pixel1, pixel2, ..., pixelN}
end

local function restoreRegion(c, backup, w)
    if not backup then return end
    local y0, x0, width, height = backup[1], backup[2], backup[3], backup[4]
    local idx = 5
    for y = y0, y0 + height - 1 do
        for x = x0, x0 + width - 1 do
            c[y * w + x + 1] = backup[idx]
            idx = idx + 1
        end
    end
end

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

local DDSD_CAPS = 0x1
local DDSD_HEIGHT = 0x2
local DDSD_WIDTH = 0x4
local DDSD_PITCH = 0x8
local DDSD_PIXELFORMAT = 0x1000
local DDPF_ALPHAPIXELS = 0x1
local DDPF_RGB = 0x40
local DDSCAPS_TEXTURE = 0x1000
local LE32D0 = writeLE32(0)
local LE32D32 = writeLE32(32)
local DDSHeadA = tableConcat({
    "DDS ",
    writeLE32(124),
    writeLE32(DDSD_CAPS + DDSD_HEIGHT + DDSD_WIDTH + DDSD_PIXELFORMAT + DDSD_PITCH)
})
local DDSHeadB = tableConcat({
    LE32D0,LE32D0,
    LE32D0,LE32D0,LE32D0,LE32D0,LE32D0,LE32D0,
    LE32D0,LE32D0,LE32D0,LE32D0,LE32D0,
    LE32D32,
    writeLE32(DDPF_ALPHAPIXELS + DDPF_RGB),
    LE32D0,
    LE32D32,
    writeLE32(0x00FF0000),
    writeLE32(0x0000FF00),
    writeLE32(0x000000FF),
    writeLE32(0xFF000000),
    writeLE32(DDSCAPS_TEXTURE), LE32D0, LE32D0, LE32D0, LE32D0,
})

function buildDDS(w, h, canvas)   -- canvas is table of BGRA strings
    return tableConcat({DDSHeadA, writeLE32(h), writeLE32(w), writeLE32(w * 4), DDSHeadB, tableConcat(canvas)})
end

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
    local bgPixel = globalPalette and globalPalette[bgIndex] or DEFAULT_PIXEL
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
            local blockEnd = pos + blockSize - 1
            for i = pos, blockEnd do
                outLen = outLen + 1
                out[outLen] = strByte(raw, i)
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

        local profiling = false
        local frameStart = profiling and getTickCount()
        local t0 = profiling and getTickCount()
        local indices = lzwDecode(meta.lzwMin, meta.imgData, meta.iw * meta.ih)
        local t1 = profiling and getTickCount()
        local t2 = t1
        if meta.interlaced then
            indices = deinterlace(indices, meta.iw, meta.ih)
            if profiling then t2 = getTickCount() end
        end
        local t_pixels_start = profiling and getTickCount()
        local idx = 1
        local top = meta.top
        local left = meta.left
        local bottom = top + meta.ih - 1
        local right = left + meta.iw - 1
        local yStart = top > 0 and top or 0
        local yEnd = bottom < height and bottom or height - 1
        local xStart = left > 0 and left or 0
        local xEnd = right < width and right or width - 1
        if yStart <= yEnd and xStart <= xEnd then
            local skipBefore = (yStart - top) * meta.iw + (xStart - left)
            idx = idx + skipBefore
            local gce = meta.gce
            local isTransparent = gce and gce.transparent
            local transparentIndex = gce and gce.transIndex or 0
            local palette = meta.palette or globalPalette
            if isTransparent then
                for yPos = yStart * width, yEnd * width, width do
                    for outX = xStart+1, xEnd+1 do
                        local paletteIndex = indices[idx]
                        if paletteIndex == transparentIndex then
                            prevCanvas[yPos+outX] = TRANSPARENT_PIXEL
                        else
                            prevCanvas[yPos+outX] = palette[paletteIndex] or DEFAULT_PIXEL
                        end
                        idx = idx + 1
                    end
                end
            else
                for yPos = yStart * width, yEnd * width, width do
                    for outX = xStart+1, xEnd+1 do
                        prevCanvas[yPos+outX] = palette[indices[idx]] or DEFAULT_PIXEL
                        idx = idx + 1
                    end
                end
            end
        end
        local t_pixels_end = profiling and getTickCount()

        local t3 = profiling and getTickCount()
        local dds = buildDDS(width, height, prevCanvas)
        local t_dds_built = profiling and getTickCount()
        local tex = dxCreateTexture(dds,"argb",false)
        local t_texture_created = profiling and getTickCount()
        local t4 = profiling and getTickCount()
        textures[i] = tex
        if isElement(tex) then
            pcall(dgsAttachToAutoDestroy, tex, gif)
        end

        local t_disposal_start = profiling and getTickCount()
        if meta.gce and meta.gce.disposal == 2 then
            if yStart <= yEnd and xStart <= xEnd then
                local bgPixel = globalPalette and globalPalette[bgIndex] or DEFAULT_PIXEL
                local xS = xStart + 1
                local xE = xEnd + 1
                for yPos = yStart * width, yEnd * width, width do
                    for xPos = xS, xE do
                        prevCanvas[yPos+xPos] = bgPixel
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
function dgsCreateGIF(pathOrData, lazyLoad)
    if type(pathOrData) ~= "string" then error(dgsGenAsrt(pathOrData,"dgsCreateGIF",1,"string or binary data")) end
    if lazyLoad == nil then lazyLoad = true end
    local framesMeta, delays, width, height, initialPrevCanvas, globalPalette, bgIndex = dgsGIFDecode(pathOrData)
    local gif = createElement("dgs-dxgif")
    dgsSetData(gif, "asPlugin", "dgs-dxgif")
    local placeholders = {}
    for i = 1, #framesMeta do placeholders[i] = nil end
    dgsSetData(gif, "frames", placeholders)
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
    dgsSetData(gif, "lazyLoad", lazyLoad)
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
        scheduleEnsureDecodedUpTo(gif, meta.imageCount or (#(meta.framesMeta or {})))
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
    scheduleEnsureDecodedUpTo(gif, math.min(5, imageCount))
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
    scheduleEnsureDecodedUpTo(image, math.min(idx + 3, imageCount))
    local frames = data.frames or {}
    local tex = frames[idx]
    if not isElement(tex) then
        local decodedUpTo = data.decodedUpTo or 0
        if decodedUpTo > 0 then
            tex = frames[decodedUpTo]
        end
    end
    if not isElement(tex) then return end
    return __dxDrawImage(posX,posY,width,height,tex,rotation,rotationX,rotationY,color,postGUI)
end

-- Background decode queue — coroutine-based. Each GIF gets a coroutine that yields
-- within decode phases (LZW, pixel rows, DDS, texture), keeping per-tick cost low.
local decodeQueue = {} -- [gif] = {target = N, co = coroutine}
local decodeHandlerAttached = false
local DECODE_BUDGET_MS = 8 -- max ms per render tick for decode work

local function decodeSingleFrame(gif, i)
    if not isElement(gif) then return false end
    local data = dgsElementData[gif]
    if not data then return false end
    local framesMeta = data.framesMeta or {}
    local meta = framesMeta[i]
    if not meta then return false end

    local width, height = (data.size or {0,0})[1] or 0, (data.size or {0,0})[2] or 0
    local prevCanvas = data.prevCanvas or {}
    local globalPalette = data.globalPalette
    local bgIndex = data.bgIndex

    local prevBackup
    if meta.gce and meta.gce.disposal == 3 then
        prevBackup = backupRegion(prevCanvas, meta.left, meta.top, meta.iw, meta.ih, width, height)
    end

    local indices = lzwDecode(meta.lzwMin, meta.imgData, meta.iw * meta.ih)
    tryYield()
    if meta.interlaced then
        indices = deinterlace(indices, meta.iw, meta.ih)
        tryYield()
    end

    -- write pixels to prevCanvas (string-based)
    local idx = 1
    local top = meta.top
    local left = meta.left
    local bottom = top + meta.ih - 1
    local right = left + meta.iw - 1
    local yStart = top > 0 and top or 0
    local yEnd = bottom < height and bottom or height - 1
    local xStart = left > 0 and left or 0
    local xEnd = right < width and right or width - 1
    if yStart <= yEnd and xStart <= xEnd then
        local skipBefore = (yStart - top) * meta.iw + (xStart - left)
        idx = idx + skipBefore
        local gce = meta.gce
        local isTransparent = gce and gce.transparent
        local transparentIndex = gce and gce.transIndex or 0
        local palette = meta.palette or globalPalette
        if isTransparent then
            local rowCount = 0
            for yPos = yStart * width, yEnd * width, width do
                for outX = xStart+1, xEnd+1 do
                    local paletteIndex = indices[idx]
                    if paletteIndex == transparentIndex then
                        prevCanvas[yPos+outX] = TRANSPARENT_PIXEL
                    else
                        prevCanvas[yPos+outX] = palette[paletteIndex] or DEFAULT_PIXEL
                    end
                    idx = idx + 1
                end
                rowCount = rowCount + 1
                if rowCount % 80 == 0 then
                    tryYield()
                end
            end
        else
            local rowCount = 0
            for yPos = yStart * width, yEnd * width, width do
                for outX = xStart+1, xEnd+1 do
                    prevCanvas[yPos+outX] = palette[indices[idx]] or DEFAULT_PIXEL
                    idx = idx + 1
                end
                rowCount = rowCount + 1
                if rowCount % 80 == 0 then
                    tryYield()
                end
            end
        end
    end

    -- build texture
    tryYield()
    local dds = buildDDS(width, height, prevCanvas)
    tryYield()
    local tex = dxCreateTexture(dds)
    tryYield()
    if isElement(tex) then pcall(dgsAttachToAutoDestroy, tex, gif) end

    -- apply disposal
    if meta.gce and meta.gce.disposal == 2 then
        if yStart <= yEnd and xStart <= xEnd then
            local bgPixel = globalPalette and globalPalette[bgIndex] or DEFAULT_PIXEL
            local xS = xStart + 1
            local xE = xEnd + 1
            local rowCount = 0
            for yPos = yStart * width, yEnd * width, width do
                for xPos = xS, xE do
                    prevCanvas[yPos+xPos] = bgPixel
                end
                rowCount = rowCount + 1
                if rowCount % 80 == 0 then
                    tryYield()
                end
            end
        end
    elseif meta.gce and meta.gce.disposal == 3 then
        if prevBackup then restoreRegion(prevCanvas, prevBackup, width) end
    end
    tryYield()

    data.prevCanvas = prevCanvas
    data.frames = data.frames or {}
    data.frames[i] = tex
    data.decodedUpTo = i

    if data.decodedUpTo == #framesMeta then
        data.prevCanvas = nil
        data.globalPalette = nil
        data.bgIndex = nil
        collectgarbage()
    end
    return true
end

local function gifDecodeWorker(gif)
    local data = dgsElementData[gif]
    if data.lazyLoad == false then
        coroutine.yield()  -- eager: yield immediately so scheduleEnsureDecodedUpTo never blocks
    end
    while true do
        local entry = decodeQueue[gif]
        if not entry then return end
        local decodedUpTo = data.decodedUpTo or 0
        if decodedUpTo >= entry.target then
            decodeQueue[gif] = nil
            return
        end
        if not isElement(gif) then
            decodeQueue[gif] = nil
            return
        end
        if not decodeSingleFrame(gif, decodedUpTo + 1) then
            decodeQueue[gif] = nil
            return
        end
        if data.lazyLoad == false then
            coroutine.yield()  -- eager: yield after each complete frame
        end
    end
end

local function processDecodeQueue()
    local start = getTickCount()
    for gif, entry in pairs(decodeQueue) do
        if not isElement(gif) then
            decodeQueue[gif] = nil
        else
            local co = entry.co
            local status = coroutine.status(co)
            if status == "dead" then
                decodeQueue[gif] = nil
            else
                local data = dgsElementData[gif]
                yieldEnabled = (not data) or (data.lazyLoad ~= false)
                coroutine.resume(co)
                yieldEnabled = true
                if coroutine.status(co) == "dead" then
                    decodeQueue[gif] = nil
                end
            end
        end
        if getTickCount() - start >= DECODE_BUDGET_MS then break end
    end
    local empty = true
    for _ in pairs(decodeQueue) do empty = false; break end
    if empty and decodeHandlerAttached then
        removeEventHandler("onClientRender", root, processDecodeQueue)
        decodeHandlerAttached = false
    end
end

function scheduleEnsureDecodedUpTo(gif, target)
    if not isElement(gif) or dgsGetPluginType(gif) ~= "dgs-dxgif" then return end
    local data = dgsElementData[gif]
    if not data then return end
    target = math.min(target, #(data.framesMeta or {}))
    if target <= (data.decodedUpTo or 0) then return end
    local entry = decodeQueue[gif]
    if not entry then
        local co = coroutine.create(gifDecodeWorker)
        decodeQueue[gif] = {target = target, co = co}
        coroutine.resume(co, gif)  -- lazy: ~2ms then yield; eager: immediate yield (0ms)
    else
        entry.target = math.max(entry.target, target)
    end
    if not decodeHandlerAttached then
        addEventHandler("onClientRender", root, processDecodeQueue)
        decodeHandlerAttached = true
    end
end