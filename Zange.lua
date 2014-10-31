ZangeTransrator = CreateFrame("Frame")
ZangeTransrator:RegisterEvent("VARIABLES_LOADED")

local function debug(...)
    print(...)
end

local function info(...)
    DEFAULT_CHAT_FRAME:AddMessage(...)
end

local function print_help()
    info([[
Zange addon commands:
  /zange off   - off this addon.
  /zange log   - translate confession (only in your log).
  /zange say   - /say Japanese translated confession (do not spam)
  /zange party - /party ^^^
  /zange raid  - /raid ^^^
  /zange guild - /guild ^^^
]])
end

local function print_current_setting()
    info('Zange addon: Current setting is "', ZangeDB["response"], '". (type /zange to help)')
end

-- function ZangeTransrator:VARIABLES_LOADED()
--     if (not ZangeDB) then
--         ZangeDB = {}
--     end
-- end

SLASH_ZANGE1 = "/zangetranslator"
SLASH_ZANGE2 = "/zange"
SlashCmdList["ZANGE"] = function (opt)
    if (not ZangeDB) then
        ZangeDB = { ["response"] = "log" }
    end
    
    if not opt or opt == "" or opt == "help" then
        print_help()
    else
        opt = string.lower(opt)
        if opt == "log" or opt == "on" then
            ZangeDB["response"] = "on"
        elseif opt == "say" or opt == "party" or opt == "raid" or opt == "guild" then
            ZangeDB["response"] = opt
        else
            ZangeDB["response"] = "off"
        end
    end
    
    print_current_setting();
end

local _, class = UnitClass("player")
if class == "PRIEST" then
    info("Zange addon loaded!")
    print_current_setting()

    ChatFrame_AddMessageEventFilter("CHAT_MSG_MONSTER_EMOTE", function(...)
        local self, _, msg, name, _, _, priest = ...
        
        if not ZangeDB.response or ZangeDB.response == "off" then
            return
        end
        
        local myname = UnitName("player")
        if priest ~= myname then
            return
        end
        
        local confess_pattern = "^[[]%%s[]] confesses: ";
        if msg:find(confess_pattern) == nil then
            return
        else
            msg = msg:gsub(confess_pattern, "")
        end
        
        local ja = ZangeTransrator.known_confessions[msg]
        if ja then
            local translated = string.format(ZangeTransrator.template.accepted, name, ja)
            if ZangeDB.response == "on" then
                info(translated)
            elseif ZangeDB.response == "say" or
                   ZangeDB.response == "party" or
                   ZangeDB.response == "raid" or
                   ZangeDB.response == "guild" then
                SendChatMessage(translated, string.upper(ZangeDB.response))
            end
            return true
        else
            info(ZangeTransrator.template.unknown)
        end
    end)
end
