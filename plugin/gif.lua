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
-- Pure-Lua GIF decoder (client-side), lazy-decodes frames on demand.

addEvent("onDgsGIFPlay", true)
addEvent("onDgsGIFStop", true)

local MAX_FRAMES_DEFAULT = math.huge -- no limit

local function readLE16(s, pos)
    local a, b = strByte(s, pos, pos + 1)
    return a + (b or 0) * 256
end

-- LZW Decoder
local function lzwDecode(minCodeSize, data, expectedSize)
    local dataBytes = {}
    for i = 1, #data do
        dataBytes[i] = strByte(data, i)
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
        dict[i] = strChar(i-1)
    end
    local nextCode = nextCodeInit
    local codeSize = codeSizeInit
    local limit = limitInit
    local prev = nil
    local out = {}
    local outLen = 0

    while true do
        local code
        do  --Read bits
            while bitCount < codeSize and dataPos <= dataLen do
                dataPos = dataPos + 1
                bitBuffer = bitBuffer + (dataBytes[dataPos] or 0) * powTable[bitCount + 1]
                bitCount = bitCount + 8
            end
            local mask = powTable[codeSize + 1]
            code = bitBuffer % mask
            bitBuffer = bitBuffer / mask
            bitBuffer = bitBuffer - bitBuffer % 1
            bitCount = bitCount - codeSize
        end
        if code == clearCode then
            -- Reset Dict
            dict = {}
            for i = 1, dictSize do
                dict[i] = strChar(i-1)
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
                    entry = prev .. strSub(prev, 1, 1)
                else
                    break
                end
            end
            local entryLen = #entry
            for i = 1, entryLen do
                outLen = outLen + 1
                out[outLen] = strByte(entry, i)
            end
            if prev then
                nextCode = nextCode + 1
                dict[nextCode] = prev .. strSub(entry, 1, 1)
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
    local rows = {}
    local idx = 1
    local function fill(start, step)
        for y = start, h-1, step do
            rows[y+1] = {}
            for x=1,w do
                rows[y+1][x] = indices[idx]
                idx = idx + 1
            end
        end
    end
    fill(0,8)
    fill(4,8)
    fill(2,4)
    fill(1,2)
    for y=1,h do
        for x=1,w do out[#out+1] = rows[y][x] end
    end
    return out
end

local function parseColorTable(data, pos, count)
    local palette = {}
    for i = 1, count do
        palette[i - 1] = {strByte(data, pos, pos + 2)}
        pos = pos + 3
    end
    return palette, pos
end

-- backup/restore helpers (file scope so ensureDecodedUpTo can use them)
local function backupRegion(c,left,top,iw,ih,w,h)
    local rows = {}
    local x0 = mathMax(0,left)
    local y0 = mathMax(0,top)
    local x1 = mathMin(w-1,left+iw-1)
    local y1 = mathMin(h-1,top+ih-1)
    for y = y0, y1 do
        local rowPieces = {}
        for x = x0, x1 do
            local p = y * w + x + 1
            local v = c[p]
            if v then
                rowPieces[#rowPieces+1] = strChar(v[1] or 0, v[2] or 0, v[3] or 0, v[4] or 0)
            else
                rowPieces[#rowPieces+1] = strChar(0,0,0,0)
            end
        end
        rows[#rows+1] = {y, x0, x1, tableConcat(rowPieces)}
    end
    return rows
end

local function restoreRegion(c, backup, w)
    if not backup then return end
    for i=1, #backup do
        local entry = backup[i]
        local y, x0, x1, data = entry[1], entry[2], entry[3], entry[4]
        local idx = 1
        local YxWidth = y * w + 1
        for x = x0+YxWidth, x1+YxWidth do
            c[x] = {strByte(data, idx, idx+3)}
            idx = idx + 4
        end
    end
end

local function writeLE32(n)
    local a = n % 256
    local b = mathFloor(n / 256) % 256
    local c = mathFloor(n / 65536) % 256
    local d = mathFloor(n / 16777216) % 256
    return strChar(a,b,c,d)
end

function buildDDS(w,h,canvas)
    -- Uncompressed 32-bit DDS (RGBA) using BITFIELDS masks
    local DDSD_CAPS = 0x1
    local DDSD_HEIGHT = 0x2
    local DDSD_WIDTH = 0x4
    local DDSD_PITCH = 0x8
    local DDSD_PIXELFORMAT = 0x1000
    local DDPF_ALPHAPIXELS = 0x1
    local DDPF_RGB = 0x40
    local DDSCAPS_TEXTURE = 0x1000

    local rowStride = w * 4
    local pixelDataSize = rowStride * h
    local LE32D0 = writeLE32(0)
    local parts = {
        "DDS ",
        writeLE32(124), -- dwSize
        writeLE32(DDSD_CAPS + DDSD_HEIGHT + DDSD_WIDTH + DDSD_PIXELFORMAT + DDSD_PITCH), -- dwFlags
        writeLE32(h), -- dwHeight
        writeLE32(w), -- dwWidth
        writeLE32(rowStride), -- dwPitchOrLinearSize
        LE32D0, -- dwDepth
        LE32D0, -- dwMipMapCount
        --11 dwReserved
        LE32D0,LE32D0,LE32D0,LE32D0,LE32D0,LE32D0,
        LE32D0,LE32D0,LE32D0,LE32D0,LE32D0,
        -- DDPIXELFORMAT
        writeLE32(32), -- dwSize
        writeLE32(DDPF_ALPHAPIXELS + DDPF_RGB), -- dwFlags
        LE32D0, -- dwFourCC
        writeLE32(32), -- dwRGBBitCount
        writeLE32(0x00FF0000), -- dwRBitMask
        writeLE32(0x0000FF00), -- dwGBitMask
        writeLE32(0x000000FF), -- dwBBitMask
        writeLE32(0xFF000000), -- dwABitMask
        -- DDSCAPS2
        writeLE32(DDSCAPS_TEXTURE), -- dwCaps1
        LE32D0, -- dwCaps2
        LE32D0, -- dwCapsReserved1
        LE32D0, -- dwCapsReserved2
        LE32D0, -- dwReserved2
    }
    -- pixel data (top-down): append each pixel's BGRA bytes directly into parts
    local base, c
    for y = 0, h-1 do
        base = y * w
        for p = 1+base, w+base do
            c = canvas[p] or {0,0,0,0}
            parts[#parts+1] = strChar(c[3] or 0, c[2] or 0, c[1] or 0, c[4] or 0)
        end
    end
    return tableConcat(parts)
end

-- Decode GIF file and return frames metadata (raw), delays, width, height, initial prevCanvas, palette and bgIndex
function dgsGIFDecode(input, maxFrames)
    maxFrames = maxFrames or MAX_FRAMES_DEFAULT
    if type(input) ~= "string" then error(dgsGenAsrt(input,"dgsGIFDecode",1,"string or binary string")) end
    local raw
    -- First try treating input as a path: resolve resource-relative path and check file existence
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
        -- If not an existing file, treat input as raw GIF binary if it has a valid header
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
    local prevCanvas = {}
    if globalPalette and globalPalette[bgIndex] then
        local c = globalPalette[bgIndex]
        for i=1,width*height do
            prevCanvas[i] = {c[1],c[2],c[3],255}
        end
    else
        for i=1, width*height do
            prevCanvas[i] = {0,0,0,0}
        end
    end
    local framesMeta = {}
    local delays = {}
    local gce = {delay = 0, transparent = false, transIndex = 0, disposal = 0}
    local subBlockBuffer = {}
    local function readSubBlocks()
        local outLength = 0
        while true do
            local blockSize = strByte(raw, pos); pos = pos + 1
            if blockSize == 0 then break end
            outLength = outLength+1
            subBlockBuffer[outLength] = strSub(raw, pos, pos+blockSize-1)
            pos = pos + blockSize
        end
        return tableConcat(subBlockBuffer,nil,nil,outLength)
    end

    while pos <= #raw do
        local b = strByte(raw, pos); pos = pos + 1
        if not b then break end
        if b == 0x2C then -- Image Descriptor
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

            -- Lazy: store compressed image data and frame metadata instead of decoding immediately.
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
            -- reset GCE after consuming it for this image
            gce = {delay = 0, transparent = false, transIndex = 0, disposal = 0}
        elseif b == 0x21 then -- Extension
            local label = strByte(raw, pos); pos = pos + 1
            if label == 0xF9 then -- Graphic Control Extension
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
        else    --b == 0x3B or others
            break
        end
    end
    return framesMeta, delays, width, height, prevCanvas, globalPalette, bgIndex
end

-- Ensure frames up to target are decoded (decompress + create texture), maintaining prevCanvas and disposal behavior
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
        iprint(meta.gce,meta.interlaced)
        if meta.gce and meta.gce.disposal == 3 then
            prevBackup = backupRegion(prevCanvas, meta.left, meta.top, meta.iw, meta.ih, width, height)
        end
        local indices = lzwDecode(meta.lzwMin, meta.imgData, meta.iw * meta.ih)
        if meta.interlaced then indices = deinterlace(indices, meta.iw, meta.ih) end
        local frameCanvas = {}
        for j = 1, width * height do
            local v = prevCanvas[j] or {0,0,0,0}
            frameCanvas[j] = {v[1], v[2], v[3], v[4]}
        end
        local idx = 1
        for outY = meta.top, meta.top + meta.ih - 1 do
            if outY >= 0 and outY < height then
                local outYxWidth = outY * width + 1
                for outX = meta.left, meta.left + meta.iw - 1 do
                    if outX >= 0 and outX < width then
                        local paletteIndex = indices[idx]
                        if not (meta.gce and meta.gce.transparent and paletteIndex == (meta.gce.transIndex or 0)) then
                            local pal = meta.palette or globalPalette
                            local col = pal and pal[paletteIndex]
                            if col then
                                local px = outYxWidth + outX
                                frameCanvas[px][1] = col[1]
                                frameCanvas[px][2] = col[2]
                                frameCanvas[px][3] = col[3]
                                frameCanvas[px][4] = 255
                            end
                        end
                    end
                    idx = idx + 1
                end
            else
                idx = idx + meta.iw
            end
        end
        -- create texture from frameCanvas
        local dds = buildDDS(width, height, frameCanvas)
        local tex = dxCreateTexture(dds)
        if not isElement(tex) then
            tex = dxCreateTexture(width, height)
            local pixels = dxGetTexturePixels(tex)
            for y = 0, height - 1 do
                for x = 0, width - 1 do
                    local p = y * width + x + 1
                    local c = frameCanvas[p] or {0,0,0,0}
                    dxSetPixelColor(pixels, x, y, c[1] or 0, c[2] or 0, c[3] or 0, c[4] or 0)
                end
            end
            dxSetTexturePixels(tex, pixels)
        end
        textures[i] = tex
        if isElement(tex) and dgsAttachToAutoDestroy then
            pcall(dgsAttachToAutoDestroy, tex, gif)
        end
        -- apply disposal
        if meta.gce and meta.gce.disposal == 2 then
            for y = meta.top, meta.top + meta.ih - 1 do
                for x = meta.left, meta.left + meta.iw - 1 do
                    local px = y * width + x + 1
                    if globalPalette and globalPalette[bgIndex] then
                        local c = globalPalette[bgIndex]
                        prevCanvas[px] = {c[1], c[2], c[3], 255}
                    else
                        prevCanvas[px] = {0, 0, 0, 0}
                    end
                end
            end
        elseif meta.gce and meta.gce.disposal == 3 then
            if prevBackup then restoreRegion(prevCanvas, prevBackup, width) end
        else
            prevCanvas = frameCanvas
        end
        data.prevCanvas = prevCanvas
        data.frames = textures
        data.decodedUpTo = i
    end
end

--DGS GIF Interface (lazy)
function dgsCreateGIF(pathOrData)
    if type(pathOrData) ~= "string" then error(dgsGenAsrt(pathOrData,"dgsCreateGIF",1,"string or binary data")) end
    local framesMeta, delays, width, height, initialPrevCanvas, globalPalette, bgIndex = dgsGIFDecode(pathOrData)
    local gif = createElement("dgs-dxgif")
    dgsSetData(gif, "asPlugin", "dgs-dxgif")
    -- placeholders for textures (nil entries); textures will be created lazily
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
    dgsTriggerEvent("onDgsPluginCreate",gif,sourceResource)
    return gif
end

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
    if not isElement(gif) or dgsGetPluginType(gif) ~= "dgsGIFGetLooped" then error(dgsGenAsrt(gif,"dgsGIFGetLooped",1,"plugin dgs-dxgif")) end
    return dgsElementData[gif].loop
end

function dgsGIFSetFrameID(gif, frame)
    if not isElement(gif) or dgsGetPluginType(gif) ~= "dgs-dxgif" then error(dgsGenAsrt(gif,"dgsGIFSetFrameID",1,"plugin dgs-dxgif")) end
    local imageCount = dgsElementData[gif].imageCount or 0
    frame = frame-frame%1
    frame = mathClamp(frame, 1, imageCount)
    local delays = dgsElementData[gif].delays or {}
    local sum = 0
    local spd = dgsElementData[gif].speed or 1
    for i=1, frame-1 do
        local ms = (delays[i] or 1) * 10 / spd
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

-- compute current frame based on elapsed time (ms) since startTick and frame delays
function dgsGIFCalculateCurrentFrameID(gif)
    local data = dgsElementData[gif]
    if not data then return 1 end
    local imageCount = data.imageCount or (#(data.framesMeta or {}))
    if imageCount == 0 then return 1 end
    local delays = data.delays or {}
    local speed = data.speed or 1
    local loop = data.loop
    -- build ms delays and total duration
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

-- Register custom texture renderer for GIF plugin (ensure decode before draw)
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
    -- ensure requested frame is decoded
    ensureDecodedUpTo(image, idx)
    local tex = (dgsElementData[image].frames or {})[idx]
    if not isElement(tex) then return end
    return __dxDrawImage(posX,posY,width,height,tex,rotation,rotationX,rotationY,color,postGUI)
end