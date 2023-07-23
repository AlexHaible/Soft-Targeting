local addonName, addonTable = ...

local AceAddon = LibStub("AceAddon-3.0")
local AceConfig = LibStub("AceConfig-3.0")
local AceEvent = LibStub("AceEvent-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceDB = LibStub("AceDB-3.0")
local SoftTargeting = AceAddon:NewAddon(addonName, "AceConsole-3.0")
local db

function SoftTargeting:OnInitialize()
    self.db = AceDB:New("SoftTargetingDB", {
        profile = {
            enabled = true,
            printOnLogin = false,
            noSpecRange = 45,
            classSpecRanges = {},
        },
    })
    self.db:RegisterDefaults({
        profile = {
            enabled = true,
            printOnLogin = false,
            noSpecRange = 45,
            classSpecRanges = {},
        },
    })
    self.db:SetProfile("global") -- Set the current profile to "global"
    db = self.db.profile

    local options = {
        name = "Soft Targeting",
        type = "group",
        args = {
            enabled = {
                name = "Action targeting enabled",
                desc = "Enable or disable action targeting",
                type = "select",
                values = { ["true"] = "Enabled", ["false"] = "Disabled" },
                get = function() return tostring(db.enabled) end,
                set = function(_, value) db.enabled = (value == "true") end,
                order = 1,
            },
                  
            printOnLogin = {
                name = "Print on login",
                desc = "Enable or disable printing a message on login",
                type = "toggle",
                get = function() return db.printOnLogin end,
                set = function(_, value) db.printOnLogin = value end,
                order = 2,
            },
            noSpecRange = {
                name = "No spec",
                desc = "Set the soft target range for when no spec is selected",
                type = "input",
                get = function() return tostring(db.noSpecRange) end,
                set = function(_, value) db.noSpecRange = tonumber(value) end,
                order = 3,
            },
        },
    }

    self.classSpecConfig = {
        ["Death Knight"] = {
            ["Blood"] = 45,
            ["Frost"] = 45,
            ["Unholy"] = 45,
        },
        ["Demon Hunter"] = {
            ["Havoc"] = 45,
            ["Vengeance"] = 45,
        },
        ["Druid"] = {
            ["Balance"] = 45,
            ["Feral"] = 45,
            ["Guardian"] = 45,
            ["Restoration"] = 45,
        },
        ["Evoker"] = {
            ["Augmentation"] = 30,
            ["Devastation"] = 30,
            ["Preservation"] = 30,
        },
        ["Hunter"] = {
            ["Beast Mastery"] = 45,
            ["Marksmanship"] = 45,
            ["Survival"] = 45,
        },
        ["Mage"] = {
            ["Arcane"] = 45,
            ["Fire"] = 45,
            ["Frost"] = 45,
        },
        ["Monk"] = {
            ["Brewmaster"] = 45,
            ["Mistweaver"] = 45,
            ["Windwalker"] = 45,
        },
        ["Paladin"] = {
            ["Holy"] = 45,
            ["Protection"] = 45,
            ["Retribution"] = 45,
        },
        ["Priest"] = {
            ["Discipline"] = 45,
            ["Holy"] = 45,
            ["Shadow"] = 45,
        },
        ["Rogue"] = {
            ["Assassination"] = 45,
            ["Outlaw"] = 45,
            ["Subtlety"] = 45,
        },
        ["Shaman"] = {
            ["Elemental"] = 45,
            ["Enhancement"] = 45,
            ["Restoration"] = 45,
        },
        ["Warlock"] = {
            ["Affliction"] = 45,
            ["Demonology"] = 45,
            ["Destruction"] = 45,
        },
        ["Warrior"] = {
            ["Arms"] = 45,
            ["Fury"] = 45,
            ["Protection"] = 45,
        },
    }

    for class, specs in pairs(self.classSpecConfig) do
        local classArgs = {}
        for spec, defaultValue in pairs(specs) do
            classArgs[spec] = {
                name = spec,
                desc = "Set the soft target range for " .. spec .. " " .. class,
                type = "input",
                width = "full",
                get = function()
                    db.classSpecRanges[class] = db.classSpecRanges[class] or {}
                    return tostring(db.classSpecRanges[class][spec] or defaultValue)
                end,
                set = function(_, value)
                    db.classSpecRanges[class] = db.classSpecRanges[class] or {}
                    db.classSpecRanges[class][spec] = tonumber(value)
                end,
            }
        end
        options.args[class] = {
            name = class,
            type = "group",
            args = classArgs,
        }
    end    

    AceConfig:RegisterOptionsTable(addonName, options)
    AceConfigDialog:AddToBlizOptions(addonName, "Soft Targeting")
    AceEvent:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED", function() self:ApplyRange() end)
end

function SoftTargeting:OnEnable()
    self:ApplyRange()
end

function SoftTargeting:ApplyRange()
    local playerClass, _ = UnitClass("player")
    local playerSpec = select(2, GetSpecializationInfo(GetSpecialization())) or "No spec"
    local classRanges = db.classSpecRanges[playerClass]
    local range = classRanges and classRanges[playerSpec] or self.classSpecConfig[playerClass][playerSpec] or db.noSpecRange

    if GetCVar("SoftTargetEnemyRange") ~= tostring(range) then
        SetCVar("SoftTargetEnemyRange", tostring(range))
    end

    local classColors = {
        ["Death Knight"] = "C41F3B",
        ["Demon Hunter"] = "A330C9",
        ["Druid"] = "FF7D0A",
        ["Evoker"] = "33937F",
        ["Hunter"] = "ABD473",
        ["Mage"] = "40C7EB",
        ["Monk"] = "00FF96",
        ["Paladin"] = "F58CBA",
        ["Priest"] = "FFFFFF",
        ["Rogue"] = "FFF569",
        ["Shaman"] = "0070DE",
        ["Warlock"] = "8788EE",
        ["Warrior"] = "C79C6E",
    }
    
    if db.printOnLogin then
        local color = classColors[playerClass] or "FFFFFF"  -- Default to white if the class is not in the table
        print(playerSpec .. " |cFF" .. color .. playerClass .. "|r detected, range set to " .. range .. ".")
    end    
end
