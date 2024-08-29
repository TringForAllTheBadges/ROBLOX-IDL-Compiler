local IDLCompiler = {}

local types = {
    int8 = {size = 1, read = "ReadInt8", write = "WriteInt8"},
    uint8 = {size = 1, read = "ReadUInt8", write = "WriteUInt8"},
    int16 = {size = 2, read = "ReadInt16", write = "WriteInt16"},
    uint16 = {size = 2, read = "ReadUInt16", write = "WriteUInt16"},
    int32 = {size = 4, read = "ReadInt32", write = "WriteInt32"},
    uint32 = {size = 4, read = "ReadUInt32", write = "WriteUInt32"},
    float32 = {size = 4, read = "ReadFloat32", write = "WriteFloat32"},
    float64 = {size = 8, read = "ReadFloat64", write = "WriteFloat64"},
    string = {size = -1, read = "ReadString", write = "WriteString"},
    bool = {size = 1, read = "ReadBool", write = "WriteBool"},
}

local function parse(idl)
    local structs = {}
    for line in idl:gmatch("[^\r\n]+") do
        local name, fields = line:match("(%w+)%s*{(.+)}")
        if name and fields then
            structs[name] = {}
            for field, typ in fields:gmatch("(%w+):(%w+)") do
                table.insert(structs[name], {name = field, type = typ})
            end
        end
    end
    return structs
end

local function genread(s)
    local r = {"local function read(buffer)"}
    table.insert(r, "    local data = {}")
    for _, f in ipairs(s) do
        local t = types[f.type]
        if t then
            table.insert(r, string.format("    data.%s = buffer:%s()", f.name, t.read))
        end
    end
    table.insert(r, "    return data")
    table.insert(r, "end")
    return table.concat(r, "\n")
end

local function genwrite(s)
    local w = {"local function write(buffer, data)"}
    for _, f in ipairs(s) do
        local t = types[f.type]
        if t then
            table.insert(w, string.format("    buffer:%s(data.%s)", t.write, f.name))
        end
    end
    table.insert(w, "end")
    return table.concat(w, "\n")
end

function IDLCompiler.compile(idl)
    local structs = parse(idl)
    local output = {}
    for name, s in pairs(structs) do
        table.insert(output, string.format("local %s = {}", name))
        table.insert(output, genread(s))
        table.insert(output, genwrite(s))
        table.insert(output, string.format("%s.read = read", name))
        table.insert(output, string.format("%s.write = write", name))
    end
    return table.concat(output, "\n\n")
end

return IDLCompiler
