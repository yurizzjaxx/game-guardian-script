function parseJsonArr(jsonStr)
    -- Remove whitespace and check if it's an array
    jsonStr = jsonStr:gsub('%s+', '')
    local isArray = jsonStr:sub(1,1) == '[' and jsonStr:sub(-1) == ']'
    
    if not isArray then
        return nil, "Expected JSON array"
    end

    local function parseValue(str, startPos)
        local firstChar = str:sub(startPos, startPos)
        
        -- Parse string
        if firstChar == '"' then
            local endPos = str:find('"', startPos+1, true)
            return str:sub(startPos+1, endPos-1), endPos + 1
        
        -- Parse number
        elseif firstChar:match('[%d%-]') then
            local endPos = startPos + 1
            while str:sub(endPos, endPos):match('[%d%.]') do
                endPos = endPos + 1
            end
            return tonumber(str:sub(startPos, endPos-1)), endPos
        
        -- Parse boolean
        elseif str:sub(startPos, startPos+3) == 'true' then
            return true, startPos + 4
        elseif str:sub(startPos, startPos+4) == 'false' then
            return false, startPos + 5
        
        -- Parse null
        elseif str:sub(startPos, startPos+3) == 'null' then
            return nil, startPos + 4
        
        -- Parse object
        elseif firstChar == '{' then
            local obj = {}
            local pos = startPos + 1
            while pos <= #str and str:sub(pos, pos) ~= '}' do
                -- Parse key
                local key, newPos = parseValue(str, pos)
                if not key then break end
                pos = newPos
                
                -- Check for colon
                if str:sub(pos, pos) ~= ':' then break end
                pos = pos + 1
                
                -- Parse value
                local value, newPos = parseValue(str, pos)
                if not value then break end
                pos = newPos
                
                obj[key] = value
                
                -- Skip comma
                if str:sub(pos, pos) == ',' then
                    pos = pos + 1
                end
            end
            return obj, pos + 1
        
        -- Parse array
        elseif firstChar == '[' then
            local arr = {}
            local pos = startPos + 1
            local index = 1
            while pos <= #str and str:sub(pos, pos) ~= ']' do
                -- Parse value
                local value, newPos = parseValue(str, pos)
                if not value then break end
                pos = newPos
                
                arr[index] = value
                index = index + 1
                
                -- Skip comma
                if str:sub(pos, pos) == ',' then
                    pos = pos + 1
                end
            end
            return arr, pos + 1
        else
            return nil
        end
    end

    local result, _ = parseValue(jsonStr, 1)
    return result
end
