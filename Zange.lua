ZangeTransrator = CreateFrame("Frame")
ZangeTransrator:RegisterEvent("ADDON_LOADED")

local function debug(...)
    print(...)
end

local function info(msg)
    if not msg then return end
    DEFAULT_CHAT_FRAME:AddMessage(msg, 1, 0.4, 0)
end

local function print_help()
    info([[
Zange addon commands:
  /zange off     - off this addon.
  /zange log    - translate confession (only in your log).
  /zange say   - /say Japanese translated confession (do not spam or confess your spam)
  /zange party - /party and same as above
  /zange raid   - /raid and same as above
  /zange guild - /guild and same as above
]])
end

local function print_current_setting()
    if (not ZangeDB) then return end
    info('Zange addon: Current setting is "' .. ZangeDB["response"] .. '". (/zange to help)')
end

ZangeTransrator:SetScript("OnEvent", function(self, event)
    if event == "ADDON_LOADED" then
        ZangeTransrator:UnregisterEvent("ADDON_LOADED")
        
        if (not ZangeDB) then
            ZangeDB = { ["response"] = "log" }
        end
        
        info("Zange addon: loaded.")
        print_current_setting()
    end
end)

SLASH_ZANGE1 = "/zange"
SLASH_ZANGE2 = "/zange"
SlashCmdList["ZANGE"] = function (opt)
    if (not ZangeDB) then return end
    
    if not opt or opt == "" or opt == "help" then
        print_help()
    else
        opt = string.lower(opt)
        if opt == "log" or opt == "on" then
            ZangeDB["response"] = "log"
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
            local translated
            if name ~= myname then
                translated = string.format(ZangeTransrator.template.accepted, name, ja)
            else
                translated = string.format(ZangeTransrator.template.iconfess, name, ja)
            end
            if not translated then
                return
            end
            
            if ZangeDB.response == "log" then
                info(translated)
            elseif ZangeDB.response == "say" or
                   ZangeDB.response == "party" or
                   ZangeDB.response == "raid" or
                   ZangeDB.response == "guild" then
                SendChatMessage(translated, string.upper(ZangeDB.response))
            end
            return true
        elseif name ~= myname then
            info(ZangeTransrator.template.unknown)
        else
            -- nothing
        end
    end)
end
