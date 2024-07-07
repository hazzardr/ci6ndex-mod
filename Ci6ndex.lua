print("loaded Ci6ndex.lua")

include( "SupportFunctions" );
include( "InstanceManager" );
-- include( "LuaClass" );

local GameEvents                            = ExposedMembers.GameEvents

local g_PlotStackInst			    :table  = InstanceManager:new( "PlotHistoryStackInstance",	"PlotStack", Controls.PlotStackUp );
local m_LegendFillInst 	            :table  = InstanceManager:new( "LegendFill",	"GoToCiv", Controls.Legende );
local m_kSearchResultIM		        :table  = InstanceManager:new( "SearchResultInstance",   "Root",     Controls.SearchResultsStack);
local m_WarInfoInst		            :table  = InstanceManager:new( "WarInfo",   "MoreWarInfo",     Controls.WarInfoStack);
local m_WarAllyUnitInfoInst		    :table  = InstanceManager:new( "WarUnitInfo",   "Anchor",     Controls.AllyUnit);
local m_WarEnemyUnitInfoInst		:table  = InstanceManager:new( "WarUnitInfo",   "Anchor",     Controls.EnemyUnit);
local m_WarAllyExpanded             :table  = InstanceManager:new( "WarAlly",   "CivIndicator",     Controls.WarAllyStack);
local m_WarEnemyExpanded            :table  = InstanceManager:new( "WarAlly",   "CivIndicator",     Controls.WarEnemyStack); 

local TypeGovernment                        = "Government"
local TypeScience                           = "Science"
local TypeCulture                           = "Culture"

local WhiteColor                   :number  = UI.GetColorValueFromHexLiteral(0xFFFFFFFF)
local RedColor                     :number  = UI.GetColorValueFromHexLiteral(0xFF0000FF)
local greenColor                   :number  = UI.GetColorValueFromHexLiteral(0xFF00FF00)
local COLOR_RED					   :number  = UI.GetColorValueFromHexLiteral(0xFF0101F5);
local COLOR_YELLOW				   :number  = UI.GetColorValueFromHexLiteral(0xFF2DFFF8);
local COLOR_GREEN				   :number  = UI.GetColorValueFromHexLiteral(0xFF4CE710);
local defaultColor                 :number  = UI.GetColorValueFromHexLiteral(0xFF555555)
local invisibleColor               :number  = UI.GetColorValueFromHexLiteral(0x00000000)

local maptype                               = Map.GetMapSize();
local mapx                                  = GameInfo.Maps[maptype].GridWidth 
local mapy                                  = GameInfo.Maps[maptype].GridHeight

local m_edgePanX                            = 0
local m_edgePanY                            = 0

local HistoryData                   :table  = {PlotData = {}, PlayerData = {}, GameData = {}};
local PlotInfo                      :table  = {};
local PlotInfoInstances             :table  = {};
local PlotInformation               :table  = {};
local AllPlotsLastTurnInfo          :table  = {};
local PlotReligion                  :table  = {};
local PlotGovernMent                :table  = {};

local CitiesOwners                  :table  = {};
local TurnPlotOwner                 :table  = {};
local ResearchBank                  :table  = {};
local DisplayedPlayer               :table  = {};
local WarDisplayed                  :table  = {};
local WarExpanded                   :table  = {};

local isShiftDown                           = false
local m_isUPpressed                         = false
local m_isRIGHTpressed                      = false
local m_isDOWNpressed                       = false
local m_isLEFTpressed                       = false

local PlayingTime                           = false;
local PlayingReverseTime                    = false;
local RealPopulation                        = true;

local ReligionFilter                        = false;
local GovernmentFilter                      = false;

local bHideNextTime                         = false;

local SpeedX                                = 0
local SpeedY                                = 0
local xOffset                               = 0
local yOffset                               = 0

local CenterPlotX;
local CenterPlotY;
local firstTurn;
local CurrentDisplayedTurn                  = 0
local PreviousDisplayedTurn                 = -1
local playSpeed                             = 8
local CountTimeTick                         = 0

local defaultCenterPlot                     = 1
local NextPlotToCreate                      = 1001
local NextPlot                              = 1001
local SetTurn                               = 0

local SetOrder                              = "defaultOrder"


local DisplayOrder = { 
    {["TypeName"]="plotWasCity",           ["IconName"]="ICON_CIVILOPEDIA_BUILDINGS",          ["IconToolTip"]="Hide City",                    ["IconColor"]=WhiteColor,   ["ShouldHide"]=false }, 
    {["TypeName"]="plotWasBarbarianCamp",  ["IconName"]="ICON_IMPROVEMENT_CAMP",               ["IconToolTip"]="Hide Barbarians Villages",     ["IconColor"]=RedColor,   ["ShouldHide"]=false }, 
    {["TypeName"]="plotUnitIcon",          ["IconName"]="ICON_Unit_Warrior",                   ["IconToolTip"]="Hide Units",                   ["IconColor"]=UI.GetColorValueFromHexLiteral(0xFF0064FF),   ["ShouldHide"]=false }, 
    {["TypeName"]="plotWonderIcon",        ["IconName"]="ICON_NOTIFICATION_WONDER_COMPLETED",  ["IconToolTip"]="Hide Wonders",                 ["IconColor"]=UI.GetColorValueFromHexLiteral(0xFF00DCFF),   ["ShouldHide"]=false }, 
    {["TypeName"]="plotDistrictIcon",      ["IconName"]="ICON_DISTRICT_CITY_CENTER",           ["IconToolTip"]="Hide Districts",               ["IconColor"]=WhiteColor,   ["ShouldHide"]=false }, 
    {["TypeName"]="plotRessourceIcon",     ["IconName"]="ICON_RESOURCE_WHEAT",                 ["IconToolTip"]="Hide Ressources",              ["IconColor"]=WhiteColor,   ["ShouldHide"]=false }
};
local AllPlotInfoKeys   = { 
    "PlotTerrain", 
    "Owner", 
    "OwnerColor", 
    "plotWasCity", 
    "CityIconToolTip", 
    "plotWasBarbarianCamp", 
    "PlotIconHide", 
    "plotUnitIcon", 
    "UnitIconOwnerColor", 
    "UnitIconToolTip", 
    "UnitHealthPercent", 
    "plotWonderIcon", 
    "WonderIconToolTip", 
    "plotDistrictIcon", 
    "plotDistrictIconToolTip", 
    "plotRessourceIcon", 
    "plotRessourceIconToolTip", 
    "plotRessourcePrereqTech", 
    "ReligionColor", 
    "GovernMentColor"}

local playerDataKeys = { 
    
    "TotalPlayerCityTurn",
    "PlayerRealPop",
    "PlayerGamePopulation",
    "TotalPlayerNonMilUnitTurn",
    "TotalPlayerUnitTurn",
    "TotalPlayerPowerTurn",
    "GameMilitaryStrength",
    "TotalPlayerHPTurn",
    "TechDiscovered",
    "SciencePerTurn",
    "CivicDiscovered",
    "CulturePerTurn",
    "GoldBalance",
    "GoldPerTurn",
    "GoldGainPerTurn",
    "GoldLossPerTurn",
    "Tourism",
    "ToolTip"
}
local HistoryTypes = {
    TotalPlayerCityTurn = {Datatype = "number", DefaultValue = 0},
    PlayerRealPop = {Datatype = "number", DefaultValue = 0},
    PlayerGamePopulation = {Datatype = "number", DefaultValue = 0},
    TotalPlayerNonMilUnitTurn = {Datatype = "number", DefaultValue = 0},
    TotalPlayerUnitTurn = {Datatype = "number", DefaultValue = 0},
    TotalPlayerPowerTurn = {Datatype = "number", DefaultValue = 0},
    GameMilitaryStrength = {Datatype = "number", DefaultValue = 0},
    TotalPlayerHPTurn = {Datatype = "number", DefaultValue = 0},
    TechDiscovered = {Datatype = "number", DefaultValue = 0},
    SciencePerTurn = {Datatype = "number", DefaultValue = 0},
    CivicDiscovered = {Datatype = "number", DefaultValue = 0},
    CulturePerTurn = {Datatype = "number", DefaultValue = 0},
    GoldBalance = {Datatype = "number", DefaultValue = 0},
    GoldPerTurn = {Datatype = "number", DefaultValue = 0},
    GoldGainPerTurn = {Datatype = "number", DefaultValue = 0},
    GoldLossPerTurn = {Datatype = "number", DefaultValue = 0},
    Tourism = {Datatype = "number", DefaultValue = 0},
    ToolTip = {Datatype = "string", DefaultValue = ""},
    
    PlotTerrain = {Datatype = "string", DefaultValue = "TERRAIN_PLAINS"},
    Owner = {Datatype = "number", DefaultValue = nil},
    OwnerColor = {Datatype = "number", DefaultValue = invisibleColor},
    plotWasCity = {Datatype = "boolean", DefaultValue = false},
    CityIconToolTip = {Datatype = "string", DefaultValue = ""},
    plotWasBarbarianCamp = {Datatype = "boolean", DefaultValue = false},
    PlotIconHide = {Datatype = "boolean", DefaultValue = false},
    plotUnitIcon = {Datatype = "string", DefaultValue = nil},
    UnitIconOwnerColor = {Datatype = "number", DefaultValue = invisibleColor},
    UnitIconToolTip = {Datatype = "string", DefaultValue = ""},
    UnitHealthPercent = {Datatype = "number", DefaultValue = 0},
    plotWonderIcon = {Datatype = "string", DefaultValue = nil},
    WonderIconToolTip = {Datatype = "string", DefaultValue = ""},
    plotDistrictIcon = {Datatype = "string", DefaultValue = nil},
    plotDistrictIconToolTip = {Datatype = "string", DefaultValue = ""},
    plotRessourceIcon = {Datatype = "string", DefaultValue = nil},
    plotRessourceIconToolTip = {Datatype = "string", DefaultValue = ""},
    plotRessourcePrereqTech = {Datatype = "number", DefaultValue = nil},
    ReligionColor = {Datatype = "number", DefaultValue = -1},
    GovernMentColor = {Datatype = "number", DefaultValue = 1}
}
local Order_Table = {
    
    {"Default Order","defaultOrder"},
    {"Number of cities","TotalPlayerCityTurn"},
    {"Real population","PlayerRealPop"},
    {"Game population","PlayerGamePopulation"},
    {"Number of units","TotalPlayerNonMilUnitTurn"},
    {"Number of military unit","TotalPlayerUnitTurn"},
    {"Military Strength","TotalPlayerPowerTurn"},
    {"Game Military Strength","GameMilitaryStrength"},
    {"Tech Discovered","TechDiscovered"},
    {"Science Per Turn","SciencePerTurn"},
    {"Civic Discovered","CivicDiscovered"},
    {"Culture Per Turn","CulturePerTurn"},
    {"Gold balance","GoldBalance"},
    {"Gold Per Turn","GoldPerTurn"},
    {"Gold gain Per Turn","GoldGainPerTurn"},
    {"Gold Loss Per Turn","GoldLossPerTurn"},
    {"Tourism","Tourism"}
};

local Options = { 
    ["SetStrategicViewOnOpen"]      = GameConfiguration.GetValue("SetStrategicViewOnOpen") == false and GameConfiguration.GetValue("SetStrategicViewOnOpen") or true, 
    ["SetStrategicViewOnClose"]     = GameConfiguration.GetValue("SetStrategicViewOnClose") and GameConfiguration.GetValue("SetStrategicViewOnClose")       or false, 
    ["EndTurnSound"]                = GameConfiguration.GetValue("EndTurnSound") and GameConfiguration.GetValue("EndTurnSound")                             or false, 
    ["HideHistoryViewButton"]       = GameConfiguration.GetValue("HideHistoryViewButton") and GameConfiguration.GetValue("HideHistoryViewButton")           or false, 
    ["HistoryViewCameraSpeed"]      =  GameConfiguration.GetValue("HistoryViewCameraSpeed") and GameConfiguration.GetValue("HistoryViewCameraSpeed")        or 50, 
    
    ["ShowUnitLastTurn"]            = GameConfiguration.GetValue("ShowUnitLastTurn") and GameConfiguration.GetValue("ShowUnitLastTurn")                     or false,
    ["RevealHistoryViewMap"]        = GameConfiguration.GetValue("RevealHistoryViewMap") and GameConfiguration.GetValue("RevealHistoryViewMap")             or false,
    ["ShowUndiscoveredResource"]    = GameConfiguration.GetValue("ShowUndiscoveredResource") and GameConfiguration.GetValue("ShowUndiscoveredResource")     or false
}
local ModifiedOptions = {}


if not GameConfiguration.GetValue("checkIfRazed") then
        GameConfiguration.SetValue("checkIfRazed", 0 )
end

