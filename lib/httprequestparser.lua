-- original
-- https://github.com/yogiverma007/httprequestparser

local httprequestparser = {
    VERSION = "1.0",
}

local function isEmpty(s)
    return s == nil or s == '' or s == ""
end

local function splitString(toSplitString, delimiter)
    local result = {};
    for match in (toSplitString .. delimiter):gmatch("(.-)" .. delimiter) do
        table.insert(result, match);
    end
    return result;
end

local function trimString(toTrimString)
    local from = toTrimString:match "^%s*()"
    return from > #toTrimString and "" or toTrimString:match(".*%S", from)
end

local function _privatefindElementFromRequestBody(requestBody, element)
    s, e = string.find(requestBody:lower(), element:lower())
    if e == nil then
        return nil
    end
    ls, le = string.find(requestBody:lower(), "\n", e)
    local line = requestBody:sub(s, le)
    s, e = string.find(line, ':')
    if s == nil then
        return nil
    end
    return trimString(line:sub(s + 1, string.len(line)))
end

local function fetchFirstLineFromRequestPayLoad(requestPayload)
    se, e = string.find(requestPayload, "\n")
    if e == nil then
        return nil
    end
    s = requestPayload:sub(1, e)
    return s;
end

--[[    Algorithm
--  split requestBody wrt new line.
--  loop through the table and find empty line.
--  when empty line found then set falg variable to stop the request body data to table.
--  this separate table contains the request body.
--  concatenate the table to string and return the request body string.
]]
local function fetchRequestBody(requestBody)
    local splitRequestBody = splitString(requestBody, "\n")
    local flag = false
    local requestBody = {}

    for k, v in pairs(splitRequestBody) do
        if (flag == true) then
            table.insert(requestBody, v)
        end
        if (v == '\n' or isEmpty(trimString(v))) then
            flag = true
        end
    end
    return requestBody
end

--[[
-- Will return Content-Type header present in request body
-- ]]
function httprequestparser.getContentType(requestBodyBuffer)
    return _privatefindElementFromRequestBody(requestBodyBuffer, "Content%-Type")
end

--[[
-- Will return Accept header present in request body
-- ]]
function httprequestparser.getAccept(requestBodyBuffer)
    return _privatefindElementFromRequestBody(requestBodyBuffer, "Accept")
end

--[[
-- Will return Host header present in request body
-- ]]
function httprequestparser.getHost(requestBodyBuffer)
    return _privatefindElementFromRequestBody(requestBodyBuffer, "Host")
end

--[[
-- Will return All Headers present in request body as table
-- ]]
function httprequestparser.getAllHeaders(requestBodyBuffer)
    local splitRequestBody = splitString(requestBodyBuffer, "\n")
    local requestHeaders = {}
    local i = 0
    for k, v in pairs(splitRequestBody) do
        if i == 0 then
            i = i + 1
        else
            if (v == '\n' or isEmpty(trimString(v))) then
                break
            else
                s, e = string.find(v, ':')
                if s ~= nil then
                    local headerName = v:sub(1, s - 1)
                    local headerValue = v:sub(s + 1, string.len(v))
                    requestHeaders[string.lower(trimString(headerName))] = trimString(headerValue)
                end
            end
        end
    end
    return requestHeaders;
end

--[[
-- Will return http method present in Request body.
-- ]]
-- https://developer.mozilla.org/en-US/docs/Web/HTTP/Messages
function httprequestparser.getHttpMethod(requestBodyBuffer)
    local line = fetchFirstLineFromRequestPayLoad(requestBodyBuffer)
    if line == nil then
        return nil
    end
    s, e = string .find(line, '%s')
    if s == nil then
        return nil
    end
    return trimString(line:sub(1, s));
end

-- https://developer.mozilla.org/en-US/docs/Web/HTTP/Messages
function httprequestparser.getURI(requestBodyBuffer)
    local line = fetchFirstLineFromRequestPayLoad(requestBodyBuffer)
    if line == nil then
        return nil
    end
    s, e = string .find(line, '%s')
    if s == nil then
        return nil
    end
    local uri_and_httpversion = trimString(line:sub(s + 1, string.len(line)));

    s, e = string .find(uri_and_httpversion, '%s')
    if s == nil then
        return nil
    end
    return trimString(uri_and_httpversion:sub(1, s));
end

-- https://developer.mozilla.org/en-US/docs/Web/HTTP/Messages
function httprequestparser.getHttpVersion(requestBodyBuffer)
    local line = fetchFirstLineFromRequestPayLoad(requestBodyBuffer)
    if line == nil then
        return nil
    end
    s, e = string .find(line, '%s')
    if s == nil then
        return nil
    end
    local uri_and_httpversion = trimString(line:sub(s + 1, string.len(line)));

    s, e = string .find(uri_and_httpversion, '%s')
    if s == nil then
        return nil
    end
    return trimString(uri_and_httpversion:sub(s + 1, string.len(uri_and_httpversion)));
end

--[[
-- Will return element present in request body as String
-- ]]
function httprequestparser.findElementFromRequestBody(requestBodyBuffer, element)
    return _privatefindElementFromRequestBody(requestBodyBuffer, element)
end

--[[
-- Will return request body as String
-- ]]
function httprequestparser.getRequestBodyAsString(requestBodyBuffer)
    return table.concat(fetchRequestBody(requestBodyBuffer), "\n")
end

return httprequestparser