function spairs(t, order)
    -- collect the keys
    local keys = {}
    for k in pairs(t) do keys[#keys+1] = k end

    -- if order function given, sort by it by passing the table and keys a, b,
    -- otherwise just sort the keys 
    if order then
        table.sort(keys, function(a,b) return order(t, a, b) end)
    else
        table.sort(keys)
    end

    -- return the iterator function
    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end

function SetHistoryView()
    CurrentDisplayedTurn    = -1
    DisplayTurn(firstTurn, true)
    Controls.HistoryView:SetHide( false );
    
    local pPlot, MoveCameraOnX1 = GetBestPlotForMap()
    
    local plotToCenter= Map.GetPlot(15, 15);
    if Players[Game.GetLocalPlayer()] and Players[Game.GetLocalPlayer()]:GetCities():GetCapitalCity() then
        local localPlayerCapital     = Players[Game.GetLocalPlayer()]:GetCities():GetCapitalCity()
        plotToCenter = Map.GetPlot(localPlayerCapital:GetX(), localPlayerCapital:GetY())
    elseif Players[Game.GetLocalPlayer()] and Players[Game.GetLocalPlayer()]:GetUnits():Members() then
        for _, pUnit in Players[Game.GetLocalPlayer()]:GetUnits():Members() do
            if pUnit:GetX() >= 0 and pUnit:GetY() >= 0 then
                plotToCenter = Map.GetPlot(pUnit:GetX(), pUnit:GetY())
                if plotToCenter then 
                    break;
                end
            end
        end
    end
    if not pPlot then
        pPlot = plotToCenter
    end
    if MoveCameraOnX1 then
        UI.LookAtPlot(0, pPlot:GetY()); 
    else
        UI.LookAtPlot(pPlot); 
    end
    local worldX, worldY = UI.GridToWorld( pPlot:GetIndex() );
    Controls.PlotAnchor:SetWorldPositionVal( worldX, worldY, 0 );
    
    SetCenterPlot(plotToCenter:GetX(), plotToCenter:GetY())
    
end
function GetBestPlotForMap()
    local pLocalPlayerVis:table   = PlayersVisibility[Game.GetLocalPlayer()];
    if not pLocalPlayerVis then
        return Map.GetPlot(30,20);
    end
    for locX = mapx -1, 0, -1 do
        for locY = mapy -1, 0, -1 do
            if pLocalPlayerVis:IsRevealed(locX, locY) and Map.GetPlot(locX, locY):GetX() == locX then    
                if locX >= 15 then
                    return Map.GetPlot(locX, locY), false;
                elseif locX >= 12 then
                    locX = 15
                    return Map.GetPlot(locX, locY), false;
                elseif locX <= 4 then
                    locX = mapx -1
                    return Map.GetPlot(locX, locY), true;
                end
            end
        end
    end
end

function PlotInfo:New(pPlot, plotInstance)
    local self :table = {};
	for key, func in pairs(PlotInfo) do
        self[key] = func;
    end
--    self                                    = LuaClass.new(PlotInfo);
    self.PlotIndex                          = pPlot:GetIndex();
    self.m_InstanceManager                  = m_PlotHistoryInst;
    self.m_Instance                         = plotInstance;
    HistoryData.PlotData[self.PlotIndex]    = GetPlotData(self.PlotIndex);
    self.Data                               = HistoryData.PlotData[self.PlotIndex];
    
    PlotInfoInstances[self.PlotIndex]       = self;
    
    --self.m_Instance.OwnerColorButton:RegisterCallback( Mouse.eLClick, function() end );
    self.m_Instance.HealthBar:SetPercent(1);
    self.m_Instance.HealthBarContainer:SetHide(true)
    Controls.TurnDisplayedLabel:SetText("Turn "..CurrentDisplayedTurn)
end

function PlotInfo:SetPlotColorsIcon(ShowTurn, bForceUpdate, changedLensThisTurn)
    if not self.IsVisible then
        return;
    end
    local PlotIndex         =  self.PlotIndex;
    
    local Turn              =  GetLastTurnChange(PlotIndex, ShowTurn)
    local PreviousTurn      =  GetLastTurnChange(PlotIndex, PreviousDisplayedTurn)
    local ChangeOwnerColor  =  false
    if Turn == PreviousTurn and PreviousDisplayedTurn ~= -1 and not bForceUpdate then
        if changedLensThisTurn then
            ChangeOwnerColor = true
        else
            return;
        end
    end
    local TurnData = self.Data[Turn]
    if TurnData["OwnerColor"] then
        local instance = self.m_Instance;
        if TurnData["Owner"] then
            TurnPlotOwner[PlotIndex] = TurnData["Owner"]
            if ReligionFilter then
                local religionType = TurnData["ReligionColor"]
                local  ReligionColor = defaultColor
                if type(religionType) == "number" and religionType ~= -1 then
		            local religionData = GameInfo.Religions[religionType];
		            if religionData and religionData.Pantheon == false then
			            ReligionColor = UI.GetColorValue(religionData.Color);
		            end  
                end
                instance.OwnerColorButton:SetColor(ReligionColor)
            elseif GovernmentFilter then  
                local GovernMentType = TurnData["GovernMentColor"]
                local  GovernMentColor = defaultColor
                if GovernMentType then
		            local GovernMentData = GameInfo.Governments[GovernMentType];
		            if GovernMentData and GovernMentData.GovernmentType then
			            GovernMentColor = UI.GetColorValue("COLOR_" .. GovernMentData.GovernmentType)
		            end  
                end
                instance.OwnerColorButton:SetColor(GovernMentColor)
            else
                if type(TurnData["OwnerColor"]) == "number" then
                    instance.OwnerColorButton:SetColor(TurnData["OwnerColor"]);
                else
                    instance.OwnerColorButton:SetColor(defaultColor);
                end
            end

            instance.PlotImage:SetSizeVal(180 , 180 )
            instance.ResourceIcon:SetSizeVal(75,75)
        else     
            instance.PlotImage:SetSizeVal(280, 280)
            instance.ResourceIcon:SetSizeVal(100, 100)

            instance.OwnerColorButton:SetColor(defaultColor);
        end
        if not ChangeOwnerColor then
            local terrainIcon = TurnData["PlotTerrain"];
            if type(terrainIcon) ~= "string" then
                terrainIcon = "ICON_TERRAIN_PLAINS"
                local pPlot = Map.GetPlotByIndex(PlotIndex)
                if pPlot:IsNaturalWonder() then
                    terrainIcon = "ICON_"..GameInfo.Features[pPlot:GetFeatureType()].FeatureType;
                elseif(terrain) then
                    local terrainType = terrain.TerrainType;
                    terrainIcon =  "ICON_" .. terrainType;
                end
            end
            instance.PlotImage:SetIcon(terrainIcon)
            instance.plotUnitIcon:SetHide(true)
            instance.ResourceIcon:SetHide(true)
            instance.OrangeBack:SetHide(true)
            instance.HealthBarContainer:SetHide(true)
            for _, ToDisplay in ipairs(DisplayOrder) do
                local Icon = TurnData[ToDisplay.TypeName]
                if Icon and not ToDisplay.ShouldHide then
                    if ToDisplay.TypeName == "plotUnitIcon" and ( Options["ShowUnitLastTurn"] or not TurnData["PlotIconHide"] or Turn < Game.GetCurrentGameTurn() -5 ) and TurnData["UnitIconToolTip"] and type(Icon) == "string" and string.find(Icon, "ICON") then
                    
                        instance.plotUnitIcon:SetIcon(Icon);
                        instance.OrangeBack:SetIcon(Icon);
                        instance.plotUnitIcon:SetColor(TurnData["UnitIconOwnerColor"])
                        if type(TurnData["UnitIconToolTip"]) == "string" then
                            instance.plotUnitIcon:SetToolTipString(TurnData["UnitIconToolTip"])
                        else 
                            instance.plotUnitIcon:SetToolTipString("Error: string expected got "..type(TurnData["UnitIconToolTip"]))
                        end
                    
                        local healthPercent = 0;
                        if type(TurnData["UnitHealthPercent"]) == "number" then
                            healthPercent = TurnData["UnitHealthPercent"]/100
                        end
                        if healthPercent ~= 0 and healthPercent ~= 1 then
                            
                            if ( healthPercent >= 0.8 ) then
			                   instance.HealthBar:SetColor( COLOR_GREEN );
		                    elseif( healthPercent > 0.4 and healthPercent < .8) then
			                   instance.HealthBar:SetColor( COLOR_YELLOW );
		                    else
			                   instance.HealthBar:SetColor( COLOR_RED );
		                    end
                            
                            instance.HealthBarBacking:SetHide( false );
                            instance.HealthBar:SetPercent( healthPercent );
                            instance.HealthBarContainer:SetHide(false)
                        end
                    
                        instance.plotUnitIcon:SetHide(false)
                        instance.OrangeBack:SetHide(false)
                        break;
                    elseif ToDisplay.TypeName == "plotWasCity" then
                        local ToolTip = TurnData["CityIconToolTip"]
                        if type(Icon) == "boolean" and ToolTip then
                            instance.plotUnitIcon:SetIcon("ICON_CIVILOPEDIA_BUILDINGS");
                            instance.plotUnitIcon:SetToolTipString(ToolTip);
                            instance.plotUnitIcon:SetColor(WhiteColor)
                            instance.plotUnitIcon:SetHide(false)
                            break;
                        end
                    elseif ToDisplay.TypeName == "plotWasBarbarianCamp" then
                        if type(Icon) == "boolean" then
                            instance.plotUnitIcon:SetIcon("ICON_IMPROVEMENT_CAMP");
                            instance.plotUnitIcon:SetToolTipString("BarBarian Village")
                            instance.plotUnitIcon:SetColor(RedColor)
                            instance.plotUnitIcon:SetHide(false)
                            break;
                        end
                    elseif ToDisplay.TypeName == "plotWonderIcon" then
                        local ToolTip = TurnData["WonderIconToolTip"]
                        if type(Icon) == "string" and string.find(Icon, "ICON") and ToolTip then
                            instance.plotUnitIcon:SetIcon(Icon);
                            instance.plotUnitIcon:SetToolTipString(ToolTip);
                            instance.plotUnitIcon:SetColor(WhiteColor)
                            instance.plotUnitIcon:SetHide(false)
                            break;
                        end
                    elseif ToDisplay.TypeName == "plotDistrictIcon" then
                        local ToolTip = TurnData["plotDistrictIconToolTip"]
                        if type(Icon) == "string" and string.find(Icon, "ICON") and ToolTip then
                            instance.plotUnitIcon:SetIcon(Icon);
                            instance.plotUnitIcon:SetToolTipString(ToolTip);
                            instance.plotUnitIcon:SetColor(WhiteColor)
                            instance.plotUnitIcon:SetHide(false)
                            break;
                        end
                    elseif ToDisplay.TypeName == "plotRessourceIcon" then
                        local techIndex = TurnData["plotRessourcePrereqTech"]
                        if Options["ShowUndiscoveredResource"] or not techIndex or not Players[Game.GetLocalPlayer()] or Players[Game.GetLocalPlayer()]:GetTechs():HasTech(techIndex) then  
                            local ToolTip = TurnData["plotRessourceIconToolTip"]
                            if type(Icon) == "string" and string.find(Icon, "ICON") and ToolTip then
                                instance.ResourceIcon:SetIcon(Icon);
                                instance.ResourceIcon:SetToolTipString(ToolTip);
                                instance.ResourceIcon:SetHide(false)
                                break;
                            end
                        end
                    end
                end
            end
        end  
    end
end

function SetTurnInformations(Turn)
    local lastEventTurn     = Turn
    local InformationNotSet = true
    local TypeGovernmentSet = false
    local TypeScienceSet    = false
    local TypeCultureSet    = false
    while InformationNotSet and lastEventTurn >= 1 do
        if not TypeGovernmentSet and GameConfiguration.GetValue("Label1."..lastEventTurn.."."..TypeGovernment) then
            for i = 1, 10 do
                Controls["GovernmentLabel"..i]:SetText(GameConfiguration.GetValue("Label"..i.."."..lastEventTurn.."."..TypeGovernment))
            end
            TypeGovernmentSet = true
        end
        if not TypeScienceSet and GameConfiguration.GetValue("Label1."..lastEventTurn.."."..TypeScience) then
            for i = 1, 10 do
                Controls["ScienceLabel"..i]:SetText(GameConfiguration.GetValue("Label"..i.."."..lastEventTurn.."."..TypeScience))
            end
            TypeScienceSet = true
        end
        if not TypeCultureSet and GameConfiguration.GetValue("Label1."..lastEventTurn.."."..TypeCulture) then
            for i = 1, 10 do
                Controls["CultureLabel"..i]:SetText(GameConfiguration.GetValue("Label"..i.."."..lastEventTurn.."."..TypeCulture))
            end
            TypeCultureSet = true
        end
        
        if TypeGovernmentSet and TypeScienceSet and TypeCultureSet then
            InformationNotSet = false
        end
        lastEventTurn = lastEventTurn -1
    end
    if not TypeGovernmentSet then
        for i = 1, 10 do
            Controls["GovernmentLabel"..i]:SetText("")
        end
    end
    if not TypeScienceSet then
        for i = 1, 10 do
            Controls["ScienceLabel"..i]:SetText("")
        end
    end
    if not TypeCultureSet then
        for i = 1, 10 do
            Controls["CultureLabel"..i]:SetText("")
        end
    end
    if RealPopulation then
        local TotalRealPopulation = HistoryData.GameData[Turn].RealPopulation 
        if not TotalRealPopulation then
            TotalRealPopulation = 0
        end
        if TotalRealPopulation > 0 then
            local TotalRealPopulationString = "000"
            while TotalRealPopulation >= 1000 do
                TotalRealPopulationString  = string.sub(tostring(TotalRealPopulation), -3 )..","..TotalRealPopulationString
                TotalRealPopulation = math.floor(TotalRealPopulation/1000)   
            end
            TotalRealPopulation = TotalRealPopulation..","..TotalRealPopulationString
        end
        Controls.Population:SetText(TotalRealPopulation)
    else
        Controls.Population:SetText(HistoryData.GameData[Turn].GamePopulation)
    end
    local strDate = Calendar.MakeYearStr(Turn);
	Controls.TurnDate:SetText(strDate);
    local IsPlayerDisplayed = {}
    DisplayedPlayer         = {}
    for plotID, playerID in pairs(TurnPlotOwner) do
        if not IsPlayerDisplayed[playerID] then
            IsPlayerDisplayed[playerID] = true
            if Players[playerID] then
                table.insert(DisplayedPlayer , playerID)
            end
        end
    end
    table.sort(DisplayedPlayer)
    if Controls.ShowKeyPanel:IsHidden() then
        SetLegend(Turn)
    end
    SetWarTurnInformation(Turn)
end
function SetLegend(Turn)
    Controls.KeyPanel:SetSizeX(350)
    Controls.KeyPanel:SetHide(true)
    m_LegendFillInst:ResetInstances()
    if ReligionFilter then
        Controls.OrderChoosePullDownStack:SetHide(true)
        local pAllReligions			:table = Game.GetReligion():GetReligions();
        
	    for religionType, NumOfCityConverted in spairs(HistoryData.GameData[Turn].NumCityFollowingReligion, function(t,a,b) if t[a] ~= t[b] then return t[a] > t[b]; else return a < b end end) do
            religionData = GameInfo.Religions[religionType];
		    if religionType == -1 then
                -- Add key entry
			    CreateKey("Pagan", defaultColor, nil, nil, nil, "number of city following religion", "[ICON_HOUSING]"..NumOfCityConverted);
            else
                CreateKey(Game.GetReligion():GetName(religionType), invisibleColor, "ICON_" .. religionData.ReligionType, UI.GetColorValue(religionData.Color), nil, "number of city following religion", "[ICON_HOUSING]"..NumOfCityConverted);
		    end
	    end
    elseif GovernmentFilter then
        Controls.OrderChoosePullDownStack:SetHide(true)
        local GovernmentDisplayed   = {}
        local IsGovernmentDisplayed = {}
        for _, playerID in ipairs (DisplayedPlayer) do
            local GovernmentType = Players[playerID]:GetCulture():GetCurrentGovernment();
            if not IsGovernmentDisplayed[GovernmentType] then
                IsGovernmentDisplayed[GovernmentType] = true
                table.insert(GovernmentDisplayed, GovernmentType)
            end
        end
        for _, GovernmentType in ipairs (GovernmentDisplayed) do
            local government = GameInfo.Governments[GovernmentType];
			if government and government.GovernmentType then
				-- Get government color
				local colorString:string = "COLOR_" .. government.GovernmentType;
				-- Add key entry
				CreateKey(government.Name, UI.GetColorValue(colorString));
            end
            
        end
    else
        Controls.OrderChoosePullDownStack:SetHide(false)
        local leftNation = #DisplayedPlayer
        local KeyOrder = {}
        local TextIcon     = ""
        for defaultOrder, playerID in ipairs(DisplayedPlayer) do
            
            if SetOrder == "TotalPlayerCityTurn" then
                TextIcon = "[ICON_HOUSING]"
            elseif SetOrder == "PlayerRealPop" then
                TextIcon = "[ICON_CITIZEN]"
            elseif SetOrder == "PlayerGamePopulation" then
                TextIcon = "[ICON_CITIZEN]"
            elseif SetOrder == "TotalPlayerNonMilUnitTurn" then
                TextIcon = "[ICON_UNIT]"
            elseif SetOrder == "TotalPlayerUnitTurn" then
                TextIcon = "[ICON_UNIT]"  
            elseif SetOrder == "TotalPlayerPowerTurn" then
                TextIcon = "[ICON_STRENGTH]"           
            elseif SetOrder == "GameMilitaryStrength" then
                TextIcon = "[ICON_STRENGTH]"              
            elseif SetOrder == "TechDiscovered" then
                TextIcon = "[ICON_SCIENCE]"                    
            elseif SetOrder == "SciencePerTurn" then
                TextIcon = "[ICON_SCIENCE]"
            elseif SetOrder == "CivicDiscovered" then
                TextIcon = "[ICON_CULTURE]"                      
            elseif SetOrder == "CulturePerTurn" then
                TextIcon = "[ICON_CULTURE]"
            elseif SetOrder == "Tourism" then
                TextIcon = "[ICON_TOURISM]"
            elseif SetOrder == "GoldBalance" then   
                TextIcon = "[ICON_GOLD]"
            elseif SetOrder == "GoldPerTurn" then  
                TextIcon = "[ICON_GOLD]"
            elseif SetOrder == "GoldGainPerTurn" then   
                TextIcon = "[ICON_GOLD]"
            elseif SetOrder == "GoldLossPerTurn" then   
                TextIcon = "[ICON_GOLD]"
            end
            if SetOrder == "defaultOrder" then
                KeyOrder[playerID] = #DisplayedPlayer - defaultOrder
                TextIcon = ""
            else
                KeyOrder[playerID]  = tonumber(HistoryData.PlayerData[playerID][Turn][SetOrder])
            end
                
        end
        for playerID, Value in spairs(KeyOrder, function(t,a,b) if t[a] ~= t[b] then return t[a] > t[b]; else return a < b end end) do
            if Value > 0 then
                local ValueDot = ""
                if math.floor(Value) ~= Value then
                    ValueDot = Round((Value - math.floor(Value))*10)
                    Value = math.floor(Value)
                end
                local ValueString = ""
                while Value >= 1000 do
                    ValueString  = ValueString ~= "" and string.sub(tostring(Value), -3 )..","..ValueString or string.sub(tostring(Value), -3 )
                    Value = math.floor(Value/1000)   
                end
                Value =  ValueString ~= "" and Value..","..ValueString or Value
                Value =  ValueDot ~= "" and Value.."."..ValueDot or Value
            end
            local playerConfig                  = PlayerConfigurations[playerID]
            local civIcon                       = "ICON_CIVILIZATION_UNKNOWN"
            if playerConfig:GetCivilizationTypeName()  then
                civIcon                       = "ICON_" .. playerConfig:GetCivilizationTypeName() 
            end
            local CivName                       = playerConfig:GetCivilizationDescription()
            local backColor, frontColor = UI.GetPlayerColors(playerID);
            local ToolTip = HistoryData.PlayerData[playerID][Turn].ToolTip
            if TextIcon ~= "" then
                CreateKey(CivName, backColor, civIcon,  frontColor, playerID, ToolTip, TextIcon..Value)
            else
                CreateKey(CivName, backColor, civIcon,  frontColor, playerID, ToolTip)
            end
        end
    end
    Controls.Legende:CalculateSize();
    if Controls.Legende:GetSizeY() + 100 < 800 then
        Controls.KeyPanel:SetSizeY(Controls.Legende:GetSizeY() + 100);
    else
        Controls.KeyPanel:SetSizeY(800);
    end
end
function CreateKey(Name, backColor, Icon,  IconColor, playerID, ToolTip, addText)
    Controls.KeyPanel:SetHide(false)
    local instance                      = m_LegendFillInst:GetInstance()
    if Icon and IconColor then
        local textureOffsetX:number, textureOffsetY:number, textureSheet:string = IconManager:FindIconAtlas(Icon, instance.Icon:GetSizeX());
        if(textureSheet == nil or textureSheet == "") then
            UI.DataError("Could not find icon in CivilizationIcon.UpdateIcon: icon=\""..Icon.."\", iconSize="..tostring(instance.Icon:GetSizeX()));
        else
	        instance.Icon:SetTexture(textureOffsetX, textureOffsetY, textureSheet);
        end
        instance.Icon:SetColor(IconColor);
        instance.Icon:SetHide(false)
    else
        instance.Icon:SetHide(true)
    end
    instance.ColorImage:SetColor(backColor);
    
    if addText then
        instance.Name:SetText(Locale.Lookup(Name).."  "..addText);
        if  instance.Name:GetSizeX() +70 > Controls.KeyPanel:GetSizeX() then
            Controls.KeyPanel:SetSizeX(instance.Name:GetSizeX() + 70)
        end
    else
        instance.Name:SetText(Locale.Lookup(Name));
    end
    if playerID then
        instance.GoToCiv:RegisterCallback( Mouse.eLClick, function() return GoToCiv(playerID); end );  
    else
        instance.GoToCiv:RegisterCallback( Mouse.eLClick, function()  end );  
    end
    if ToolTip then
        instance.GoToCiv:SetToolTipString(ToolTip)
    else
        instance.GoToCiv:SetToolTipString("")
    end
end
function SetCenterPlot(locX, locY)
    xOffset  = (- locX -1) * 224  
    if locY % 2 == 0 then
        xOffset = xOffset +89
    end
    yOffset  = (- mapy +locY+1) * 192  -130  
    Controls.PlotStackUp:SetOffsetVal( xOffset, yOffset);
end
function GoToCiv(playerID)
        local CenterPlotY       = Round((yOffset +130)/ 192 + mapy -1)
        local CenterPlotX       = 0
        if CenterPlotY % 2 == 0 then
            CenterPlotX = - Round((xOffset -89)/ 224 +1)
        else
            CenterPlotX = - Round(xOffset/ 224 +1)
        end
        local pCenterPlot       = Map.GetPlot(  CenterPlotX, CenterPlotY  )
        local centerPlotID      = pCenterPlot:GetIndex()
        local NewCenterPlotID   = centerPlotID
        local ClosestPlot;
        for plotID, player2ID in pairs(TurnPlotOwner) do
            if player2ID == playerID then
                if centerPlotID == plotID then
                    return;
                end
                local pPlot = Map.GetPlotByIndex(plotID)
                local plotDistancefromCenter = Map.GetPlotDistance(pPlot:GetX(), pPlot:GetY(), pCenterPlot:GetX(), pCenterPlot:GetY())
                if not ClosestPlot or plotDistancefromCenter < ClosestPlot then
                    NewCenterPlotID = plotID
                    ClosestPlot = plotDistancefromCenter
                end
            end
        end
        local NewCenterPlot = Map.GetPlotByIndex(NewCenterPlotID)
        SetCenterPlot(NewCenterPlot:GetX(), NewCenterPlot:GetY())
end

function SetWarTurnInformation(Turn)
    m_WarInfoInst:DestroyInstances()
    WarDisplayed      = {};
    local WarCount          = 0;
    for _,playerID  in ipairs(DisplayedPlayer) do
        local WasAtWarWith  = WasAtWarWithWho(playerID, Turn);
        if WasAtWarWith then
            local WasAtWarWithNotDone = {}
            for _,EnemyID in ipairs(WasAtWarWith) do
                local CanInsert = true
                for i=1, WarCount do
                    for _,WarOpposant in ipairs(WarDisplayed[i].Enemies) do
                        for _,WarAlly in ipairs(WarDisplayed[i].Allies) do  
                            if (WarOpposant == EnemyID and WarAlly == playerID) or (WarAlly == EnemyID and WarOpposant == playerID) then
                                CanInsert = false
                            end
                        end
                    end
                end
                if CanInsert then
                    table.insert(WasAtWarWithNotDone, EnemyID)
                end
            end 
            if #WasAtWarWithNotDone > 0 then
                WarCount = WarCount + 1
                local MoreWar;
                MoreWar = MakeWarInfoInstance(playerID, WasAtWarWithNotDone, WarCount, Turn)
                if MoreWar then
                    while MoreWar[1]  do
                        WarCount = WarCount + 1
                        MoreWar = MakeWarInfoInstance(playerID, MoreWar, WarCount, Turn)
                    end
                end
                
            end
            
        end
        
    end
    if WarExpanded.Allies and WarExpanded.Enemies then
        local WarAllyToExpand;
        local WarEnemyToExpand;
        for i=1, WarCount do
            local SameAlly  = false
            local SameEnemy = false 
            for _,WarAlly in ipairs(WarDisplayed[i].Allies) do  
                for _,WarAllyExpanded in ipairs(WarExpanded.Allies) do  
                    if WarAlly == WarAllyExpanded then
                        SameAlly = true
                    end
                end
            end 
        
            for _,WarOpposant in ipairs(WarDisplayed[i].Enemies) do
                for  _,WarOpposantExpanded in ipairs(WarExpanded.Enemies) do
                    if WarOpposantExpanded == WarOpposant then
                        SameEnemy = true
                    end
                end
            end
            if SameAlly and SameEnemy then
                WarAllyToExpand     = WarDisplayed[i].Allies
                WarEnemyToExpand    = WarDisplayed[i].Enemies
            end
        end
        if WarAllyToExpand and WarEnemyToExpand then
            ToggleAndFillWarInfoExpanded(WarAllyToExpand, WarEnemyToExpand, Turn, false)
        else
            ToggleAndFillWarInfoExpanded(WarAllyToExpand, WarEnemyToExpand, Turn, true)
        end
    end
end
function MakeWarInfoInstance(playerID, WasAtWarWith, WarCount, Turn)
    WarDisplayed[WarCount]            = {};
    WarDisplayed[WarCount].Enemies    = {};
    WarDisplayed[WarCount].Allies     = {};
    local MoreWar                     = {};
    local firstEnemyID;
    for _, oldEnemy in ipairs(WasAtWarWith) do
        if firstEnemyID and not HistoryData.PlayerData[oldEnemy][Turn]["WasAtWarWith."..firstEnemyID] then
            if #(WarDisplayed[WarCount].Enemies) > 0 then
                local CanInsert = true
                for _, EnemyID in ipairs (WarDisplayed[WarCount].Enemies) do
                    if HistoryData.PlayerData[oldEnemy][Turn]["WasAtWarWith."..EnemyID] or EnemyID == oldEnemy then
                        CanInsert = false
                        table.insert(MoreWar, oldEnemy)
                        break;
                    end
                end
                if CanInsert then
                    table.insert(WarDisplayed[WarCount].Enemies, oldEnemy)
                end
            else
                table.insert(WarDisplayed[WarCount].Enemies, oldEnemy)
            end
        elseif not firstEnemyID then
            firstEnemyID = oldEnemy
        else
            table.insert(MoreWar, oldEnemy)
        end
    end
    local WasAllyedWith    =     WasAtWarWithWho(firstEnemyID, Turn);
    if WasAllyedWith then
        for _, oldAlly in ipairs(WasAllyedWith) do
            if HistoryData.PlayerData[oldAlly][Turn] and not HistoryData.PlayerData[oldAlly][Turn]["WasAtWarWith."..playerID] and oldAlly ~= playerID then
                if #(WarDisplayed[WarCount].Allies) > 0 then
                    local CanInsert = true
                    for _, AllyID in ipairs (WarDisplayed[WarCount].Allies) do
                        
                        if  HistoryData.PlayerData[oldAlly][Turn]["WasAtWarWith."..AllyID] or AllyID == oldAlly then 
                            CanInsert = false
                            break;
                        end
                    end
                    if CanInsert then
                        table.insert(WarDisplayed[WarCount].Allies, oldAlly)
                    end
                else
                    table.insert(WarDisplayed[WarCount].Allies, oldAlly)
                end
            end
        end
    end
    local leaderTypeName:string         =  Players[playerID]:IsMajor() and PlayerConfigurations[playerID]:GetLeaderTypeName() or PlayerConfigurations[playerID]:GetCivilizationTypeName();
    local EnemyleaderTypeName:string    =  Players[firstEnemyID]:IsMajor() and PlayerConfigurations[firstEnemyID]:GetLeaderTypeName() or PlayerConfigurations[firstEnemyID]:GetCivilizationTypeName();
    if leaderTypeName and EnemyleaderTypeName then
        local Instance                  = m_WarInfoInst:GetInstance();
        Instance.MoreWarInfo:RegisterCallback( Mouse.eLClick, function() ToggleAndFillWarInfoExpanded(WarDisplayed[WarCount].Allies, WarDisplayed[WarCount].Enemies, Turn, true); end)
        
        if Players[playerID]:IsMajor() then
            Instance.Portrait:SetIcon("ICON_"..leaderTypeName);
            Instance.Portrait:SetToolTipString(Locale.Lookup(PlayerConfigurations[playerID]:GetCivilizationDescription()))
            Instance.Portrait:SetHide(false);
            Instance.MinorCivIcon:SetHide(true);
        else
            local backColor, frontColor = UI.GetPlayerColors(playerID);
            local textureOffsetX:number, textureOffsetY:number, textureSheet:string = IconManager:FindIconAtlas("ICON_"..leaderTypeName, Instance.MinorCivIcon:GetSizeX());
            if(textureSheet == nil or textureSheet == "") then
                UI.DataError("Could not find icon in CivilizationIcon.UpdateIcon: icon=\"".."ICON_"..leaderTypeName.."\", iconSize="..tostring(Instance.MinorCivIcon:GetSizeX()));
            else
	           Instance.MinorCivIcon:SetTexture(textureOffsetX, textureOffsetY, textureSheet);
            end
            Instance.MinorCivIcon:SetColor(frontColor);
            Instance.MinorCivIcon:SetToolTipString(Locale.Lookup(PlayerConfigurations[playerID]:GetCivilizationDescription()))
            Instance.MinorCivIcon:SetHide(false);
            Instance.Portrait:SetHide(true);
        end
        
        if Players[firstEnemyID]:IsMajor() then
            Instance.Portrait2:SetIcon("ICON_"..EnemyleaderTypeName);
            Instance.Portrait2:SetToolTipString(Locale.Lookup(PlayerConfigurations[firstEnemyID]:GetCivilizationDescription()))
            Instance.Portrait2:SetHide(false);
            Instance.MinorCivIcon2:SetHide(true);
        else
            local backColor, frontColor = UI.GetPlayerColors(firstEnemyID);
            local textureOffsetX:number, textureOffsetY:number, textureSheet:string = IconManager:FindIconAtlas("ICON_"..EnemyleaderTypeName, Instance.MinorCivIcon2:GetSizeX());
            if(textureSheet == nil or textureSheet == "") then
                UI.DataError("Could not find icon in CivilizationIcon.UpdateIcon: icon=\"".."ICON_"..EnemyleaderTypeName.."\", iconSize="..tostring(Instance.MinorCivIcon2:GetSizeX()));
            else
	           Instance.MinorCivIcon2:SetTexture(textureOffsetX, textureOffsetY, textureSheet);
            end
            Instance.MinorCivIcon2:SetColor(frontColor);
            Instance.MinorCivIcon2:SetToolTipString(Locale.Lookup(PlayerConfigurations[firstEnemyID]:GetCivilizationDescription()))
            Instance.MinorCivIcon2:SetHide(false);
            Instance.Portrait2:SetHide(true);
        end
        
    
        Instance.Portrait2:SetIcon("ICON_"..EnemyleaderTypeName);
        local m_WarAlly = InstanceManager:new( "WarAlly",   "CivIndicator",     Instance.WarAllyStack);
        local m_WarEnemy = InstanceManager:new( "WarAlly",   "CivIndicator",     Instance.WarEnemyStack); 
        FillAlly(m_WarAlly, WarDisplayed[WarCount].Allies)
        FillAlly(m_WarEnemy, WarDisplayed[WarCount].Enemies )
    end
    table.insert( WarDisplayed[WarCount].Allies, playerID )
    table.insert( WarDisplayed[WarCount].Enemies, firstEnemyID )
    return MoreWar;
end
function ToggleAndFillWarInfoExpanded(Allies, Enemies, Turn, hide)

    
    if WarExpanded.Allies and WarExpanded.Enemies and  hide and Allies and Enemies then
        local SameAlly  = false
        local SameEnemy = false 
        for _,WarAlly in ipairs(Allies) do  
            for _,WarAllyExpanded in ipairs(WarExpanded.Allies) do  
                if WarAlly == WarAllyExpanded then
                    SameAlly = true
                end
            end
        end 
        
        for _,WarOpposant in ipairs(Enemies) do
            for  _,WarOpposantExpanded in ipairs(WarExpanded.Enemies) do
                if WarOpposantExpanded == WarOpposant then
                    SameEnemy = true
                end
            end
        end
        if SameAlly and SameEnemy then
            hide = true
        else
            hide = false
        end
    end
    
    if Controls.WarInfoExpanded:IsHidden() or not hide then
        local playerID = Allies[#Allies]
        local firstEnemyID = Enemies[#Enemies]
        local WarAllyToExpand;
        local WarEnemyToExpand;

        table.remove( Allies, #Allies )
        table.remove( Enemies, #Enemies )
        
        local leaderTypeName:string         =  Players[playerID]:IsMajor() and PlayerConfigurations[playerID]:GetLeaderTypeName() or PlayerConfigurations[playerID]:GetCivilizationTypeName();
        local EnemyleaderTypeName:string    =  Players[firstEnemyID]:IsMajor() and PlayerConfigurations[firstEnemyID]:GetLeaderTypeName() or PlayerConfigurations[firstEnemyID]:GetCivilizationTypeName();    
        Controls.WarInfoExpanded:SetHide(false)
        
        if Players[playerID]:IsMajor() then
            Controls.Portrait:SetIcon("ICON_"..leaderTypeName);
            Controls.Portrait:SetToolTipString(Locale.Lookup(PlayerConfigurations[playerID]:GetCivilizationDescription()))
            Controls.Portrait:SetHide(false);
            Controls.MinorCivIcon:SetHide(true);
        else
            local backColor, frontColor = UI.GetPlayerColors(playerID);
            local textureOffsetX:number, textureOffsetY:number, textureSheet:string = IconManager:FindIconAtlas("ICON_"..leaderTypeName, Controls.MinorCivIcon:GetSizeX());
            if(textureSheet == nil or textureSheet == "") then
                UI.DataError("Could not find icon in CivilizationIcon.UpdateIcon: icon=\"".."ICON_"..leaderTypeName.."\", iconSize="..tostring(Controls.MinorCivIcon:GetSizeX()));
            else
	           Controls.MinorCivIcon:SetTexture(textureOffsetX, textureOffsetY, textureSheet);
            end
            Controls.MinorCivIcon:SetColor(frontColor);
            Controls.MinorCivIcon:SetToolTipString(Locale.Lookup(PlayerConfigurations[playerID]:GetCivilizationDescription()))
            Controls.MinorCivIcon:SetHide(false);
            Controls.Portrait:SetHide(true);
        end
        
        if Players[firstEnemyID]:IsMajor() then
            Controls.Portrait2:SetIcon("ICON_"..EnemyleaderTypeName);
            Controls.Portrait2:SetToolTipString(Locale.Lookup(PlayerConfigurations[firstEnemyID]:GetCivilizationDescription()))
            Controls.Portrait2:SetHide(false);
            Controls.MinorCivIcon2:SetHide(true);
        else
            local backColor, frontColor = UI.GetPlayerColors(firstEnemyID);
            local textureOffsetX:number, textureOffsetY:number, textureSheet:string = IconManager:FindIconAtlas("ICON_"..EnemyleaderTypeName, Controls.MinorCivIcon2:GetSizeX());
            if(textureSheet == nil or textureSheet == "") then
                UI.DataError("Could not find icon in CivilizationIcon.UpdateIcon: icon=\"".."ICON_"..EnemyleaderTypeName.."\", iconSize="..tostring(Controls.MinorCivIcon2:GetSizeX()));
            else
	           Controls.MinorCivIcon2:SetTexture(textureOffsetX, textureOffsetY, textureSheet);
            end
            Controls.MinorCivIcon2:SetColor(frontColor);
            Controls.MinorCivIcon2:SetToolTipString(Locale.Lookup(PlayerConfigurations[firstEnemyID]:GetCivilizationDescription()))
            Controls.MinorCivIcon2:SetHide(false);
            Controls.Portrait2:SetHide(true);
        end
        
        
        Controls.Portrait:SetIcon("ICON_"..leaderTypeName);
        Controls.Portrait2:SetIcon("ICON_"..EnemyleaderTypeName);

        m_WarAllyExpanded:ResetInstances()    
        m_WarEnemyExpanded:ResetInstances()  
        
        FillAlly(m_WarAllyExpanded, Allies)
        FillAlly(m_WarEnemyExpanded, Enemies)

        local AllyUnitNumber    = HistoryData.PlayerData[playerID][Turn].TotalPlayerUnitTurn
        local AllyPower         = HistoryData.PlayerData[playerID][Turn].TotalPlayerPowerTurn 
        local AllyCityNumber    = HistoryData.PlayerData[playerID][Turn].TotalPlayerCityTurn 
        local AllyHP            = HistoryData.PlayerData[playerID][Turn].TotalPlayerHPTurn 
        
        local AllyUnit           = {}
        if AllyUnitNumber > 0 then
            for i = 1, AllyUnitNumber do
                table.insert(AllyUnit, HistoryData.PlayerData[playerID][Turn]["Typeof."..i])
            end
        end
        
        for _,AllyID in ipairs(Allies) do
            AllyUnitNumber    = AllyUnitNumber + HistoryData.PlayerData[AllyID][Turn].TotalPlayerUnitTurn;
            AllyPower         = AllyPower + HistoryData.PlayerData[AllyID][Turn].TotalPlayerPowerTurn;
            AllyCityNumber    = AllyCityNumber + HistoryData.PlayerData[AllyID][Turn].TotalPlayerCityTurn;
            AllyHP            = AllyHP + HistoryData.PlayerData[AllyID][Turn].TotalPlayerHPTurn;
            
            if HistoryData.PlayerData[AllyID][Turn].TotalPlayerUnitTurn > 0 then
                for i = 1, HistoryData.PlayerData[AllyID][Turn].TotalPlayerUnitTurn do
                    table.insert(AllyUnit,  HistoryData.PlayerData[AllyID][Turn]["Typeof."..i]);
                end
            end
        end
        
        
        local EnemiesUnitNumber = HistoryData.PlayerData[firstEnemyID][Turn].TotalPlayerUnitTurn;
        local EnemiesPower      = HistoryData.PlayerData[firstEnemyID][Turn].TotalPlayerPowerTurn;
        local EnemiesCityNumber = HistoryData.PlayerData[firstEnemyID][Turn].TotalPlayerCityTurn;
        local EnemiesHP         = HistoryData.PlayerData[firstEnemyID][Turn].TotalPlayerHPTurn;
        
        local EnemyUnit           = {}
        
        if EnemiesUnitNumber > 0 then
            for i = 1, EnemiesUnitNumber do
                table.insert(EnemyUnit,  HistoryData.PlayerData[firstEnemyID][Turn]["Typeof."..i]);
            end
        end
        
        for _,EnemyID in ipairs(Enemies) do
            EnemiesUnitNumber    = EnemiesUnitNumber + HistoryData.PlayerData[EnemyID][Turn].TotalPlayerUnitTurn;
            EnemiesPower         = EnemiesPower + HistoryData.PlayerData[EnemyID][Turn].TotalPlayerPowerTurn;
            EnemiesCityNumber    = EnemiesCityNumber + HistoryData.PlayerData[EnemyID][Turn].TotalPlayerCityTurn;
            EnemiesHP            = EnemiesHP + HistoryData.PlayerData[EnemyID][Turn].TotalPlayerHPTurn;
            
            if HistoryData.PlayerData[EnemyID][Turn].TotalPlayerUnitTurn > 0 then
                for i = 1, HistoryData.PlayerData[EnemyID][Turn].TotalPlayerUnitTurn do
                    table.insert(EnemyUnit,  HistoryData.PlayerData[EnemyID][Turn]["Typeof."..i]);
                end
            end
        end
        
        
        table.sort(AllyUnit)
        table.sort(EnemyUnit)
        
        Controls.AllyUnitNumber:SetText("[ICON_Unit]"..AllyUnitNumber);
        Controls.AllyPower:SetText("[ICON_STRENGTH]"..AllyPower);
        Controls.AllYCityNumber:SetText("[ICON_Housing]"..AllyCityNumber);
        Controls.AllyHp:SetText("[ICON_UnderSiege]"..AllyHP);
        
        Controls.EnemyUnitNumber:SetText("[ICON_Unit]"..EnemiesUnitNumber);
        Controls.Enemypower:SetText("[ICON_STRENGTH]"..EnemiesPower);
        Controls.EnemyCityNumber:SetText("[ICON_Housing]"..EnemiesCityNumber);
        Controls.EnemyHp:SetText("[ICON_UnderSiege]"..EnemiesHP);
        
        m_WarAllyUnitInfoInst:ResetInstances()
        m_WarEnemyUnitInfoInst:ResetInstances()
        
        if #AllyUnit > 0 then
            FillUnitInstance(AllyUnit, true)
        end
        if #EnemyUnit > 0 then
            FillUnitInstance(EnemyUnit, false)
        end
        
        
        table.insert( Allies, playerID )
        table.insert( Enemies, firstEnemyID )
        WarExpanded.Allies = Allies
        WarExpanded.Enemies = Enemies
    else
        if WarExpanded.Allies and WarExpanded.Enemies then
            WarExpanded.Allies      = nil
            WarExpanded.Enemies     = nil
        end
        Controls.WarInfoExpanded:SetHide(true)
    end
end
function FillUnitInstance(AllyUnit, bAllyTeam)
    local AllyUnitInstance      = bAllyTeam and m_WarAllyUnitInfoInst:GetInstance() or  m_WarEnemyUnitInfoInst:GetInstance()
    local instanceID            = 0
    local Color                 = bAllyTeam and greenColor or RedColor
    local oldUnitType;
    for k, UnitType in ipairs(AllyUnit) do
        instanceID = instanceID + 1
        
        if not oldUnitType then
            oldUnitType = UnitType;
        end
        if oldUnitType ~= UnitType then
            oldUnitType = UnitType;
            for i= instanceID, 14 do
                AllyUnitInstance["UnitIcon"..i]:SetHide(true)
            end
            instanceID = 15
        end
        
            
        if instanceID <15 then
            AllyUnitInstance["UnitIcon"..instanceID]:SetIcon("ICON_"..GameInfo.Units[UnitType].UnitType)
            AllyUnitInstance["UnitIcon"..instanceID]:SetToolTipString(Locale.Lookup(GameInfo.Units[UnitType].Name))
            AllyUnitInstance["UnitIcon"..instanceID]:SetColor(Color)
            AllyUnitInstance["UnitIcon"..instanceID]:SetHide(false)
        else
            instanceID = 1
            AllyUnitInstance     = bAllyTeam and m_WarAllyUnitInfoInst:GetInstance() or  m_WarEnemyUnitInfoInst:GetInstance()
            AllyUnitInstance["UnitIcon"..instanceID]:SetIcon("ICON_"..GameInfo.Units[UnitType].UnitType) 
            AllyUnitInstance["UnitIcon"..instanceID]:SetToolTipString(Locale.Lookup(GameInfo.Units[UnitType].Name))
            AllyUnitInstance["UnitIcon"..instanceID]:SetColor(Color)
            AllyUnitInstance["UnitIcon"..instanceID]:SetHide(false)
        end
        
        if k == #AllyUnit then
            for i= instanceID+1, 14 do
                AllyUnitInstance["UnitIcon"..i]:SetHide(true)
            end
        end
    end
end
function FillAlly(m_WarAlly, Ally)
    for i, playerID in ipairs(Ally) do
        local AllyInstance                 = m_WarAlly:GetInstance();
        local LeaderIcon = Players[playerID]:IsMajor() and "ICON_"..PlayerConfigurations[playerID]:GetLeaderTypeName() or "ICON_"..PlayerConfigurations[playerID]:GetCivilizationTypeName()
     
        if  Players[playerID]:IsMajor() then
            AllyInstance.CivIcon:SetIcon(LeaderIcon);
        else
            local backColor, frontColor = UI.GetPlayerColors(firstEnemyID);
            local textureOffsetX:number, textureOffsetY:number, textureSheet:string = IconManager:FindIconAtlas(LeaderIcon, AllyInstance.CivIcon:GetSizeX());
            if(textureSheet == nil or textureSheet == "") then
                UI.DataError("Could not find icon in CivilizationIcon.UpdateIcon: icon=\"".."ICON_"..LeaderIcon.."\", iconSize="..tostring(AllyInstance.CivIcon:GetSizeX()));
            else
	           AllyInstance.CivIcon:SetTexture(textureOffsetX, textureOffsetY, textureSheet);
            end
            AllyInstance.CivIcon:SetColor(frontColor);
        end
        AllyInstance.CivIcon:SetToolTipString(Locale.Lookup(PlayerConfigurations[playerID]:GetCivilizationDescription()))
  
        if i == 1 then
            AllyInstance.CivIndicator:SetOffsetX(37)
        elseif i == 2 then
            AllyInstance.CivIndicator:SetOffsetX(17)
            AllyInstance.CivIndicator:SetOffsetY(-10)
        elseif i == 3 then
            AllyInstance.CivIndicator:SetOffsetX(-3)
        elseif i == 4 then
            AllyInstance.CivIndicator:SetOffsetX(-13)
            AllyInstance.CivIndicator:SetOffsetY(17)
        elseif i == 5 then
            AllyInstance.CivIndicator:SetOffsetX(-3)
            AllyInstance.CivIndicator:SetOffsetY(36)
        elseif i == 6 then
            AllyInstance.CivIndicator:SetOffsetX(17)
            AllyInstance.CivIndicator:SetOffsetY(46)
        elseif i == 7 then
            AllyInstance.CivIndicator:SetOffsetX(37)
            AllyInstance.CivIndicator:SetOffsetY(36)
        elseif i == 8 then
            AllyInstance.CivIndicator:SetOffsetX(47)
            AllyInstance.CivIndicator:SetOffsetY(17)
        end
    end
end

function GetLastTurnChange(PlotID, Turn)
    if HistoryData.PlotData[PlotID][Turn] and HistoryData.PlotData[PlotID][Turn].LastTurnEvent then
        return HistoryData.PlotData[PlotID][Turn].LastTurnEvent
    elseif HistoryData.PlotData[PlotID][Turn -1] and HistoryData.PlotData[PlotID][Turn -1].LastTurnEvent then
        return HistoryData.PlotData[PlotID][Turn -1].LastTurnEvent
    end
    return firstTurn;
end
function SetPlotInformation( PlotID, Turn)
    
    local LastTurnChange =  GetLastTurnChange(PlotID, Turn -1)
    local PlotInforMation = {}
    if PlotID == Map.GetPlotCount() -1 and Options["EndTurnSound"] then
       UI.PlaySound("Confirm_Bed_Positive");
    end
    local pPlot = Map.GetPlotByIndex(PlotID);
    
    local terrain = GameInfo.Terrains[pPlot:GetTerrainType()];
    local PlotIcon = "ICON_TERRAIN_PLAINS"
    if pPlot:IsNaturalWonder() then
        PlotIcon = "ICON_"..GameInfo.Features[pPlot:GetFeatureType()].FeatureType;
    elseif(terrain) then
        local terrainType = terrain.TerrainType;
        PlotIcon =  "ICON_" .. terrainType;
    end
    PlotInforMation.PlotTerrain = PlotIcon
    
    
    
    local OwnerColor = invisibleColor;
    
    if pPlot:IsOwned() then
        OwnerColor    = UI.GetPlayerColors( pPlot:GetOwner() );
        PlotInforMation.Owner = pPlot:GetOwner()
    end
    PlotInforMation.OwnerColor = OwnerColor
    
    local plotImprovement   = pPlot:GetImprovementType();
    local unitsInPlot       = Units.GetUnitsInPlot(pPlot);
    local districtType      = pPlot:GetDistrictType();
    local eResourceType     = pPlot:GetResourceType();
    if pPlot:IsCity() then
        PlotInforMation.plotWasCity = true
        local pCity                 = CityManager.GetCityAt(pPlot:GetX(), pPlot:GetY())
        if pCity then
            local GovernMentType        = Players[pCity:GetOwner()]:GetCulture():GetCurrentGovernment();
            local religionType:number   = pCity:GetReligion():GetMajorityReligion()
            for _, plot2ID in pairs(Map.GetCityPlots():GetPurchasedPlots(pCity)) do
                PlotReligion[plot2ID]    = religionType
                PlotGovernMent[plot2ID]  = GovernMentType
                local LastTurnChange2 =  GetLastTurnChange(plot2ID, Turn)
                if plot2ID < PlotID and (GameConfiguration.GetValue("ReligionColor."..plot2ID.."."..LastTurnChange2) ~= religionType or GameConfiguration.GetValue("GovernMentColor."..plot2ID.."."..LastTurnChange2) ~= GovernMentType) then
                     SetPlotInformation( plot2ID, Turn)
                end
                
            end
            local ReligionName = religionType ~= -1 and Game.GetReligion():GetName(religionType) or "Pagans";
            PlotInforMation.CityIconToolTip = "          "..Locale.Lookup(pCity:GetName()).."[NEWLINE][NEWLINE]Owner: "..Locale.Lookup(PlayerConfigurations[pCity:GetOwner()]:GetCivilizationDescription()).."[NEWLINE]Population: "..pCity:GetPopulation().."[NEWLINE]Religion: "..ReligionName;
        end
    end
    if plotImprovement ~= -1 and GameInfo.Improvements[plotImprovement].BarbarianCamp then
        PlotInforMation.plotWasBarbarianCamp = true  -- "ICON_IMPROVEMENT_CAMP"
    end
    if #unitsInPlot > 0 then
        for _, pUnit in ipairs(unitsInPlot) do
            local OwnerColor                                = UI.GetPlayerColors( pUnit:GetOwner() );
            if pUnit:GetOwner() ~= Game.GetLocalPlayer() then 
                PlotInforMation.PlotIconHide = true
            end
            if GameInfo.Units[pUnit:GetUnitType()].UnitType then
                PlotInforMation.plotUnitIcon = "ICON_"..GameInfo.Units[pUnit:GetUnitType()].UnitType;
            else
                PlotInforMation.plotUnitIcon = "ICON_"..GameInfo.Units[1].UnitType;
            end
            local healthPercent = 0;
            local maxDamage = pUnit:GetMaxDamage();
            if (maxDamage > 0) then		
                healthPercent = math.max( math.min( (maxDamage - pUnit:GetDamage()) / maxDamage, 1 ), 0 );
            end  
            local strengthString = "";
            if pUnit:GetCombat() > 0 then
                strengthString = strengthString .. "[ICON_Strength]" ..pUnit:GetCombat()
            end
            if pUnit:GetRangedCombat() > 0 then
                strengthString = strengthString .. "[ICON_Ranged]" ..pUnit:GetRangedCombat()
            end
            if pUnit:GetBombardCombat() > 0 then
                strengthString = strengthString .. "[ICON_Bombard]" ..pUnit:GetBombardCombat()
            end
            if pUnit:GetAntiAirCombat() > 0 then
                strengthString = strengthString .. "[ICON_AntiAir_Large]" ..pUnit:GetAntiAirCombat()
            end
            if pUnit:GetReligiousStrength() > 0 then
                strengthString = strengthString .. "[ICON_Religion]" ..pUnit:GetReligiousStrength()
            end
            PlotInforMation.UnitIconOwnerColor = OwnerColor;
            PlotInforMation.UnitIconToolTip = Locale.Lookup(GameInfo.Units[pUnit:GetUnitType()].Name).."[NEWLINE][NEWLINE]Owner :"..Locale.Lookup(PlayerConfigurations[pUnit:GetOwner()]:GetCivilizationDescription()).."[NEWLINE]Heath: ".. maxDamage - pUnit:GetDamage() .."/".. maxDamage.."[NEWLINE]Strength: "..strengthString;
            PlotInforMation.UnitHealthPercent = healthPercent*100;
            break;
        end
    end
    if districtType ~= -1 then
        if GameInfo.Districts[districtType].DistrictType == "DISTRICT_WONDER" then
            local tBuildingTypes = CityManager.GetDistrictAt(pPlot):GetCity():GetBuildings():GetBuildingsAtLocation(PlotID);
            for _, buildingIndex in ipairs(tBuildingTypes) do
                PlotInforMation.plotWonderIcon = "ICON_"..GameInfo.Buildings[buildingIndex].BuildingType;
                PlotInforMation.WonderIconToolTip = Locale.Lookup(GameInfo.Buildings[buildingIndex].Name);
            end
        else
            PlotInforMation.plotDistrictIcon = "ICON_"..GameInfo.Districts[districtType].DistrictType;
            PlotInforMation.plotDistrictIconToolTip = Locale.Lookup(GameInfo.Districts[districtType].Name);
        end
    end
    if eResourceType ~= -1 then
        local resource                    = GameInfo.Resources[eResourceType];
        local IconResourceName = "ICON_"..resource.ResourceType;
        if (resource.PrereqTech) then
            local tech              = GameInfo.Technologies[resource.PrereqTech];              
            PlotInforMation.plotRessourcePrereqTech = tech.Index;
        end
        PlotInforMation.plotRessourceIcon = IconResourceName;
        PlotInforMation.plotRessourceIconToolTip = Locale.Lookup(resource.Name);
    end
    
    PlotInforMation.ReligionColor    = PlotReligion[PlotID]
    PlotInforMation.GovernMentColor  = PlotGovernMent[PlotID] 
    HistoryData.PlotData[PlotID][Turn]  = {}
    HistoryData.PlotData[PlotID][Turn].LastTurnEvent  = LastTurnChange
    if not GameConfiguration.GetValue(PlotID..".Changed."..Turn) then
        for _, key  in ipairs(AllPlotInfoKeys) do
            if  GameConfiguration.GetValue(key.."."..PlotID.."."..LastTurnChange) ~= PlotInforMation[key] then
                GameConfiguration.SetValue(PlotID..".Changed."..Turn, true)
                HistoryData.PlotData[PlotID][Turn].LastTurnEvent = Turn
                break;
            end
        end
    end
    if  GameConfiguration.GetValue(PlotID..".Changed."..Turn) then
        HistoryData.PlotData[PlotID][Turn].LastTurnEvent = Turn
        for key, value in pairs(PlotInforMation) do
            GameConfiguration.SetValue(key.."."..PlotID.."."..Turn, value)
            HistoryData.PlotData[PlotID][Turn][key] = value
        end
    end
end

function OnPlotInfoStackTimeEnd()
    for plotID = NextPlot, Map.GetPlotCount() -1 do
        SetPlotInformation(plotID, SetTurn)
        if plotID % 3000 == 0 then
           Controls.PlotInfoStackTime:SetToBeginning();
		   Controls.PlotInfoStackTime:Play();
           NextPlot = plotID +1
           break;
        end
    end
end

function GetTurnInformations()
    if not Game then
        return;
    end
    local CurrentTurn                                   = Game.GetCurrentGameTurn() -1
    if HistoryData.GameData[CurrentTurn] and HistoryData.GameData[CurrentTurn].RealPopulation then
        CurrentTurn                                     = Game.GetCurrentGameTurn() 
    end
    local TurnInformation       = {}
    TurnInformation.Name        = "Turn "..CurrentTurn
    TurnInformation.Tooltip     = GameConfiguration.GetValue("TurnTooltip."..CurrentTurn)
    if type(TurnInformation.Tooltip) ~= "string" then
        if ResearchBank[CurrentTurn -1] then
             TurnInformation.Tooltip  = ResearchBank[CurrentTurn -1].Tooltip
        else
            TurnInformation.Tooltip = "";
        end
    end
    ResearchBank[CurrentTurn]   = TurnInformation
   
    HistoryData.GameData[CurrentTurn]                           = {}
    HistoryData.GameData[CurrentTurn].NumCityFollowingReligion  = {}
    
    local kPlayers	:table = PlayerManager.GetWasEverAlive();
    local RealPopulation = 0;
    local GamePopulation = 0;
	for _, pPlayer in ipairs(kPlayers) do
        local playerID  = pPlayer:GetID();
        HistoryData.PlayerData[playerID][CurrentTurn]    = {}
        local PlayerToolTip = "";
        local playerRealPop = 0
        local PlayerGamePopulation = 0
        local CityCount = 0;
        for _,pCity in pPlayer:GetCities():Members() do
            local hab = pCity:GetPopulation();
            RealPopulation = Round(RealPopulation + ( hab^3.6 - hab^3+1 )*2);
            playerRealPop = Round(playerRealPop + ( hab^3.6 - hab^3+1 )*2);
            GamePopulation = GamePopulation + hab;
            PlayerGamePopulation = PlayerGamePopulation + hab;
            CityCount = CityCount +1;
            local religionType:number   = pCity:GetReligion():GetMajorityReligion()
            HistoryData.GameData[CurrentTurn].NumCityFollowingReligion[religionType]    =  HistoryData.GameData[CurrentTurn].NumCityFollowingReligion[religionType] and HistoryData.GameData[CurrentTurn].NumCityFollowingReligion[religionType] +1 or 1
        end
        for religionType, NumOfCity in pairs(HistoryData.GameData[CurrentTurn].NumCityFollowingReligion) do
            GameConfiguration.SetValue("NumCityFollowingReligion"..religionType.."."..CurrentTurn, NumOfCity)
        end
        PlayerToolTip = PlayerToolTip..CityCount.."[ICON_Housing]Cities [NEWLINE]";
        PlayerToolTip = PlayerToolTip..playerRealPop..",000[ICON_CITIZEN]Real Populations [NEWLINE]";
        PlayerToolTip = PlayerToolTip..PlayerGamePopulation.."[ICON_CITIZEN]Game Population [NEWLINE][NEWLINE]";
        
        HistoryData.PlayerData[playerID][CurrentTurn].PlayerRealPop           = playerRealPop*1000
        HistoryData.PlayerData[playerID][CurrentTurn].PlayerGamePopulation    = PlayerGamePopulation
        local AtWarWith = IsAtWarWithWho(playerID);
        if AtWarWith then
            for _, enemyID in ipairs(AtWarWith) do
                HistoryData.PlayerData[playerID][CurrentTurn]["WasAtWarWith."..enemyID] = true
            end     
        end
        local TotalPlayerUnit   = 0;
        local TotalMilitaryUnit = 0;
        local TotalPlayerPower  = 0;
        local TotalPlayerHP     = 0;
        for _, pUnit in Players[playerID]:GetUnits():Members() do
            TotalPlayerUnit = TotalPlayerUnit +1;
            local isMilitaryUnit  = false
            if pUnit:GetRangedCombat() >= pUnit:GetBombardCombat() and pUnit:GetRangedCombat() >= pUnit:GetCombat() and pUnit:GetRangedCombat() >= pUnit:GetAntiAirCombat() and pUnit:GetRangedCombat() > 0 then
                TotalPlayerPower = TotalPlayerPower + pUnit:GetRangedCombat();
                isMilitaryUnit = true
            elseif pUnit:GetBombardCombat() >= pUnit:GetCombat() and pUnit:GetBombardCombat() >= pUnit:GetAntiAirCombat() and  pUnit:GetBombardCombat() > 0 then
                TotalPlayerPower = TotalPlayerPower + pUnit:GetBombardCombat();
                isMilitaryUnit = true
            elseif pUnit:GetAntiAirCombat() >= pUnit:GetCombat() and pUnit:GetAntiAirCombat() > 0 then
		        TotalPlayerPower = TotalPlayerPower + pUnit:GetAntiAirCombat()
                isMilitaryUnit = true
	        elseif pUnit:GetCombat() > 0 then
                TotalPlayerPower = TotalPlayerPower + pUnit:GetCombat();
                isMilitaryUnit = true
            end
            TotalPlayerHP = TotalPlayerHP + pUnit:GetMaxDamage() pUnit:GetDamage();
            if isMilitaryUnit then
                TotalMilitaryUnit = TotalMilitaryUnit + 1
                HistoryData.PlayerData[playerID][CurrentTurn]["Typeof."..TotalMilitaryUnit] = pUnit:GetUnitType()
            end
        end
        
        HistoryData.PlayerData[playerID][CurrentTurn].TotalPlayerNonMilUnitTurn     = TotalPlayerUnit 
        HistoryData.PlayerData[playerID][CurrentTurn].TotalPlayerUnitTurn           = TotalMilitaryUnit       
        HistoryData.PlayerData[playerID][CurrentTurn].TotalPlayerPowerTurn          = TotalPlayerPower    
        HistoryData.PlayerData[playerID][CurrentTurn].GameMilitaryStrength          = pPlayer:GetStats():GetMilitaryStrength()   
        HistoryData.PlayerData[playerID][CurrentTurn].TotalPlayerHPTurn             = TotalPlayerHP    
        HistoryData.PlayerData[playerID][CurrentTurn].TotalPlayerCityTurn           = CityCount      
        
        PlayerToolTip = PlayerToolTip..TotalPlayerUnit.."[ICON_UNIT]Units [NEWLINE]";
        PlayerToolTip = PlayerToolTip..TotalMilitaryUnit.."[ICON_UNIT]Military Units [NEWLINE]";
        PlayerToolTip = PlayerToolTip..TotalPlayerPower.."[ICON_STRENGTH]Total Military Strength [NEWLINE]";
        PlayerToolTip = PlayerToolTip..pPlayer:GetStats():GetMilitaryStrength().."[ICON_STRENGTH]Game Military Strength [NEWLINE][NEWLINE]";
        
        PlayerToolTip = PlayerToolTip..pPlayer:GetStats():GetNumTechsResearched().."[ICON_SCIENCE]Tech Discovered [NEWLINE]";
        PlayerToolTip = PlayerToolTip..Round(pPlayer:GetTechs():GetScienceYield(),1).."[ICON_SCIENCE]Science per turn [NEWLINE][NEWLINE]";
        
        HistoryData.PlayerData[playerID][CurrentTurn].TechDiscovered = pPlayer:GetStats():GetNumTechsResearched()
        HistoryData.PlayerData[playerID][CurrentTurn].SciencePerTurn = tostring(Round(pPlayer:GetTechs():GetScienceYield(),1))
        
        local CivicDiscovered = 0
        for kCivic in GameInfo.Civics() do
            if pPlayer:GetCulture():HasCivic(kCivic.Index) then
                CivicDiscovered = CivicDiscovered + 1
            end         
        end
        PlayerToolTip = PlayerToolTip..CivicDiscovered.."[ICON_CULTURE]Civic Discovered [NEWLINE]";
        PlayerToolTip = PlayerToolTip..Round(pPlayer:GetCulture():GetCultureYield(),1).."[ICON_CULTURE]Culture per turn [NEWLINE]";
        PlayerToolTip = PlayerToolTip..Round(pPlayer:GetStats():GetTourism(),1).."[ICON_TOURISM]Tourism [NEWLINE][NEWLINE]";
        
        PlayerToolTip = PlayerToolTip..Round(pPlayer:GetTreasury():GetGoldBalance(),1).."[ICON_GOLD]Gold Balance[NEWLINE]"
        PlayerToolTip = PlayerToolTip..Round(pPlayer:GetTreasury():GetGoldYield(),1) - Round(pPlayer:GetTreasury():GetTotalMaintenance(),1).."[ICON_GOLD]Gold per turn[NEWLINE]"
        PlayerToolTip = PlayerToolTip..Round(pPlayer:GetTreasury():GetGoldYield(),1).."[ICON_GOLD] Gold Gain Per turn[NEWLINE]"
        PlayerToolTip = PlayerToolTip..Round(pPlayer:GetTreasury():GetTotalMaintenance(),1).."[ICON_GOLD] Gold Loss per turn[NEWLINE]"
             
        HistoryData.PlayerData[playerID][CurrentTurn].CivicDiscovered   = CivicDiscovered
        HistoryData.PlayerData[playerID][CurrentTurn].CulturePerTurn    = tostring(Round(pPlayer:GetCulture():GetCultureYield(),1))
        HistoryData.PlayerData[playerID][CurrentTurn].Tourism           = tostring(Round(pPlayer:GetStats():GetTourism(),1))
        
        HistoryData.PlayerData[playerID][CurrentTurn].GoldBalance       = tostring(Round(pPlayer:GetTreasury():GetGoldBalance(),1))
        HistoryData.PlayerData[playerID][CurrentTurn].GoldPerTurn       = tostring(Round(pPlayer:GetTreasury():GetGoldYield(),1) - Round(pPlayer:GetTreasury():GetTotalMaintenance(),1))
        HistoryData.PlayerData[playerID][CurrentTurn].GoldGainPerTurn   = tostring(Round(pPlayer:GetTreasury():GetGoldYield(),1))
        HistoryData.PlayerData[playerID][CurrentTurn].GoldLossPerTurn   = tostring(Round(pPlayer:GetTreasury():GetTotalMaintenance(),1))
        
        HistoryData.PlayerData[playerID][CurrentTurn].ToolTip   = PlayerToolTip
        
        for key, value in pairs (HistoryData.PlayerData[playerID][CurrentTurn]) do
            GameConfiguration.SetValue(key..".playerID."..playerID..".Turn."..CurrentTurn, value)
        end
    end
    GameConfiguration.SetValue("RealPopulation"..CurrentTurn, RealPopulation );
    GameConfiguration.SetValue("GamePopulation"..CurrentTurn, GamePopulation );
    HistoryData.GameData[CurrentTurn].RealPopulation    = RealPopulation
    HistoryData.GameData[CurrentTurn].GamePopulation    = GamePopulation 
    if GameConfiguration.GetValue("checkIfRazed") > 0 then
        for i = 1, GameConfiguration.GetValue("checkIfRazed") do
            local pPlot = Map.GetPlot(GameConfiguration.GetValue("checkIfRazedx"..i), GameConfiguration.GetValue("checkIfRazedy"..i))
            if not pPlot:IsCity() then
                local EventTurn         = Game.GetCurrentGameTurn() - 1
                local cityKey           = GameConfiguration.GetValue("checkIfRazedx"..i).."."..GameConfiguration.GetValue("checkIfRazedy"..i)
                local unitsInPlot       = Units.GetUnitsInPlot(pPlot)
                local CityName          = GameConfiguration.GetValue("CityName"..cityKey)  
                local ConquerorName     = "Unknown Player"
                local ConqueredPlayerID = GameConfiguration.GetValue("checkIfRazedplayer"..i)
                for _, pUnit in ipairs(unitsInPlot) do
                    ConquerorName = Locale.Lookup(PlayerConfigurations[pUnit:GetOwner()]:GetCivilizationDescription());
                    if ConqueredPlayerID == pUnit:GetOwner() then
                        ConqueredPlayerID = GameConfiguration.GetValue("CityOldOwner"..cityKey)
                    end           
                end
                local ConqueredPlayerName = Locale.Lookup(PlayerConfigurations[ConqueredPlayerID]:GetCivilizationDescription());
                AddTurnEvent( ConquerorName.." Destroyed "..CityName.." which belonged to the "..ConqueredPlayerName, EventTurn , TypeGovernment)
            end
        end
        GameConfiguration.SetValue("checkIfRazed", 0)
    end
    NextPlot = 0
    SetTurn  = CurrentTurn
    Controls.PlotInfoStackTime:SetToBeginning();
    Controls.PlotInfoStackTime:Play();

end

function IsAtWarWithWho(playerID)                                   -- return with who the player is at war with
    local pPlayersAtWarWith = {};
    local count             = 0;
    local kPlayers	 :table = PlayerManager.GetWasEverAlive();
    local pPlayer       = Players[playerID] 
    if (pPlayer.IsFreeCities and pPlayer:IsFreeCities()) or pPlayer:IsBarbarian()  or not pPlayer:IsAlive() then
        return false;
    end
    for _, pOtherPlayer in ipairs(kPlayers) do
        local otherPlayerID = pOtherPlayer:GetID();
        if otherPlayerID ~= playerID then 
            local IsValidPlayer = true
            if (pOtherPlayer.IsFreeCities and pOtherPlayer:IsFreeCities()) or pOtherPlayer:IsBarbarian() or not pOtherPlayer:IsAlive()then
                IsValidPlayer = false
            end
            if IsValidPlayer and (pPlayer:GetDiplomacy():IsAtWarWith(otherPlayerID) or  pOtherPlayer:GetDiplomacy():IsAtWarWith(playerID) ) then
                table.insert(pPlayersAtWarWith, otherPlayerID)
            end
        end    
	end
    if #pPlayersAtWarWith == 0 then
        return false;
    else
        return pPlayersAtWarWith;
    end
end

function WasAtWarWithWho(playerID, Turn)                                   -- return with who the player is at war with
    local pPlayersAtWarWith = {};
    local kPlayers	 :table = PlayerManager.GetWasEverAlive();
    for _, pOtherPlayer in ipairs(kPlayers) do
        local otherPlayerID = pOtherPlayer:GetID();
        if otherPlayerID ~= playerID then
            
            if HistoryData.PlayerData[playerID] and HistoryData.PlayerData[playerID][Turn] and HistoryData.PlayerData[playerID][Turn]["WasAtWarWith."..otherPlayerID] then
                table.insert(pPlayersAtWarWith, otherPlayerID)
            end
        end    
	end
    if #pPlayersAtWarWith < 1 then
        return false;
    else
        return pPlayersAtWarWith;
    end
end

function AddTurnEvent( string, EventTurn, StringType)
    if EventTurn == firstTurn then
        return;
    end
    if GameConfiguration.GetValue("TurnTooltip."..EventTurn) then
        GameConfiguration.SetValue("TurnTooltip."..EventTurn, GameConfiguration.GetValue("TurnTooltip."..EventTurn).."[NEWLINE][NEWLINE]"..string)
    else
         GameConfiguration.SetValue("TurnTooltip."..EventTurn, "Turn Events :[NEWLINE][NEWLINE]"..string)
    end
    local TurnInformation       = {}
    TurnInformation.Name        = "Turn "..EventTurn
    TurnInformation.Tooltip     = GameConfiguration.GetValue("TurnTooltip."..EventTurn) and GameConfiguration.GetValue("TurnTooltip."..EventTurn) or ""
    ResearchBank[EventTurn]     = TurnInformation
    string =  "Turn "..EventTurn..": "..string
    if EventTurn == Game.GetCurrentGameTurn() then
        for i = 1, 10 do
            if GameConfiguration.GetValue("Label".. i .."."..EventTurn.."."..StringType) == string then
                return;
            end
        end
        for i = 10, 2, -1 do
            GameConfiguration.SetValue("Label"..i.."."..EventTurn.."."..StringType, GameConfiguration.GetValue("Label"..i -1 .."."..StringType));
            GameConfiguration.SetValue("Label"..i.."."..StringType, GameConfiguration.GetValue("Label"..i -1 .."."..StringType));
        end
        GameConfiguration.SetValue("Label1."..EventTurn.."."..StringType, string);
        GameConfiguration.SetValue("Label1."..StringType, string);
        if GameConfiguration.GetValue("NumberOfEventThisTurn."..EventTurn.."."..StringType) then
            GameConfiguration.SetValue("NumberOfEventThisTurn."..EventTurn.."."..StringType, GameConfiguration.GetValue("NumberOfEventThisTurn."..EventTurn.."."..StringType) + 1);
        else
            GameConfiguration.SetValue("NumberOfEventThisTurn."..EventTurn.."."..StringType, 1)
        end
    else
        local LastEventTurn = EventTurn
        while not GameConfiguration.GetValue("Label1."..LastEventTurn.."."..StringType) and LastEventTurn > 1 do
            LastEventTurn = LastEventTurn -1
        end
        for i = 1, 10 do
            if GameConfiguration.GetValue("Label".. i .."."..LastEventTurn.."."..StringType) == string then
                return;
            end
        end
        for i = 10, 2, -1 do
            GameConfiguration.SetValue("Label"..i.."."..EventTurn.."."..StringType, GameConfiguration.GetValue("Label"..i -1 .."."..LastEventTurn.."."..StringType));
        end
        GameConfiguration.SetValue("Label1."..EventTurn.."."..StringType, string);
        if GameConfiguration.GetValue("NumberOfEventThisTurn."..EventTurn.."."..StringType) then
            GameConfiguration.SetValue("NumberOfEventThisTurn."..EventTurn.."."..StringType, GameConfiguration.GetValue("NumberOfEventThisTurn."..EventTurn.."."..StringType) + 1);
        else
            GameConfiguration.SetValue("NumberOfEventThisTurn."..EventTurn.."."..StringType, 1)
        end
        
        local labelnumber = 1
        for turn = EventTurn+1, Game.GetCurrentGameTurn() do
            if GameConfiguration.GetValue("NumberOfEventThisTurn."..turn.."."..StringType) and labelnumber < 11 then
                labelnumber = labelnumber + GameConfiguration.GetValue("NumberOfEventThisTurn."..turn.."."..StringType)
                for i = 10, labelnumber + 1, -1 do
                     GameConfiguration.SetValue("Label"..i.."."..turn.."."..StringType, GameConfiguration.GetValue("Label".. i - 1 .."."..turn.."."..StringType));
                end
                GameConfiguration.SetValue("Label"..labelnumber.."."..turn.."."..StringType, string);
            end
        end
        if labelnumber < 11 then
            LastEventTurn = Game.GetCurrentGameTurn()
            while not GameConfiguration.GetValue("Label1."..LastEventTurn.."."..StringType) and LastEventTurn > 1 do
                LastEventTurn = LastEventTurn -1
            end
            
            for i = 10 , 1, -1 do
                GameConfiguration.SetValue("Label"..i.."."..StringType, GameConfiguration.GetValue("Label"..i -1 .."."..LastEventTurn.."."..StringType));
            end
        end
    end
end
function AddTurnEventWhenCan(string, EventTurn, StringType, playerID)
    if GameConfiguration.GetValue("Event."..playerID) then
        GameConfiguration.SetValue( "Event."..playerID,  GameConfiguration.GetValue("Event."..playerID) + 1 )
    else
        GameConfiguration.SetValue( "Event."..playerID, 1 )
    end
    GameConfiguration.SetValue( "Eventstring."..playerID.."."..GameConfiguration.GetValue("Event."..playerID), string)
    GameConfiguration.SetValue( "EventTurn."..playerID.."."..GameConfiguration.GetValue("Event."..playerID), EventTurn)
    GameConfiguration.SetValue( "EventType."..playerID.."."..GameConfiguration.GetValue("Event."..playerID), StringType)
end

function OnDiplomacyMeet(player1ID, player2ID)
    if player1ID == Game.GetLocalPlayer() then
        local playerID = player2ID
        if GameConfiguration.GetValue("Event."..playerID) then
            for i=1, GameConfiguration.GetValue("Event."..playerID) do
                AddTurnEvent(GameConfiguration.GetValue("Eventstring."..playerID.."."..i), GameConfiguration.GetValue("EventTurn."..playerID.."."..i), GameConfiguration.GetValue("EventType."..playerID.."."..i))
            end    
        end
    elseif player2ID == Game.GetLocalPlayer() then
        local playerID = player1ID
        if GameConfiguration.GetValue("Event."..playerID) then
            for i=1, GameConfiguration.GetValue("Event."..playerID) do
                AddTurnEvent(GameConfiguration.GetValue("Eventstring."..playerID.."."..i), GameConfiguration.GetValue("EventTurn."..playerID.."."..i), GameConfiguration.GetValue("EventType."..playerID.."."..i))
            end        
        end
    end
end

--=======================================
--     Events
--=======================================


function OnPlayerDeclareWar(player1ID, player2ID)
    if Players[player1ID]:IsMajor() then
        local player1Name   = Locale.Lookup(PlayerConfigurations[player1ID]:GetCivilizationDescription());
        local player2Name   = Locale.Lookup(PlayerConfigurations[player2ID]:GetCivilizationDescription());
        local EventTurn     = Game.GetCurrentGameTurn();
        local localplayerdiplomacy = Players[Game.GetLocalPlayer()] and Players[Game.GetLocalPlayer()]:GetDiplomacy() or Players[0]:GetDiplomacy();
        if localplayerdiplomacy:HasMet(player1ID) or localplayerdiplomacy:HasMet(player2ID) or not Players[Game.GetLocalPlayer()] then
            AddTurnEvent(player1Name.." declared war to "..player2Name, EventTurn, TypeGovernment);
        else
            AddTurnEventWhenCan(player1Name.." declared war to "..player2Name, EventTurn, TypeGovernment, player1ID);
            AddTurnEventWhenCan(player1Name.." declared war to "..player2Name, EventTurn, TypeGovernment, player2ID);
        end
    end
end
function OnPlayerMakePeace(player1ID, player2ID)
    if Players[player1ID]:IsMajor() then
        local player1Name   = Locale.Lookup(PlayerConfigurations[player1ID]:GetCivilizationDescription());
        local player2Name   = Locale.Lookup(PlayerConfigurations[player2ID]:GetCivilizationDescription());
        local EventTurn     = Game.GetCurrentGameTurn();
        local localplayerdiplomacy = Players[Game.GetLocalPlayer()] and Players[Game.GetLocalPlayer()]:GetDiplomacy() or Players[0]:GetDiplomacy();
        if localplayerdiplomacy:HasMet(player1ID) or localplayerdiplomacy:HasMet(player2ID) or Players[Game.GetLocalPlayer()] then
            AddTurnEvent(player1Name.." has signed a peace treaty with "..player2Name, EventTurn, TypeGovernment);
        else
            AddTurnEventWhenCan(player1Name.." has signed a peace treaty with "..player2Name, EventTurn, TypeGovernment, player1ID);
            AddTurnEventWhenCan(player1Name.." has signed a peace treaty with "..player2Name, EventTurn, TypeGovernment, player2ID);
        end
    end    
end
function OnGovernmentChanged( playerID:number )
    if Players[playerID]:IsMajor() then
        local GovernmentName    = Locale.Lookup(GameInfo.Governments[Players[playerID]:GetCulture():GetCurrentGovernment()].Name);
        local playerName        = Locale.Lookup(PlayerConfigurations[playerID]:GetCivilizationDescription());
        local EventTurn         = Game.GetCurrentGameTurn();
        if not Players[Game.GetLocalPlayer()] or Game.GetLocalPlayer() == playerID or Players[Game.GetLocalPlayer()]:GetDiplomacy():HasMet(playerID) then
            AddTurnEvent(playerName.." has adopted a new Government: "..GovernmentName, EventTurn, TypeGovernment);
        else
            AddTurnEventWhenCan(playerName.." has adopted a new Government: "..GovernmentName, EventTurn, TypeGovernment, playerID);
        end
    end
end
function OnUnitActivate(owner, unitID, x, y, eReason, bVisibleToLocalPlayer)
    if (eReason == EventSubTypes.FOUND_CITY) then
        local cityKey           = x.."."..y;
        GameConfiguration.SetValue(cityKey.."OriginalOwner", owner)
    end
end
function OnCityAddedToMap(owner: number, cityID : number, cityX : number, cityY : number)
    local pCity             = CityManager.GetCity(owner, cityID);
    local cityKey           = cityX.."."..cityY;
    local CityOldOwner      = GameConfiguration.GetValue(cityKey.."CurrentOwner")
    if not GameConfiguration.GetValue(cityKey.."OriginalOwner") then
        GameConfiguration.SetValue(cityKey.."OriginalOwner", pCity:GetOriginalOwner())
    end
    if not CityOldOwner then
        CityOldOwner = GameConfiguration.GetValue(cityKey.."OriginalOwner")
    end
    if type(CityOldOwner) ~= "number" then
        CityOldOwner = 0;
    end
    local CityOldOwnerName  = Locale.Lookup(PlayerConfigurations[CityOldOwner]:GetCivilizationDescription());
    local CityNewOwnerName  = Locale.Lookup(PlayerConfigurations[owner]:GetCivilizationDescription());
    local CityName          = Locale.Lookup(pCity:GetName())
    local OriginalOwner     = GameConfiguration.GetValue(cityKey.."OriginalOwner")
    
    if CityOldOwner ~= OriginalOwner then
        local i = 2
        local alreadyIn = false
        while GameConfiguration.GetValue(cityKey.."OldOwner"..i) and not alreadyIn do
            if GameConfiguration.GetValue(cityKey.."OldOwner"..i) == CityOldOwner then
                alreadyIn = true
            else
                i = i +1
            end
        end
        if not alreadyIn then
            GameConfiguration.SetValue(cityKey.."OldOwner"..i, CityOldOwner)
        end
    end
    if CityOldOwner ~= owner then
        local EventTurn  = Game.GetCurrentGameTurn();
        local Reconquest = false
        if OriginalOwner == owner then
            Reconquest = true
        else
            local i = 2
            while GameConfiguration.GetValue(cityKey.."OldOwner"..i) do
                if owner == GameConfiguration.GetValue(cityKey.."OldOwner"..i) then
                    Reconquest = true
                end
                i = i + 1
            end
        end
        local text = ""
        if Reconquest then
            text = CityNewOwnerName.." reconquered "..CityName.." belonging to the "..CityOldOwnerName
        else
            text = CityNewOwnerName.." conquered "..CityName.." belonging to the "..CityOldOwnerName
        end
        local localplayerdiplomacy = Players[Game.GetLocalPlayer()] and Players[Game.GetLocalPlayer()]:GetDiplomacy() or Players[0]:GetDiplomacy();
        if not Players[Game.GetLocalPlayer()] or localplayerdiplomacy:HasMet(owner) or localplayerdiplomacy:HasMet(CityOldOwner) then
            AddTurnEvent( text, EventTurn, TypeGovernment);
        else
            AddTurnEventWhenCan( text, EventTurn, TypeGovernment, owner );
            AddTurnEventWhenCan( text, EventTurn, TypeGovernment, CityOldOwner );
        end
        GameConfiguration.SetValue("CityOldOwner"..cityKey, CityOldOwner)
        if GameConfiguration.GetValue("checkIfRazed") > 0 and GameConfiguration.GetValue("checkIfRazedx"..GameConfiguration.GetValue("checkIfRazed")) == cityX and  GameConfiguration.GetValue("checkIfRazedy"..GameConfiguration.GetValue("checkIfRazed")) == cityY then
            GameConfiguration.SetValue("checkIfRazed", GameConfiguration.GetValue("checkIfRazed") -1 ) 
        end
    end
    GameConfiguration.SetValue(cityKey.."CurrentOwner", owner)
    GameConfiguration.SetValue( owner..".x."..pCity:GetID(), cityX)
    GameConfiguration.SetValue( owner..".y."..pCity:GetID(), cityY)
    GameConfiguration.SetValue("CityName"..cityKey, Locale.Lookup(pCity:GetName()))
end
function OnPlayerDefeat(player1ID:number, player2ID:number)
    local EventTurn             = Game.GetCurrentGameTurn();
    local player1Name           = Locale.Lookup(PlayerConfigurations[player1ID]:GetCivilizationDescription());
    local player2Name           = Locale.Lookup(PlayerConfigurations[player2ID]:GetCivilizationDescription());
    local text                  = player1Name.." has been defeated by "..player2Name;
    local localplayerdiplomacy  = Players[Game.GetLocalPlayer()] and Players[Game.GetLocalPlayer()]:GetDiplomacy() or Players[0]:GetDiplomacy();
    if not Players[Game.GetLocalPlayer()] or localplayerdiplomacy:HasMet(player2ID) or localplayerdiplomacy:HasMet(player1ID) then
        AddTurnEvent( text, EventTurn, TypeGovernment);
    else
        AddTurnEventWhenCan( text, EventTurn, TypeGovernment, player2ID );
        AddTurnEventWhenCan( text, EventTurn, TypeGovernment, player1ID );
    end
end
function OnCityNameChanged( playerID: number, cityID : number )
    local pCity             = CityManager.GetCity(playerID, cityID);
    local cityKey           = pCity:GetX().."."..pCity:GetY();
    GameConfiguration.SetValue("CityName"..cityKey, Locale.Lookup(pCity:GetName()))
end
function OnCityRemovedFromMap( playerID: number, cityID : number )
    
    
    if not GameConfiguration.GetValue("checkIfRazed") then
        GameConfiguration.SetValue("checkIfRazed", 0 )
    end
    GameConfiguration.SetValue("checkIfRazed", GameConfiguration.GetValue("checkIfRazed") +1 )
    GameConfiguration.SetValue("checkIfRazedx"..GameConfiguration.GetValue("checkIfRazed"), GameConfiguration.GetValue( playerID..".x."..cityID))
    GameConfiguration.SetValue("checkIfRazedy"..GameConfiguration.GetValue("checkIfRazed"), GameConfiguration.GetValue( playerID..".y."..cityID))
    GameConfiguration.SetValue("checkIfRazedplayer"..GameConfiguration.GetValue("checkIfRazed"), playerID ) 
end

function OnReligionFounded(playerID, religionFounded)
    local PlayerName    = Locale.Lookup(PlayerConfigurations[playerID]:GetCivilizationDescription());
    local religionName  = Locale.Lookup(GameInfo.Religions[religionFounded].Name)
    local EventTurn     = Game.GetCurrentGameTurn()
    if not Players[Game.GetLocalPlayer()] or Game.GetLocalPlayer() == playerID or Players[Game.GetLocalPlayer()]:GetDiplomacy():HasMet(playerID) then
        AddTurnEvent(PlayerName.." founded "..religionName, EventTurn, TypeCulture)
    else
        AddTurnEventWhenCan(PlayerName.." founded "..religionName, EventTurn, TypeCulture, playerID)
    end
     GameConfiguration.SetValue("TurnFound"..religionFounded, EventTurn ) 
end
function OnCivicCompleted( playerID:number, civic:number )
    local kTeck = GameInfo.Civics[ civic ]
    local civicName =  Locale.Lookup(kTeck.Name)
    local EraName = Locale.Lookup(GameInfo.Eras[kTeck.EraType].Name);  
    if not GameConfiguration.GetValue(EraName..".AlreadyReachedCivic") and Players[playerID]:IsMajor() then
        local PlayerName    = Locale.Lookup(PlayerConfigurations[playerID]:GetCivilizationDescription());
        local EventTurn     = Game.GetCurrentGameTurn()    
        GameConfiguration.SetValue(EraName..".AlreadyReachedCivic", true)
        if not Players[Game.GetLocalPlayer()] or Game.GetLocalPlayer() == playerID or Players[Game.GetLocalPlayer()]:GetDiplomacy():HasMet(playerID) then 
            AddTurnEvent(PlayerName.." was the first to create a society of the "..EraName.." by institutionalizing "..civicName , EventTurn, TypeCulture)
        else
            AddTurnEventWhenCan(PlayerName.." was the first to create a society of the "..EraName.." by institutionalizing "..civicName , EventTurn, TypeCulture, playerID)
        end
    end   
end


function OnResearchCompleted( playerID:number, iTech:number )
    local kTeck = GameInfo.Technologies[ iTech ]
    local techName =  Locale.Lookup(kTeck.Name)
    if not GameConfiguration.GetValue(techName..".AlreadySearched") and Players[playerID]:IsMajor() then
        local PlayerName    = Locale.Lookup(PlayerConfigurations[playerID]:GetCivilizationDescription());
        local EventTurn     = Game.GetCurrentGameTurn()
        GameConfiguration.SetValue(techName..".AlreadySearched", true)
        if not Players[Game.GetLocalPlayer()] or Game.GetLocalPlayer() == playerID or Players[Game.GetLocalPlayer()]:GetDiplomacy():HasMet(playerID) then 
            AddTurnEvent(PlayerName.." Discovered "..techName, EventTurn, TypeScience)
        else
            AddTurnEventWhenCan(PlayerName.." Discovered "..techName, EventTurn, TypeScience, playerID)
        end
        
        local EraName = Locale.Lookup(GameInfo.Eras[kTeck.EraType].Name);
        if not GameConfiguration.GetValue(EraName..".AlreadyReachedTech") then
            GameConfiguration.SetValue(EraName..".AlreadyReachedTech", true)
            if not Players[Game.GetLocalPlayer()] or Game.GetLocalPlayer() == playerID or Players[Game.GetLocalPlayer()]:GetDiplomacy():HasMet(playerID) then 
                AddTurnEvent(PlayerName.." was the first to reach technologically the "..EraName, EventTurn, TypeScience)
            else
                AddTurnEventWhenCan(PlayerName.." was the first to reach technologically the "..EraName, EventTurn, TypeScience, playerID)
            end
        end
    end
end

function OnWonderCompleted(locX, locY, buildingIndex, playerID, iPercentComplete)
    local EventTurn =  Game.GetCurrentGameTurn()
	local currentBuildingType = GameInfo.Buildings[buildingIndex].BuildingType;
	if currentBuildingType ~= nil then
        local PlayerName = Locale.Lookup(PlayerConfigurations[playerID]:GetCivilizationDescription());
        local Wondername = Locale.Lookup(GameInfo.Buildings[buildingIndex].Name);
        if not Players[Game.GetLocalPlayer()] or Game.GetLocalPlayer() == playerID or Players[Game.GetLocalPlayer()]:GetDiplomacy():HasMet(playerID) then 
            AddTurnEvent(PlayerName.." completed the construction of "..Wondername, EventTurn, TypeCulture)
        else
            AddTurnEventWhenCan(PlayerName.." completed the construction of "..Wondername, EventTurn, TypeCulture, playerID)
        end       
    end
end



--=======================================
--     UI controls
--=======================================

function OnOpenHistoryView()
    if Controls.HistoryView:IsHidden() then
	   Controls.ActivateHistoryMod:SetSelected( true );
       SetHistoryView()
       ContextPtr:LookUpControl("/InGame/TopPanel"):SetHide(true)
	   ContextPtr:LookUpControl("/InGame/DiplomacyRibbon"):SetHide(true)
	   ContextPtr:LookUpControl("/InGame/LaunchBar"):SetHide(true)
	   ContextPtr:LookUpControl("/InGame/PartialScreenHooks"):SetHide(true)
	   ContextPtr:LookUpControl("/InGame/WorldTracker"):SetHide(true)
	   ContextPtr:LookUpControl("/InGame/WorldViewPlotMessages"):SetHide(true)
    
	   ContextPtr:LookUpControl("/InGame/ActionPanel"):SetHide(true)
	   ContextPtr:LookUpControl("/InGame/NotificationPanel"):SetHide(true)
    
	   ContextPtr:LookUpControl("/InGame/MinimapPanel"):SetHide(true)
        
	   ContextPtr:LookUpControl("/InGame/PlotToolTip"):SetHide(true)
        
	   ContextPtr:LookUpControl("/InGame/UnitFlagManager"):SetHide(true)
       ContextPtr:LookUpControl("/InGame/CityBannerManager"):SetHide(true) 
       if Options["SetStrategicViewOnOpen"] then
            UI.SetWorldRenderView( WorldRenderView.VIEW_2D );
       else
            UI.SetWorldRenderView( WorldRenderView.VIEW_3D );
       end
       LuaEvents.InGameTopOptionsMenu_Show();
    end
end
function OnCloseHistoryView()
    if not Controls.HistoryView:IsHidden() then
        Controls.HistoryView:SetHide( true );
	    Controls.ActivateHistoryMod:SetSelected( false );
	    Controls.ActivateHistoryMod:SetHide( Options["HideHistoryViewButton"] );
            
        
        
       ContextPtr:LookUpControl("/InGame/TopPanel"):SetHide(false)
	   ContextPtr:LookUpControl("/InGame/DiplomacyRibbon"):SetHide(false)
	   ContextPtr:LookUpControl("/InGame/LaunchBar"):SetHide(false)
	   ContextPtr:LookUpControl("/InGame/PartialScreenHooks"):SetHide(false)
	   ContextPtr:LookUpControl("/InGame/WorldTracker"):SetHide(false)
	   ContextPtr:LookUpControl("/InGame/WorldViewPlotMessages"):SetHide(false)
    
	   ContextPtr:LookUpControl("/InGame/ActionPanel"):SetHide(false)
	   ContextPtr:LookUpControl("/InGame/NotificationPanel"):SetHide(false)
    
	   ContextPtr:LookUpControl("/InGame/MinimapPanel"):SetHide(false)
        
	   ContextPtr:LookUpControl("/InGame/PlotToolTip"):SetHide(false)
        
       ContextPtr:LookUpControl("/InGame/UnitFlagManager"):SetHide(false)
       ContextPtr:LookUpControl("/InGame/CityBannerManager"):SetHide(false)  
        if Options["SetStrategicViewOnClose"] then
            UI.SetWorldRenderView( WorldRenderView.VIEW_2D );
       else
            UI.SetWorldRenderView( WorldRenderView.VIEW_3D );
       end
       LuaEvents.InGameTopOptionsMenu_Close();
    end
end




function OnRefreshTimeTick()
    CountTimeTick = CountTimeTick + 1
    if PlayingTime or PlayingReverseTime then
        if PlayingTime and playSpeed <= CountTimeTick then
            DisplayNextTurn()
            CountTimeTick = 0
        elseif playSpeed <= CountTimeTick then
            DisplayPreviousTurn()
            CountTimeTick = 0
        end
        Controls.TimeCallback:SetToBeginning();
	    Controls.TimeCallback:Play();
    end
end

function TogglePlayHistory()
    if Controls.PlayPauseButton:IsChecked() then
        PlayingTime = true
        OnRefreshTimeTick()
    else
        StopTimePlaying()
    end
end

function StopTimePlaying()
    PlayingTime         = false
    PlayingReverseTime  = false
    Controls.PlayPauseButton:SetCheck(false)
end

function ChangeSpeed()
    if playSpeed == 1 then
        playSpeed = 8 
        Controls.AcceleratePlay:SetText("x1")
    elseif playSpeed == 8 then
        playSpeed = 4 
        Controls.AcceleratePlay:SetText("x2")
    elseif playSpeed == 4 then
        playSpeed = 2 
        Controls.AcceleratePlay:SetText("x4")
    elseif playSpeed == 2 then
        playSpeed = 1
        Controls.AcceleratePlay:SetText("x8")
    else 
        playSpeed = 8 
        Controls.AcceleratePlay:SetText("x1")
    end
end

function DisplayTurn(Turn, bOnOpen)
    PreviousDisplayedTurn = CurrentDisplayedTurn
    CurrentDisplayedTurn = Turn
    Controls.TurnDisplayedLabel:SetText("Turn "..CurrentDisplayedTurn)
    for _,AllPlotsInfo in pairs(PlotInfoInstances) do
        if bOnOpen then
            local pPlot                   = Map.GetPlotByIndex(AllPlotsInfo.PlotIndex)
            local pLocalPlayerVis:table   = PlayersVisibility[Game.GetLocalPlayer()];
            local locX:number             = pPlot:GetX();
            local locY:number             = pPlot:GetY();
            if not pLocalPlayerVis or pLocalPlayerVis:IsRevealed(locX, locY) then
                AllPlotsInfo.IsVisible              = true
                AllPlotsInfo.IsRevealed             = true
            else
                AllPlotsInfo.IsVisible              = Options["RevealHistoryViewMap"]
                AllPlotsInfo.IsRevealed             = false    
            end
            AllPlotsInfo.m_Instance.OwnerColorButton:SetHide(not AllPlotsInfo.IsVisible)
        end
        
        AllPlotsInfo:SetPlotColorsIcon(CurrentDisplayedTurn)    
    end    
    SetTurnInformations(CurrentDisplayedTurn)
end
function DisplayNextTurn()
    local NextDisplayedTurn    = CurrentDisplayedTurn +1
        if NextDisplayedTurn > Game.GetCurrentGameTurn() -1 then
            if PlayingTime or PlayingReverseTime then
                StopTimePlaying()
                return;
            else
                NextDisplayedTurn = firstTurn 
            end              
        end
    DisplayTurn(NextDisplayedTurn)
end

function DisplayPreviousTurn()
    local NextDisplayedTurn    =  CurrentDisplayedTurn -1  
        if  NextDisplayedTurn < firstTurn then
            if PlayingTime or PlayingReverseTime then
                StopTimePlaying()
                return;
            else
                NextDisplayedTurn = Game.GetCurrentGameTurn() -1
            end  
        end
    DisplayTurn(NextDisplayedTurn)
end


function CollapseGovernment()
    Controls.HideGovernmentAnim:Reverse()
    Controls.CollapseButtonGovernment:SetHide( true );
    Controls.ExpandButtonGovernment:SetHide( false );   
end
function ExpandGovernment()
    Controls.HideGovernmentAnim:Reverse()
    Controls.CollapseButtonGovernment:SetHide( false );
    Controls.ExpandButtonGovernment:SetHide( true );  
end

function CollapseCulture()
    Controls.HideCultureAnim:Reverse()
    Controls.CollapseButtonCulture:SetHide( true );
    Controls.ExpandButtonCulture:SetHide( false );   
end
function ExpandCulture()
    Controls.HideCultureAnim:Reverse()
    Controls.CollapseButtonCulture:SetHide( false );
    Controls.ExpandButtonCulture:SetHide( true );  
end

function CollapseScience()
    Controls.HideScienceAnim:Reverse()
    Controls.CollapseButtonScience:SetHide( true );
    Controls.ExpandButtonScience:SetHide( false );   
end
function ExpandScience()
    Controls.HideScienceAnim:Reverse()
    Controls.CollapseButtonScience:SetHide( false );
    Controls.ExpandButtonScience:SetHide( true );  
end


function KeyDownHandler (uiKey)
    
    if uiKey == Keys.VK_SHIFT then
        isShiftDown = true
    end
    local keyPanChanged = false
    if( uiKey == Keys.VK_UP and not m_isUPpressed ) then
		keyPanChanged = true;
		m_isUPpressed = true;
	end
	if( uiKey == Keys.VK_RIGHT and not m_isRIGHTpressed ) then
		keyPanChanged = true;
		m_isRIGHTpressed = true;
	end
	if( uiKey == Keys.VK_DOWN and not m_isDOWNpressed) then
		keyPanChanged = true;
		m_isDOWNpressed = true;
	end
	if( uiKey == Keys.VK_LEFT and not m_isLEFTpressed) then
		keyPanChanged = true;
		m_isLEFTpressed = true;
	end
    if( keyPanChanged and not Controls.HistoryView:IsHidden() ) then
		ProcessPan(0,0);
	end
    
end
function KeyUpHandler(uiKey)
    
    if uiKey == Keys.VK_SHIFT then
        isShiftDown = false
    end
    
    local keyPanChanged = false
    if uiKey == Keys.R and isShiftDown then
        OnOpenHistoryView()
    end
    if( uiKey == Keys.VK_UP and m_isUPpressed ) then
		m_isUPpressed = false;
		keyPanChanged = true;
	end
	if( uiKey == Keys.VK_RIGHT and m_isRIGHTpressed) then
		m_isRIGHTpressed = false;
		keyPanChanged = true;
	end
	if( uiKey == Keys.VK_DOWN and m_isDOWNpressed) then
		m_isDOWNpressed = false;
		keyPanChanged = true;
	end
	if( uiKey == Keys.VK_LEFT and m_isLEFTpressed) then
		m_isLEFTpressed = false;
		keyPanChanged = true;
	end
	if( keyPanChanged and not Controls.HistoryView:IsHidden() ) then
		ProcessPan(0,0);
	end
end
function OnInputHandler( pInputStruct:table )
	local uiMsg = pInputStruct:GetMessageType();
	if uiMsg == KeyEvents.KeyDown then return KeyDownHandler( pInputStruct:GetKey() ); end
	if uiMsg == KeyEvents.KeyUp then return KeyUpHandler( pInputStruct:GetKey() ); end	
	return false;
end



function OnSearchCharCallback()
	local str = Controls.SearchEditBox:GetText();

	local defaultText = Locale.Lookup("LOC_TREE_SEARCH_W_DOTS")
	if(str == defaultText) then
		-- We cannot immediately clear the results..
		-- When the edit box loses focus, it resets the text which triggers this call back.
		-- if the user is in the process of clicking a result, wiping the results in this callback will make the user
		-- click whatever was underneath.
		-- Instead, trigger a timer will wipe the results.

	elseif(str == nil or #str == 0) then
		-- Clear results.
		m_kSearchResultIM:DestroyInstances();
		Controls.SearchResultsStack:CalculateSize();
		Controls.SearchResultsStack:ReprocessAnchoring();
		Controls.SearchResultsPanel:CalculateSize();
		Controls.SearchResultsPanelContainer:SetHide(true);

	elseif(str and #str > 0) then
		local hasResults = false;
		m_kSearchResultIM:DestroyInstances();
        for Turn, Information in pairs(ResearchBank) do
            if string.find(string.upper(Information.Name), string.upper(str)) or string.find(string.upper(Information.Tooltip), string.upper(str)) then
                hasResults = true
                local instance = m_kSearchResultIM:GetInstance();

				-- Search results already localized.
				local name = Information.Name;
				instance.Name:SetText(name);
                if Information.Icon then
				    local iconName = Information.Icon;
				    instance.SearchIcon:SetIcon(iconName);
                end
                instance.Button:RegisterCallback(Mouse.eLClick, function() 
						Controls.SearchEditBox:SetText(defaultText);
                        DisplayTurn(Turn)
					end);

				instance.Button:SetToolTipString(Information.Tooltip);

            end
        end
		
		Controls.SearchResultsStack:CalculateSize();
		Controls.SearchResultsStack:ReprocessAnchoring();
		Controls.SearchResultsPanel:CalculateSize();
		Controls.SearchResultsPanelContainer:SetHide(not hasResults);
	end
end

function OnSearchBarGainFocus()
	Controls.SearchEditBox:ClearString();
end
function OnSearchBarLoseFocus()
    Controls.SearchEditBox:SetText(Locale.Lookup("LOC_TREE_SEARCH_W_DOTS"));
end

Controls.SearchEditBox:RegisterStringChangedCallback(OnSearchCharCallback);
Controls.SearchEditBox:RegisterHasFocusCallback( OnSearchBarGainFocus);
Controls.SearchEditBox:RegisterCommitCallback( OnSearchBarLoseFocus);

ContextPtr:SetHide(false);
ContextPtr:SetInputHandler( OnInputHandler, true );
-- local textureOffsetX, textureOffsetY, textureSheet = IconManager:FindIconAtlas("ICON_MOVES",22);
-- print(textureOffsetX, textureOffsetY, textureSheet, " everything here")
--	Controls.PlayPauseButton:SetCheckTexture(textureSheet);
--	Controls.PlayPauseButton:SetUnCheckTexture(textureSheet)
--	Controls.PlayPauseButton:SetCheckTextureOffsetVal(textureOffsetX,textureOffsetY);
--	Controls.PlayPauseButton:SetUnCheckTextureOffsetVal(textureOffsetX,textureOffsetY);
function TogglePlayReverseTime()
    Controls.PlayPauseButton:SetCheck(not Controls.PlayPauseButton:IsChecked())
    if Controls.PlayPauseButton:IsChecked() then
        PlayingReverseTime = true
        OnRefreshTimeTick()
    else
        StopTimePlaying()
    end
end
function ReligionToggle()
    if GovernmentFilter then
        GovernmentFilter = false
        Controls.GovernmentToggle:SetCheck(GovernmentFilter)
    end
    ReligionFilter = not ReligionFilter;
    Controls.ReligionToggle:SetCheck(ReligionFilter)
    for _, AllPlotsInfo in pairs(PlotInfoInstances) do
        AllPlotsInfo:SetPlotColorsIcon(CurrentDisplayedTurn, false, true)
    end
    SetLegend(CurrentDisplayedTurn)
end
function GovernmentToggle()
    if ReligionFilter then
        ReligionFilter = false
        Controls.ReligionToggle:SetCheck(ReligionFilter)
    end
    GovernmentFilter = not GovernmentFilter;


    Controls.GovernmentToggle:SetCheck(GovernmentFilter)
    for _, AllPlotsInfo in pairs(PlotInfoInstances) do
        AllPlotsInfo:SetPlotColorsIcon(CurrentDisplayedTurn, false, true)
    end
    SetLegend(CurrentDisplayedTurn)
end
function ToggleHideType(Num)
    DisplayOrder[Num].ShouldHide = not DisplayOrder[Num].ShouldHide
    Controls["RedLine"..Num]:SetHide(not DisplayOrder[Num].ShouldHide)
    Controls["toggleButton"..Num]:SetCheck(DisplayOrder[Num].ShouldHide)
    for _, AllPlotsInfo in pairs(PlotInfoInstances) do
        AllPlotsInfo:SetPlotColorsIcon(CurrentDisplayedTurn, true)
    end
end

function SetIconToHideButton(Num)
    Controls["IcontoggleButton"..Num]:SetIcon(DisplayOrder[Num].IconName)
    Controls["IcontoggleButton"..Num]:SetColor(DisplayOrder[Num].IconColor)
    Controls["toggleButton"..Num]:SetToolTipString(DisplayOrder[Num].IconToolTip)
    Controls["toggleButton"..Num]:SetCheck(DisplayOrder[Num].ShouldHide)
    Controls["RedLine"..Num]:SetHide(not DisplayOrder[Num].ShouldHide)
end

function SwitchButtonOrder(Num)
    local switch            = DisplayOrder[Num]
    DisplayOrder[Num]       = DisplayOrder[Num +1]  
    DisplayOrder[Num +1]    = switch
    
    
    SetIconToHideButton(Num)
    SetIconToHideButton(Num+1)


    for _, AllPlotsInfo in pairs(PlotInfoInstances) do
        AllPlotsInfo:SetPlotColorsIcon(CurrentDisplayedTurn, true)
    end
end



function HideKeyPanel()
    Controls.ShowKeyPanel:SetHide(false)
    Controls.KeyPanel:SetHide(true)
end
function ShowKeyPanel()
    Controls.ShowKeyPanel:SetHide(true)
    Controls.KeyPanel:SetHide(false)
    SetLegend(CurrentDisplayedTurn)
end


function PopulateComboBox(control, values, selected_value, selection_handler, is_locked)

	if (is_locked == nil) then
		is_locked = false;
	end

	control:ClearEntries();
	for i, v in ipairs(values) do
		local instance = {};
		control:BuildEntry( "InstanceOne", instance );
		instance.Button:SetVoid1(i);
        instance.Button:LocalizeAndSetText(v[1]);

		if(v[2] == selected_value) then
			local button = control:GetButton();
            button:LocalizeAndSetText(v[1]);
		end
	end
	control:CalculateInternals();	
		
	control:SetDisabled(is_locked ~= false);

	if(selection_handler) then
		control:RegisterSelectionCallback(
			function(voidValue1, voidValue2, control)
				local option = values[voidValue1];

				local button = control:GetButton();
                button:LocalizeAndSetText(option[1]);
								
				selection_handler(option[2]);
			end
		);
	end
    	
end

function OnLensLayerOff( layerNum:number )
	if layerNum == LensLayers.CULTURAL_IDENTITY_LENS then
		OnShouldShowButton();
	end
end
function OnInterfaceModeChanged (eOldMode:number, eNewMode:number)
    if eNewMode == InterfaceModeTypes.SELECTION then
		 OnShouldShowButton();
    elseif eNewMode == InterfaceModeTypes.SPY_CHOOSE_MISSION then
        --OnShouldHideButton()
    elseif eNewMode == InterfaceModeTypes.SPY_TRAVEL_TO_CITY then
        --OnShouldHideButton()
    elseif eNewMode == InterfaceModeTypes.MAKE_TRADE_ROUTE then
        --OnShouldHideButton()
    elseif eNewMode == InterfaceModeTypes.TELEPORT_TO_CITY then
        --OnShouldHideButton()
	end
end
function OnShouldHideButton ()
    Controls.ActivateHistoryMod:SetHide(true);
end
function OnShouldHideButtonEvenNextTime ()
    Controls.ActivateHistoryMod:SetHide(true);
    bHideNextTime = true
end
function OnShouldShowButton ()
    if not bHideNextTime then
        Controls.ActivateHistoryMod:SetHide( Options["HideHistoryViewButton"] );
    else
        bHideNextTime = false
    end
end

PopulateComboBox(Controls.OrderChoosePullDown, Order_Table, SetOrder, function(option) SetOrder=option; SetLegend(CurrentDisplayedTurn); end )

function ProcessPan(panX, panY)
    
    SpeedX = panX
    SpeedY = panY
	if SpeedX == 0 and SpeedY == 0 then
		if( m_isUPpressed ) then SpeedY = SpeedY + Options.HistoryViewCameraSpeed; end 
		if( m_isDOWNpressed) then SpeedY = SpeedY - Options.HistoryViewCameraSpeed; end
		if( m_isRIGHTpressed ) then SpeedX = SpeedX - Options.HistoryViewCameraSpeed; end
		if( m_isLEFTpressed ) then SpeedX = SpeedX + Options.HistoryViewCameraSpeed; end
	end
    if SpeedX ~= 0 or SpeedY ~= 0 then
        Controls.MoveCameraTimer:SetToBeginning();
        Controls.MoveCameraTimer:Play();
    end
end
function OnMoveCamera()
    if (SpeedX and SpeedX ~= 0) or (SpeedY and SpeedY ~= 0) and not Controls.HistoryView:IsHidden() then
        if isShiftDown then
            xOffset = xOffset + SpeedX*3
            yOffset = yOffset + SpeedY*3
        else
            xOffset = xOffset + SpeedX
            yOffset = yOffset + SpeedY
        end
        Controls.PlotStackUp:SetOffsetVal( xOffset, yOffset);
        Controls.PlotInfoStackTime:SetToBeginning();
        Controls.MoveCameraTimer:Play();
        
    end
end
Controls.MoveCameraTimer:RegisterEndCallback(OnMoveCamera);


function IsAbleToEdgePan()
	return not Controls.HistoryView:IsHidden() and (UserConfiguration.IsEdgePanEnabled() or  m_isMouseButtonRDown) ;
end

-- ===========================================================================
function OnMouseBeginPanLeft()
	if IsAbleToEdgePan() then
		m_edgePanX = Options.HistoryViewCameraSpeed;
		ProcessPan(m_edgePanX,m_edgePanY);
	end
end

function OnMouseStopPanLeft()
	if not ( m_edgePanX == 0.0 and not Controls.HistoryView:IsHidden())  then
		m_edgePanX = 0.0;
		ProcessPan(m_edgePanX,m_edgePanY);
	end
end

function OnMouseBeginPanRight()
	if IsAbleToEdgePan() then
		m_edgePanX = -Options.HistoryViewCameraSpeed;
		ProcessPan(m_edgePanX,m_edgePanY);
	end
end

function OnMouseStopPanRight()
	if not ( m_edgePanX == 0.0 and not Controls.HistoryView:IsHidden()) then
		m_edgePanX = 0;
		ProcessPan(m_edgePanX,m_edgePanY);
	end
end

function OnMouseBeginPanUp()
	if IsAbleToEdgePan() then
		m_edgePanY = Options.HistoryViewCameraSpeed;
		ProcessPan(m_edgePanX,m_edgePanY);
	end
end

function OnMouseStopPanUp()
	if not ( m_edgePanY == 0.0 and not Controls.HistoryView:IsHidden()) then
		m_edgePanY = 0;
		ProcessPan(m_edgePanX,m_edgePanY);
	end
end

function OnMouseBeginPanDown()
	if IsAbleToEdgePan() then
		m_edgePanY = -Options.HistoryViewCameraSpeed;
		ProcessPan(m_edgePanX,m_edgePanY);
	end
end

function OnMouseStopPanDown()
	if not ( m_edgePanY == 0.0 and not Controls.HistoryView:IsHidden()) then
		m_edgePanY = 0;
		ProcessPan(m_edgePanX,m_edgePanY);
	end
end



function OnOpenOptions()
    Controls.HistoryViewOptionPanel:SetHide(false)
    for optionName, value in pairs(Options) do
        if type(value) == "boolean" then
            Controls[optionName]:SetSelected(value)
        else
            Controls[optionName]:SetValue(value/500)
            Controls.OptionValue:SetText(Round(Options[optionName]))
        end
    end
    ModifiedOptions = {}
end
function OnOkButtonPressed()
    for optionName, bModified in pairs(ModifiedOptions) do
        if bModified then
            GameConfiguration.SetValue(optionName, Options[optionName]);
        end
    end
    ModifiedOptions = {}
    Controls.HistoryViewOptionPanel:SetHide(true)
    Controls.OpenOptionButton:SetCheck(false)
end
function OnCancelButtonPressed()
    for optionName, bModified in pairs(ModifiedOptions) do
        if bModified and Options[optionName] ~= GameConfiguration.GetValue(optionName) then
            Options[optionName] = GameConfiguration.GetValue(optionName);
            Controls[optionName]:SetSelected(Options[optionName])
        end
    end
    
    if Options["SetStrategicViewOnOpen"] then
        UI.SetWorldRenderView( WorldRenderView.VIEW_2D );
    else
        UI.SetWorldRenderView( WorldRenderView.VIEW_3D );
    end
    
    for _, AllPlotsInfo in pairs(PlotInfoInstances) do
        if Options["RevealHistoryViewMap"] then
            AllPlotsInfo.IsVisible = true
        else
            AllPlotsInfo.IsVisible = AllPlotsInfo.IsRevealed
        end
        AllPlotsInfo.m_Instance.OwnerColorButton:SetHide(not AllPlotsInfo.IsVisible)
        AllPlotsInfo:SetPlotColorsIcon(CurrentDisplayedTurn, true)
    end
    
    ModifiedOptions = {}
    Controls.HistoryViewOptionPanel:SetHide(true)
    Controls.OpenOptionButton:SetCheck(false)
end


function ToggleSetStrategicViewOnOpen()
    local optionName = "SetStrategicViewOnOpen"
    ModifiedOptions[optionName] = true
    Options[optionName] = not Options[optionName]
    Controls[optionName]:SetSelected(Options[optionName])
    if Options[optionName] then
        UI.SetWorldRenderView( WorldRenderView.VIEW_2D );
    else
        UI.SetWorldRenderView( WorldRenderView.VIEW_3D );
    end
end
function ToggleSetStrategicViewOnClose()   
    local optionName = "SetStrategicViewOnClose"
    ModifiedOptions[optionName] = true
    Options[optionName] = not Options[optionName]
    Controls[optionName]:SetSelected(Options[optionName])
end
function ToggleEndTurnSound()   
    local optionName = "EndTurnSound"
    ModifiedOptions[optionName] = true
    Options[optionName] = not Options[optionName]
    Controls[optionName]:SetSelected(Options[optionName])
end
function ToggleHideHistoryViewButton()   
    local optionName = "HideHistoryViewButton"
    ModifiedOptions[optionName] = true
    Options[optionName] = not Options[optionName]
    Controls[optionName]:SetSelected(Options[optionName])
end
function SetHistoryViewCameraSpeed(Value)    
    local optionName = "HistoryViewCameraSpeed"
    ModifiedOptions[optionName] = true
    Options[optionName] = math.max(Value * 500, 1)
    Controls.OptionValue:SetText(Round(Options[optionName]))
end

function ToggleShowUnitLastTurn()  
    local optionName = "ShowUnitLastTurn"
    ModifiedOptions[optionName] = true
    Options[optionName] = not Options[optionName]
    Controls[optionName]:SetSelected(Options[optionName])
    
    for _, AllPlotsInfo in pairs(PlotInfoInstances) do
        AllPlotsInfo:SetPlotColorsIcon(CurrentDisplayedTurn, true)
    end
end
function ToggleRevealHistoryViewMap()
    local optionName = "RevealHistoryViewMap"
    ModifiedOptions[optionName] = true
    Options[optionName] = not Options[optionName]
    Controls[optionName]:SetSelected(Options[optionName])
    
    for _, AllPlotsInfo in pairs(PlotInfoInstances) do
        if Options[optionName] then
            AllPlotsInfo.IsVisible = true
        else
            AllPlotsInfo.IsVisible = AllPlotsInfo.IsRevealed
        end
        AllPlotsInfo.m_Instance.OwnerColorButton:SetHide(not AllPlotsInfo.IsVisible)
        AllPlotsInfo:SetPlotColorsIcon(CurrentDisplayedTurn, true)
    end
end
function ToggleShowUndiscoveredResource()
    local optionName = "ShowUndiscoveredResource"
    ModifiedOptions[optionName] = true
    Options[optionName] = not Options[optionName]
    Controls[optionName]:SetSelected(Options[optionName])
    
    for _, AllPlotsInfo in pairs(PlotInfoInstances) do
        AllPlotsInfo:SetPlotColorsIcon(CurrentDisplayedTurn, true)
    end
end


function CreateMap()
    local lastY = -1
    local Stackinstance;
    local plotInstanceManager;
    
    for Turn = 0, Game.GetCurrentGameTurn() do
        if GameConfiguration.GetValue("1.Changed."..Turn) then
            if not firstTurn then
                firstTurn = Turn 
            end
        end
        local TurnInformation       = {}
        TurnInformation.Name        = "Turn "..Turn
        TurnInformation.Tooltip     = GameConfiguration.GetValue("TurnTooltip."..Turn);
        if type(TurnInformation.Tooltip) ~= "string" then
            if ResearchBank[Turn -1] then
                TurnInformation.Tooltip = ResearchBank[Turn -1].Tooltip
            else
                TurnInformation.Tooltip = ""
            end
        end
        
        
        ResearchBank[Turn]          = TurnInformation
    end
    if not firstTurn then
        firstTurn = Game.GetCurrentGameTurn() - 1
    end

    
    for plotID = 0, Map.GetPlotCount() -1 do
        local pPlot = Map.GetPlotByIndex(plotID)
        local plotY = pPlot:GetY()
        if lastY ~= plotY then
            lastY = plotY
            local Stackinstance = g_PlotStackInst:GetInstance()
            if plotY% 2 ~= 0 then
                Stackinstance.PlotStack:SetOffsetX(110)
            end
            plotInstanceManager	 = InstanceManager:new( "PlotHistoryInstance",	"PlotContainer", Stackinstance.PlotStack );
        end
    
        local plotInstance = plotInstanceManager:GetInstance()
        PlotInfo:New(pPlot, plotInstance)
    end
end

function GetPlotData(plotID)
    local plotData = {}
    local LastTurnEvent = firstTurn
    for Turn = firstTurn , Game.GetCurrentGameTurn() do
        plotData[Turn] = {}
        if GameConfiguration.GetValue(plotID..".Changed."..Turn) then
            LastTurnEvent                   = Turn
            plotData[Turn].LastTurnEvent    = LastTurnEvent
            for _, key in ipairs(AllPlotInfoKeys) do 
                plotData[Turn][key] = GameConfiguration.GetValue(key.."."..plotID.."."..Turn)
                if (plotData[Turn][key] ~= HistoryTypes[key].DefaultValue ) and type(plotData[Turn][key]) ~= HistoryTypes[key].Datatype then
                    if plotData[Turn -1] then
                        plotData[Turn][key] = plotData[Turn -1][key]
                    else
                        plotData[Turn][key] = HistoryTypes[key].DefaultValue
                    end
                end
            end
        else
            plotData[Turn].LastTurnEvent    = LastTurnEvent
        end
    end
    return plotData;
end
function GetData()
    for Turn = firstTurn , Game.GetCurrentGameTurn() do
        HistoryData.GameData[Turn]  = {}
        
       
        HistoryData.GameData[Turn].GamePopulation = GameConfiguration.GetValue("GamePopulation"..Turn)
        if type(HistoryData.GameData[Turn].GamePopulation) ~= "number" then
            if HistoryData.GameData[Turn -1] then
                HistoryData.GameData[Turn].GamePopulation = HistoryData.GameData[Turn -1].GamePopulation
            else
                HistoryData.GameData[Turn].GamePopulation = 0
            end
        end
        
        HistoryData.GameData[Turn].RealPopulation = GameConfiguration.GetValue("RealPopulation"..Turn)
        if type(HistoryData.GameData[Turn].RealPopulation) ~= "number" then
            if Turn == firstTurn and HistoryData.GameData[Turn].RealPopulation == nil then
                HistoryData.GameData[Turn].RealPopulation = nil
            elseif HistoryData.GameData[Turn -1] then
                HistoryData.GameData[Turn].RealPopulation = HistoryData.GameData[Turn -1].RealPopulation
            else
                HistoryData.GameData[Turn].RealPopulation = 0
            end
        end
        
        HistoryData.GameData[Turn].NumCityFollowingReligion = {}
        for row in GameInfo.Religions() do
            local religionType = row.Index
            HistoryData.GameData[Turn].NumCityFollowingReligion[religionType] = GameConfiguration.GetValue("NumCityFollowingReligion"..religionType.."."..Turn)
            if type(HistoryData.GameData[Turn].NumCityFollowingReligion[religionType]) ~= "number" then
                if HistoryData.GameData[Turn -1] then
                    HistoryData.GameData[Turn].NumCityFollowingReligion[religionType] = HistoryData.GameData[Turn -1].NumCityFollowingReligion[religionType]
                else
                    HistoryData.GameData[Turn].NumCityFollowingReligion[religionType] = 0
                end
            end
        end
        
        HistoryData.GameData[Turn].NumCityFollowingReligion[-1] = GameConfiguration.GetValue("NumCityFollowingReligion".. -1 .."."..Turn)
        if type(HistoryData.GameData[Turn].NumCityFollowingReligion[-1]) ~= "number" then
            if HistoryData.GameData[Turn -1] then
                HistoryData.GameData[Turn].NumCityFollowingReligion[-1] = HistoryData.GameData[Turn -1].NumCityFollowingReligion[-1]
            else
                HistoryData.GameData[Turn].NumCityFollowingReligion[-1] = 0
            end
        end
        local kPlayers	:table = PlayerManager.GetWasEverAlive();
        for _, pPlayer in ipairs(kPlayers) do
            local playerID = pPlayer:GetID()
            if not HistoryData.PlayerData[playerID] then
                HistoryData.PlayerData[playerID] = {}
            end
            HistoryData.PlayerData[playerID][Turn] = {}
            for _, key in ipairs(playerDataKeys) do
                HistoryData.PlayerData[playerID][Turn][key] = GameConfiguration.GetValue(key..".playerID."..playerID..".Turn."..Turn)
                if type(HistoryData.PlayerData[playerID][Turn][key]) ~= HistoryTypes[key].Datatype then
                    if HistoryData.PlayerData[playerID][Turn - 1] then
                        HistoryData.PlayerData[playerID][Turn][key] = HistoryData.PlayerData[playerID][Turn - 1][key]
                    else
                        HistoryData.PlayerData[playerID][Turn][key] = HistoryTypes[key].DefaultValue
                    end
                end
            end
            if type(HistoryData.PlayerData[playerID][Turn].TotalPlayerUnitTurn) == "number" then
                for i = 1, HistoryData.PlayerData[playerID][Turn].TotalPlayerUnitTurn do
                    HistoryData.PlayerData[playerID][Turn]["Typeof."..i] = GameConfiguration.GetValue("Typeof."..i..".playerID."..playerID..".Turn."..Turn)
                    if type(HistoryData.PlayerData[playerID][Turn]["Typeof."..i]) ~= "number" then
                        if HistoryData.PlayerData[playerID][Turn - 1] then
                            HistoryData.PlayerData[playerID][Turn]["Typeof."..i] = HistoryData.PlayerData[playerID][Turn - 1]["Typeof."..i]
                        else
                            HistoryData.PlayerData[playerID][Turn]["Typeof."..i] = 1
                        end
                    end
                end
            end
            for _, pPlayer2 in ipairs(kPlayers) do
                local enemyID = pPlayer2:GetID()
                if  GameConfiguration.GetValue("WasAtWarWith."..enemyID..".playerID."..playerID..".Turn."..Turn) and ( GameConfiguration.GetValue("WasAtWarWith."..enemyID..".playerID."..playerID..".Turn."..Turn +1) or GameConfiguration.GetValue("WasAtWarWith."..enemyID..".playerID."..playerID..".Turn."..Turn -1)) then
                    HistoryData.PlayerData[playerID][Turn]["WasAtWarWith."..enemyID] = GameConfiguration.GetValue("WasAtWarWith."..enemyID..".playerID."..playerID..".Turn."..Turn)
                elseif  GameConfiguration.GetValue("WasAtWarWith."..enemyID..".playerID."..playerID..".Turn."..Turn) then
                     GameConfiguration.SetValue("WasAtWarWith."..enemyID..".playerID."..playerID..".Turn."..Turn, false)
                end
            end
        end
        
    end
end

function Initialize()
    
    Controls.PlayPauseButton:RegisterCallback( Mouse.eLClick, TogglePlayHistory );
    Controls.PlayPauseButton:RegisterCallback( Mouse.eRClick, TogglePlayReverseTime );

    Controls.AcceleratePlay:RegisterCallback( Mouse.eLClick, ChangeSpeed );


    Controls.ActivateHistoryMod:RegisterCallback( Mouse.eLClick, OnOpenHistoryView );
    Controls.CloseButton:RegisterCallback( Mouse.eLClick, OnCloseHistoryView );


    Controls.ReligionToggle:RegisterCallback( Mouse.eLClick, ReligionToggle );
    Controls.GovernmentToggle:RegisterCallback( Mouse.eLClick, GovernmentToggle );


    Controls.toggleButton1:RegisterCallback( Mouse.eLClick, function() ToggleHideType(1) end );
    Controls.toggleButton2:RegisterCallback( Mouse.eLClick, function() ToggleHideType(2) end );
    Controls.toggleButton3:RegisterCallback( Mouse.eLClick, function() ToggleHideType(3) end );
    Controls.toggleButton4:RegisterCallback( Mouse.eLClick, function() ToggleHideType(4) end );
    Controls.toggleButton5:RegisterCallback( Mouse.eLClick, function() ToggleHideType(5) end );
    Controls.toggleButton6:RegisterCallback( Mouse.eLClick, function() ToggleHideType(6) end );

    Controls.SwitchOrder1:RegisterCallback( Mouse.eLClick, function() SwitchButtonOrder(1) end );
    Controls.SwitchOrder2:RegisterCallback( Mouse.eLClick, function() SwitchButtonOrder(2) end );
    Controls.SwitchOrder3:RegisterCallback( Mouse.eLClick, function() SwitchButtonOrder(3) end );
    Controls.SwitchOrder4:RegisterCallback( Mouse.eLClick, function() SwitchButtonOrder(4) end );
    Controls.SwitchOrder5:RegisterCallback( Mouse.eLClick, function() SwitchButtonOrder(5) end );




    Controls.RightArrow:RegisterCallback( Mouse.eLClick, DisplayNextTurn );
    Controls.LeftArrow:RegisterCallback( Mouse.eLClick, DisplayPreviousTurn );


    Controls.CollapseButtonGovernment:RegisterCallback( Mouse.eLClick, CollapseGovernment );
    Controls.ExpandButtonGovernment:RegisterCallback( Mouse.eLClick, ExpandGovernment );

    Controls.CollapseButtonCulture:RegisterCallback( Mouse.eLClick, CollapseCulture );
    Controls.ExpandButtonCulture:RegisterCallback( Mouse.eLClick, ExpandCulture );

    Controls.CollapseButtonScience:RegisterCallback( Mouse.eLClick, CollapseScience );
    Controls.ExpandButtonScience:RegisterCallback( Mouse.eLClick, ExpandScience );
    
    
    Controls.HideKeyPanel:RegisterCallback( Mouse.eLClick, HideKeyPanel );
    Controls.ShowKeyPanel:RegisterCallback( Mouse.eLClick, ShowKeyPanel );

    Controls.TimeCallback:RegisterEndCallback(OnRefreshTimeTick);

    
    Controls.LeftScreenEdge:RegisterMouseEnterCallback(     OnMouseBeginPanLeft );
    Controls.LeftScreenEdge:RegisterMouseExitCallback(      OnMouseStopPanLeft );
    Controls.RightScreenEdge:RegisterMouseEnterCallback(    OnMouseBeginPanRight );
    Controls.RightScreenEdge:RegisterMouseExitCallback(     OnMouseStopPanRight );
    Controls.TopScreenEdge:RegisterMouseEnterCallback(      OnMouseBeginPanUp );
    Controls.TopScreenEdge:RegisterMouseExitCallback(       OnMouseStopPanUp );
    Controls.BottomScreenEdge:RegisterMouseEnterCallback(   OnMouseBeginPanDown );  
    Controls.BottomScreenEdge:RegisterMouseExitCallback(    OnMouseStopPanDown );


    GameEvents.OnGameTurnStarted.Add( GetTurnInformations );


    Events.DiplomacyMeet.Add( OnDiplomacyMeet );


    Events.DiplomacyDeclareWar.Add(	                    OnPlayerDeclareWar );
    Events.DiplomacyMakePeace.Add(                      OnPlayerMakePeace );
    Events.GovernmentChanged.Add(                       OnGovernmentChanged );
    Events.UnitActivate.Add(                            OnUnitActivate );
    Events.CityAddedToMap.Add(					        OnCityAddedToMap );
    Events.CityNameChanged.Add(			                OnCityNameChanged );
    Events.CityRemovedFromMap.Add(				        OnCityRemovedFromMap );

    Controls.PlotInfoStackTime:RegisterEndCallback(OnPlotInfoStackTimeEnd);


    Events.ReligionFounded.Add(                         OnReligionFounded );
    Events.CivicCompleted.Add(                          OnCivicCompleted );
    Events.ResearchCompleted.Add(                       OnResearchCompleted);
    Events.WonderCompleted.Add(                         OnWonderCompleted );

    --LuaEvents.TechTree_OpenTechTree.Add(                            OnShouldHideButton);
    --LuaEvents.CivicsTree_OpenCivicsTree.Add(                        OnShouldHideButton);
    --LuaEvents.Government_OpenGovernment.Add(                        OnShouldHideButton);
    --LuaEvents.GreatPeople_OpenGreatPeople.Add(                      OnShouldHideButton);
    --LuaEvents.GovernorPanel_Opened.Add(                             OnShouldHideButton);
    --LuaEvents.GovernorPanel_Open.Add(                               OnShouldHideButton);
    --LuaEvents.HistoricMoments_Opened.Add(                           OnShouldHideButton);
    --LuaEvents.GovernorAssignmentChooser_RequestAssignment.Add(      OnShouldHideButtonEvenNextTime);
    --LuaEvents.ActionPanel_OpenChooseCivic.Add(                      OnShouldHideButton);
    --LuaEvents.WorldTracker_OpenChooseCivic.Add(                     OnShouldHideButton);
    --LuaEvents.ActionPanel_OpenChooseResearch.Add(                   OnShouldHideButton);
    --LuaEvents.WorldTracker_OpenChooseResearch.Add(                  OnShouldHideButton);
    LuaEvents.DiplomacyActionView_HideIngameUI.Add(                 OnShouldHideButton);


    --LuaEvents.TechTree_CloseTechTree.Add(                           OnShouldShowButton);
    --LuaEvents.CivicsTree_CloseCivicsTree.Add(                       OnShouldShowButton);
    --LuaEvents.Government_CloseGovernment.Add(                       OnShouldShowButton);
    --LuaEvents.GreatPeople_CloseGreatPeople.Add(                     OnShouldShowButton);
    --LuaEvents.GovernorPanel_Closed.Add(                             OnShouldShowButton);
    --LuaEvents.GovernorPanel_Close.Add(                              OnShouldHideButton);
    --LuaEvents.HistoricMoments_Closed.Add(                           OnShouldShowButton);
    --LuaEvents.LaunchBar_CloseChoosers.Add(                          OnShouldShowButton);
    LuaEvents.DiplomacyActionView_ShowIngameUI.Add(                 OnShouldShowButton);


    --LuaEvents.CityPanel_ShowOverviewPanel.Add(                      function(bool) if bool then OnShouldHideButton() else OnShouldShowButton() end end);
    Events.InterfaceModeChanged.Add(                                OnInterfaceModeChanged );
    --Events.LensLayerOff.Add(					                    OnLensLayerOff );
    
    
    
    Controls.OpenOptionButton:RegisterCallback( Mouse.eLClick,          OnOpenOptions) 

    Controls.OkButton:RegisterCallback( Mouse.eLClick,                  OnOkButtonPressed) 
    Controls.CancelButton:RegisterCallback( Mouse.eLClick,              OnCancelButtonPressed) 

    Controls.SetStrategicViewOnOpen:RegisterCallback( Mouse.eLClick,    ToggleSetStrategicViewOnOpen)
    Controls.SetStrategicViewOnClose:RegisterCallback( Mouse.eLClick,   ToggleSetStrategicViewOnClose)
    Controls.EndTurnSound:RegisterCallback( Mouse.eLClick,              ToggleEndTurnSound)
    Controls.HideHistoryViewButton:RegisterCallback( Mouse.eLClick,     ToggleHideHistoryViewButton)
    Controls.HistoryViewCameraSpeed:RegisterSliderCallback(             SetHistoryViewCameraSpeed)
    
    if GameConfiguration.IsAnyMultiplayer() then
        Controls.CheatStack:SetHide(true)
    else
        Controls.ShowUnitLastTurn:RegisterCallback( Mouse.eLClick,          ToggleShowUnitLastTurn)
        Controls.RevealHistoryViewMap:RegisterCallback( Mouse.eLClick,      ToggleRevealHistoryViewMap)
        Controls.ShowUndiscoveredResource:RegisterCallback( Mouse.eLClick,  ToggleShowUndiscoveredResource)
    end

    
    CreateMap()
    GetData()
    
end

Initialize()









