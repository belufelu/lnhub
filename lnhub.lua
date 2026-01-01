local Repository = "https://raw.githubusercontent.com/RectangularObject/LinoriaLib/main/"

local Library = loadstring(game:HttpGet(Repository .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(Repository .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(Repository .. "addons/SaveManager.lua"))()

-- Сначала определяем ESP переменные из оригинального скрипта
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local GameData = ReplicatedStorage.GameData
local LatestRoom = GameData.LatestRoom
local Floor = GameData.Floor

-- ESP переменные из оригинального скрипта
local ItemESP = false
local EntityESP = false
local OtherESP = false
local ESP_Items = {
    KeyObtain={"Key",1.5},
    LiveHintBook={"Book",1.5},
    Lighter={"Lighter",1.5},
    Lockpick={"Lockpicks",1.5},
    Vitamins={"Vitamins",1.5},
    Crucifix={"Crucifix",1.5},
    CrucifixWall={"Crucifix",1.5},
    SkeletonKey={"Skeleton Key",1.5},
    Flashlight={"Flashlight",1.5},
    Candle={"Candle",1.5},
    LiveBreakerPolePickup={"Fuse",1.5},
    Shears={"Shears",1.5},
    Battery={"Battery",1.5},
    PickupItem={"Paper",1.5},
    ElectricalKeyObtain={"Electrical Key",1.5},
    Shakelight={"Shakelight",1.5},
    Scanner={"iPad",1.5}
}

local ESP_Entities = {
    RushMoving={"Rush",5},
    AmbushMoving={"Ambush",5},
    FigureRagdoll={"Figure",7},
    FigureLibrary={"Figure",7},
    SeekMoving={"Seek",5.5},
    Screech={"Screech",2},
    Eyes={"Eyes",4},
    Snare={"Snare",2},
    A60={"A-60",10},
    A120={"A-120",10}
}

local ESP_Other = {
    Door={"Door",5},
    LeverForGate={"Lever",3},
    GoldPile={"Gold",0.5},
    Bandage={"Bandage",0.5}
}

local DisableSnare = false

-- Функция для применения/удаления защиты от Snare
local function applySnareProtection()
    -- Применяем ко всем существующим Snare
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name == "Snare" then
            local hitbox = obj:FindFirstChild("Hitbox")
            if hitbox then
                hitbox.CanTouch = not DisableSnare
            end
        end
    end
    
    -- Отслеживаем новые Snare
    workspace.DescendantAdded:Connect(function(obj)
        if obj.Name == "Snare" then
            task.wait(0.1)
            local hitbox = obj:FindFirstChild("Hitbox")
            if hitbox then
                hitbox.CanTouch = not DisableSnare
            end
        end
    end)
end

-- Функция ApplySettings из оригинального скрипта (точная копия)
local function ApplySettings(Object)
    task.spawn(function()
        task.wait()
        if (ESP_Items[Object.Name] or ESP_Entities[Object.Name] or ESP_Other[Object.Name]) and Object.ClassName == "Model" then
            if Object:FindFirstChild("RushNew") then
                if not Object.RushNew:WaitForChild("PlaySound").Playing then return end
            end
            -- Правильные цвета из оригинального скрипта
            local Color = ESP_Items[Object.Name] and Color3.new(1,1,0) or ESP_Entities[Object.Name] and Color3.new(1,0,0) or Color3.new(0,1,1)
            
            if Object.Name == "RushMoving" or Object.Name == "AmbushMoving" or Object.Name == "Eyes" or Object.Name == "A60" or Object.Name == "A120" then
                for i = 1, 100 do
                    if Object:FindFirstChildOfClass("Part") then
                        break
                    end
                    if i == 100 then
                        return
                    end
                end
                if Object:FindFirstChildOfClass("Part") then
                    Object:FindFirstChildOfClass("Part").Transparency = 0.99
                end
                if not Object:FindFirstChild("Humanoid") then
                    Instance.new("Humanoid",Object)
                end
            end
            
            local function ApplyHighlight(IsValid,Bool)
                if IsValid then
                    if Bool then
                        local TXT = IsValid[1]
                        if IsValid[1] == "Door" then
                            local RoomName
                            if Floor.Value == "Rooms" then
                                RoomName = ""
                            else
                                local nextRoomNum = tonumber(Object.Parent.Name)
                                if nextRoomNum then
                                    nextRoomNum = nextRoomNum + 1
                                    local nextRoom = workspace.CurrentRooms:FindFirstChild(tostring(nextRoomNum))
                                    if nextRoom then
                                        local originalName = nextRoom:GetAttribute("OriginalName")
                                        if originalName then
                                            local OldString = originalName:sub(7,99)
                                            local NewString = ""
                                            for i = 1, #OldString do
                                                if i == 1 then
                                                    NewString = NewString .. OldString:sub(i,i)
                                                    continue
                                                end
                                                if OldString:sub(i,i) == OldString:sub(i,i):upper() and OldString:sub(i-1,i-1) ~= "_" then
                                                    NewString = NewString .. " "
                                                end
                                                if OldString:sub(i,i) ~= "_" then
                                                    NewString = NewString .. OldString:sub(i,i)
                                                end
                                            end
                                            RoomName = " (" .. NewString .. ")"
                                        end
                                    end
                                end
                            end
                            TXT = "Door " .. (Floor.Value == "Rooms" and "A-" or "") .. (tonumber(Object.Parent.Name) or 0) + 1 .. (RoomName or "")
                        end
                        if IsValid[1] == "Gold" then
                            local goldValue = Object:GetAttribute("GoldValue")
                            if goldValue then
                                TXT = goldValue .. " Gold"
                            end
                        end
                        local UI = Instance.new("BillboardGui",Object)
                        UI.Size = UDim2.new(0,1000,0,30)
                        UI.AlwaysOnTop = true
                        UI.StudsOffset = Vector3.new(0,IsValid[2],0)
                        local Label = Instance.new("TextLabel",UI)
                        Label.Size = UDim2.new(1,0,1,0)
                        Label.BackgroundTransparency = 1
                        Label.TextScaled = true
                        Label.Text = TXT
                        Label.TextColor3 = Color
                        Label.FontFace = Font.new("rbxasset://fonts/families/Oswald.json")
                        Label.TextStrokeTransparency = 0
                        Label.TextStrokeColor3 = Color3.new(Color.R/2,Color.G/2,Color.B/2)
                    elseif Object:FindFirstChild("BillboardGui") then
                        Object.BillboardGui:Destroy()
                    end
                    local Target = Object
                    if IsValid[1] == "Door" and Object.Parent and Object.Parent.Name ~= "49" and Object.Parent.Name ~= "50" then
                        Target = Object:WaitForChild("Door") or Object
                    end
                    if Bool then
                        local Highlight = Instance.new("Highlight",Target)
                        Highlight.FillColor = Color
                        Highlight.OutlineColor = Color
                    elseif Target:FindFirstChild("Highlight") then
                        Target.Highlight:Destroy()
                    end
                end
            end
            
            ApplyHighlight(ESP_Items[Object.Name],ItemESP)
            ApplyHighlight(ESP_Entities[Object.Name],EntityESP)
            ApplyHighlight(ESP_Other[Object.Name],OtherESP)
        end
    end)
end

-- Обработчик для новых объектов
workspace.DescendantAdded:Connect(ApplySettings)

Library:Notify("LNHUB - (v1) DOORS | Loading Functions...", nil, 4590657391)

local plr = game.Players.LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()
local hum = char:FindFirstChildOfClass("Humanoid") or char:WaitForChild("Humanoid")

-- Оригинальная ESP функция (оставляем для совместимости)
function esp(what,color,core,name)
    local parts
    
    if typeof(what) == "Instance" then
        if what:IsA("Model") then
            parts = what:GetChildren()
        elseif what:IsA("BasePart") then
            parts = {what,table.unpack(what:GetChildren())}
        end
    elseif typeof(what) == "table" then
        parts = what
    end
    
    local bill
    local boxes = {}
    
    for i,v in pairs(parts) do
        if v:IsA("BasePart") then
            local box = Instance.new("BoxHandleAdornment")
            box.Size = v.Size
            box.AlwaysOnTop = true
            box.ZIndex = 1
            box.AdornCullingMode = Enum.AdornCullingMode.Never
            box.Color3 = color
            box.Transparency = 0.7
            box.Adornee = v
            box.Parent = game.CoreGui
            
            table.insert(boxes,box)
            
            task.spawn(function()
                while box do
                    if box.Adornee == nil or not box.Adornee:IsDescendantOf(workspace) then
                        box.Adornee = nil
                        box.Visible = false
                        box:Destroy()
                    end  
                    task.wait()
                end
            end)
        end
    end
    
    if core and name then
        bill = Instance.new("BillboardGui",game.CoreGui)
        bill.AlwaysOnTop = true
        bill.Size = UDim2.new(0,400,0,100)
        bill.Adornee = core
        bill.MaxDistance = 2000
        
        local mid = Instance.new("Frame",bill)
        mid.AnchorPoint = Vector2.new(0.5,0.5)
        mid.BackgroundColor3 = color
        mid.Size = UDim2.new(0,8,0,8)
        mid.Position = UDim2.new(0.5,0,0.5,0)
        Instance.new("UICorner",mid).CornerRadius = UDim.new(1,0)
        Instance.new("UIStroke",mid)
        
        local txt = Instance.new("TextLabel",bill)
        txt.AnchorPoint = Vector2.new(0.5,0.5)
        txt.BackgroundTransparency = 1
        txt.BackgroundColor3 = color
        txt.TextColor3 = color
        txt.Size = UDim2.new(1,0,0,20)
        txt.Position = UDim2.new(0.5,0,0.7,0)
        txt.Text = name
        Instance.new("UIStroke",txt)
        
        task.spawn(function()
            while bill do
                if bill.Adornee == nil or not bill.Adornee:IsDescendantOf(workspace) then
                    bill.Enabled = false
                    bill.Adornee = nil
                    bill:Destroy() 
                end  
                task.wait()
            end
        end)
    end
    
    local ret = {}
    
    ret.delete = function()
        for i,v in pairs(boxes) do
            v.Adornee = nil
            v.Visible = false
            v:Destroy()
        end
        
        if bill then
            bill.Enabled = false
            bill.Adornee = nil
            bill:Destroy() 
        end
    end
    
    return ret 
end

local flags = {
    speed = 16,
    espdoors = false,
    espkeys = false,
    espitems = false,
    espbooks = false,
    esprush = false,
    espchest = false,
    esplocker = false,
    esphumans = false,
    espgold = false,
    goldespvalue = 25,
    hintrush = false,
    light = false,
    instapp = false,
    noseek = false,
    nogates = false,
    nopuzzle = false,
    noa90 = false,
    noskeledoors = false,
    noscreech = false,
    getcode = false,
    roomsnolock = false,
    draweraura = false,
    autorooms = false,
}

local esptable = {doors={},keys={},items={},books={},entity={},chests={},lockers={},people={},gold={}}
local entitynames = {"RushMoving","AmbushMoving","Snare","A60","A120"}

Library:Notify("LNHUB - (v1) DOORS | Loading GUI...", nil, 4590657391)
Library:Notify("LNHUB - (v1) DOORS | Loading Utilites & ESP...", nil, 4590657391)
local NotificationHolder = loadstring(game:HttpGet("https://raw.githubusercontent.com/BocusLuke/UI/main/STX/Module.Lua"))()
local Notification = loadstring(game:HttpGet("https://raw.githubusercontent.com/BocusLuke/UI/main/STX/Client.Lua"))()

Library:Notify("LNHUB - (v1) DOORS | Script Loaded!", nil, 4590657391)
local Window = Library:CreateWindow({
    Title = 'LNHUB - (v1)',
    Center = true,
    AutoShow = true,
    TabPadding = 5,
    MenuFadeTime = 0.2
})

local Tabs = {
    Main = Window:AddTab('Main'),
    Player = Window:AddTab('Player'),
    Cheats = Window:AddTab('Cheats'),
    Visuals = Window:AddTab('Visuals'),
    Floors = Window:AddTab('Floors'),
    ['Configs'] = Window:AddTab('Configs'),
}

local TabBox = Tabs.Main:AddLeftTabbox()
local AutoTab = TabBox:AddTab('Auto')
AutoTab:AddToggle('', {
    Text = 'Auto Library Code',
    Default = false,
    Callback = function(Value)
        flags.getcode = Value
        
        if Value then
            local function deciphercode()
                local paper = char:FindFirstChild("LibraryHintPaper")
                local hints = plr.PlayerGui:WaitForChild("PermUI"):WaitForChild("Hints")
                
                local code = {[1]="_",[2]="_",[3]="_",[4]="_",[5]="_"}
                
                if paper then
                    for i,v in pairs(paper:WaitForChild("UI"):GetChildren()) do
                        if v:IsA("ImageLabel") and v.Name ~= "Image" then
                            for i,img in pairs(hints:GetChildren()) do
                                if img:IsA("ImageLabel") and img.Visible and v.ImageRectOffset == img.ImageRectOffset then
                                    local num = img:FindFirstChild("TextLabel").Text
                                    
                                    code[tonumber(v.Name)] = num 
                                end
                            end
                        end
                    end 
                end
                
                return code
            end
            
            local addconnect
            addconnect = char.ChildAdded:Connect(function(v)
                if v:IsA("Tool") and v.Name == "LibraryHintPaper" then
                    task.wait()
                    
                    local code = table.concat(deciphercode())
                    
                    if code:find("_") then
                        Notification:Notify(
                            {Title = "LNHUB", Description = "Get All Books"},
                            {OutlineColor = Color3.fromRGB(80, 80, 80),Time = 5, Type = "image"},
                            {Image = "http://www.roblox.com/asset/?id=6023426923", ImageColor = Color3.fromRGB(255, 84, 84)}
                        )
                    else
                        Notification:Notify(
                            {Title = "LNHUB", Description = "Library code is: ".. code},
                            {OutlineColor = Color3.fromRGB(80, 80, 80),Time = 5, Type = "image"},
                            {Image = "http://www.roblox.com/asset/?id=6023426923", ImageColor = Color3.fromRGB(255, 84, 84)}
                        )
                    end
                end
            end)
            
            repeat task.wait() until not flags.getcode
            addconnect:Disconnect()
        end
    end
})

local NotifiersTab = TabBox:AddTab('Notifiers')
NotifiersTab:AddToggle('', {
    Text = 'Notify Entity',
    Default = false,
    Callback = function(Value)
        _G.AlertEnabled = Value
        
        if Value then
            setupEntityAlerts()
        else
            if _G.EntityConnection then
                _G.EntityConnection:Disconnect()
                _G.EntityConnection = nil
            end
            if _G.CharConnection then
                _G.CharConnection:Disconnect()
                _G.CharConnection = nil
            end
        end
    end
})

function setupRushAmbushAlerts()
    if not _G.AlertEnabled then return end
    
    if _G.EntityConnection then
        _G.EntityConnection:Disconnect()
    end
    if _G.CharConnection then
        _G.CharConnection:Disconnect()
    end
    
    _G.EntityConnection = game:GetService("Workspace").CurrentRooms.ChildAdded:Connect(function(room)
        if not _G.AlertEnabled then return end
        
        task.wait(0.3)
        
        local rush = room:FindFirstChild("RushMoving")
        if rush then
            Notification:Notify(
                {Title = "LNHUB", Description = "Rush Has Spawned! Find hiding spot!"},
                {OutlineColor = Color3.fromRGB(80, 80, 80),Time = 5, Type = "image"},
                {Image = "http://www.roblox.com/asset/?id=6023426923", ImageColor = Color3.fromRGB(255, 84, 84)}
            )
        end
        
        local ambush = room:FindFirstChild("AmbushMoving")
        if ambush then
            Notification:Notify(
                {Title = "LNHUB", Description = "Ambush Has Spawned! Find hiding spot!"},
                {OutlineColor = Color3.fromRGB(80, 80, 80),Time = 5, Type = "image"},
                {Image = "http://www.roblox.com/asset/?id=6023426923", ImageColor = Color3.fromRGB(255, 84, 84)}
            )
        end
    end)
    
    _G.CharConnection = game:GetService("Workspace").ChildAdded:Connect(function(child)
        if not _G.AlertEnabled then return end
        
        task.wait(0.2)
        
        if child.Name == "RushMoving" or child.Name == "Rush" then
            Notification:Notify(
                {Title = "LNHUB", Description = "Rush Has Spawned! Find hiding spot!"},
                {OutlineColor = Color3.fromRGB(80, 80, 80),Time = 5, Type = "image"},
                {Image = "http://www.roblox.com/asset/?id=6023426923", ImageColor = Color3.fromRGB(255, 84, 84)}
            )
        end
        
        if child.Name == "AmbushMoving" or child.Name == "Ambush" then
            Notification:Notify(
                {Title = "LNHUB", Description = "Ambush Has Spawned! Find hiding spot!"},
                {OutlineColor = Color3.fromRGB(80, 80, 80),Time = 5, Type = "image"},
                {Image = "http://www.roblox.com/asset/?id=6023426923", ImageColor = Color3.fromRGB(255, 84, 84)}
            )
        end
    end)
    
    task.spawn(function()
        task.wait(1)
        if not _G.AlertEnabled then return end
        
        for _, room in pairs(game:GetService("Workspace").CurrentRooms:GetChildren()) do
            if room:FindFirstChild("RushMoving") then
                Notification:Notify(
                    {Title = "LNHUB", Description = "Rush Has Spawned! Find hiding spot!"},
                    {OutlineColor = Color3.fromRGB(80, 80, 80),Time = 5, Type = "image"},
                    {Image = "http://www.roblox.com/asset/?id=6023426923", ImageColor = Color3.fromRGB(255, 84, 84)}
                )
            end
            if room:FindFirstChild("AmbushMoving") then
                Notification:Notify(
                    {Title = "LNHUB", Description = "Ambush Has Spawned! Find hiding spot!"},
                    {OutlineColor = Color3.fromRGB(80, 80, 80),Time = 5, Type = "image"},
                    {Image = "http://www.roblox.com/asset/?id=6023426923", ImageColor = Color3.fromRGB(255, 84, 84)}
                )
            end
        end
        
        if game:GetService("Workspace"):FindFirstChild("RushMoving") or 
           game:GetService("Workspace"):FindFirstChild("Rush") then
            Notification:Notify(
                {Title = "LNHUB", Description = "Rush Has Spawned! Find hiding spot!"},
                {OutlineColor = Color3.fromRGB(80, 80, 80),Time = 5, Type = "image"},
                {Image = "http://www.roblox.com/asset/?id=6023426923", ImageColor = Color3.fromRGB(255, 84, 84)}
            )
        end
        
        if game:GetService("Workspace"):FindFirstChild("AmbushMoving") or 
           game:GetService("Workspace"):FindFirstChild("Ambush") then
            Notification:Notify(
                {Title = "LNHUB", Description = "Ambush Has Spawned! Find hiding spot!"},
                {OutlineColor = Color3.fromRGB(80, 80, 80),Time = 5, Type = "image"},
                {Image = "http://www.roblox.com/asset/?id=6023426923", ImageColor = Color3.fromRGB(255, 84, 84)}
            )
        end
    end)
end

function setupEntityAlerts()
    setupRushAmbushAlerts()
end

_G.AlertEnabled = true

task.spawn(function()
    task.wait(3)
    if _G.AlertEnabled then
        setupEntityAlerts()
    end
end)

local LeftGroupBox = Tabs.Main:AddLeftGroupbox('Miscellaneous')



LeftGroupBox:AddToggle('', {
    Text = 'No Gates',
    Default = false,
    Callback = function(Value)
        flags.nogates = Value
        
        if Value then
            local addconnect
            addconnect = workspace.CurrentRooms.ChildAdded:Connect(function(room)
                local gate = room:WaitForChild("Gate",2)
                
                if gate then
                    local door = gate:WaitForChild("ThingToOpen",2)
                    
                    if door then
                        door:Destroy() 
                    end
                end
            end)
            
            repeat task.wait() until not flags.nogates
            addconnect:Disconnect()
        end
    end
})

LeftGroupBox:AddToggle('', {
    Text = 'No Puzzle Doors',
    Default = false,
    Callback = function(Value)
        flags.nopuzzle = Value
        
        if Value then
            local addconnect
            addconnect = workspace.CurrentRooms.ChildAdded:Connect(function(room)
                local assets = room:WaitForChild("Assets")
                local paintings = assets:WaitForChild("Paintings",2)
                
                if paintings then
                    local door = paintings:WaitForChild("MovingDoor",2)
                
                    if door then
                        door:Destroy() 
                    end 
                end
            end)
            
            repeat task.wait() until not flags.nopuzzle
            addconnect:Disconnect()
        end
    end
})

LeftGroupBox:AddToggle('', {
    Text = 'No Locks for A-000 Door',
    Default = false,
    Callback = function(Value)
flags.roomsnolock = Value
        
        if Value then
            local function check(room)
                local door = room:WaitForChild("RoomsDoor_Entrance",2)
                
                if door then
                    local prompt = door:WaitForChild("Door"):WaitForChild("EnterPrompt")
                    prompt.Enabled = true
                end 
            end
            
            local addconnect
            addconnect = workspace.CurrentRooms.ChildAdded:Connect(function(room)
                check(room)
            end)
            
            for i,v in pairs(workspace.CurrentRooms:GetChildren()) do
                check(v)
            end
            
            repeat task.wait() until not flags.roomsnolock
            addconnect:Disconnect()
        end
    end
})

local MyButton = LeftGroupBox:AddButton({
    Text = 'Play Again (Restart)',
    Func = function()
        game.ReplicatedStorage.RemotesFolder.PlayAgain:FireServer()
    end,
    DoubleClick = false
})

local MyButton = LeftGroupBox:AddButton({
    Text = 'Lobby',
    Func = function()
        game.ReplicatedStorage.RemotesFolder.Lobby:FireServer()
    end,
    DoubleClick = false
})

local TabBox = Tabs.Main:AddRightTabbox()
local MainTab = TabBox:AddTab('Main')

MainTab:AddToggle('', {
    Text = 'Instant Use',
    Default = false,
    Callback = function(Value)
        if Value then
            setupInstantInteract()
        else
            disableInstantInteract()
        end
    end
})

local originalValues = {}
local connections = {}

function setupInstantInteract()
    local function modifyPrompts()
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("ProximityPrompt") then
                if not originalValues[obj] then
                    originalValues[obj] = obj.HoldDuration
                end
                obj.HoldDuration = 0
                obj.MaxActivationDistance = 10
            end
        end
    end
    
    modifyPrompts()
    
    local connection = workspace.DescendantAdded:Connect(function(obj)
        if obj:IsA("ProximityPrompt") then
            wait(0.1)
            originalValues[obj] = obj.HoldDuration
            obj.HoldDuration = 0
            obj.MaxActivationDistance = 10
        end
    end)
    
    table.insert(connections, connection)
    
    local connection2 = game:GetService("ReplicatedStorage").DescendantAdded:Connect(function(obj)
        if obj:IsA("ProximityPrompt") then
            wait(0.1)
            originalValues[obj] = obj.HoldDuration
            obj.HoldDuration = 0
        end
    end)
    
    table.insert(connections, connection2)
end

function disableInstantInteract()
    for obj, originalValue in pairs(originalValues) do
        if obj and obj.Parent then
            obj.HoldDuration = originalValue
            obj.MaxActivationDistance = 10
        end
    end
    
    originalValues = {}
    
    for _, connection in ipairs(connections) do
        connection:Disconnect()
    end
    
    connections = {}
end

local AurasTab = TabBox:AddTab('Auras')
AurasTab:AddToggle('', {
    Text = 'Loot Aura',
    Default = false,
    Callback = function(Value)
        flags.draweraura = Value
        
        if Value then
            local function setup(room)
                local function check(v)
                    if v:IsA("Model") then
                        if v.Name == "DrawerContainer" then
                            local knob = v:WaitForChild("Knobs")
                            
                            if knob then
                                local prompt = knob:WaitForChild("ActivateEventPrompt")
                                local interactions = prompt:GetAttribute("Interactions")
                                
                                if not interactions then
                                    task.spawn(function()
                                        repeat task.wait(0.1)
                                            if plr:DistanceFromCharacter(knob.Position) <= 12 then
                                                fireproximityprompt(prompt)
                                            end
                                        until prompt:GetAttribute("Interactions") or not flags.draweraura
                                    end)
                                end
                            end
                        elseif v.Name == "GoldPile" then
                            local prompt = v:WaitForChild("LootPrompt")
                            local interactions = prompt:GetAttribute("Interactions")
                                
                            if not interactions then
                                task.spawn(function()
                                    repeat task.wait(0.1)
                                        if plr:DistanceFromCharacter(v.PrimaryPart.Position) <= 12 then
                                            fireproximityprompt(prompt) 
                                        end
                                    until prompt:GetAttribute("Interactions") or not flags.draweraura
                                end)
                            end
                        elseif v.Name:sub(1,8) == "ChestBox" then
                            local prompt = v:WaitForChild("ActivateEventPrompt")
                            local interactions = prompt:GetAttribute("Interactions")
                            
                            if not interactions then
                                task.spawn(function()
                                    repeat task.wait(0.1)
                                        if plr:DistanceFromCharacter(v.PrimaryPart.Position) <= 12 then
                                            fireproximityprompt(prompt)
                                        end
                                    until prompt:GetAttribute("Interactions") or not flags.draweraura
                                end)
                            end
                        elseif v.Name == "RolltopContainer" then
                            local prompt = v:WaitForChild("ActivateEventPrompt")
                            local interactions = prompt:GetAttribute("Interactions")
                            
                            if not interactions then
                                task.spawn(function()
                                    repeat task.wait(0.1)
                                        if plr:DistanceFromCharacter(v.PrimaryPart.Position) <= 12 then
                                            fireproximityprompt(prompt)
                                        end
                                    until prompt:GetAttribute("Interactions") or not flags.draweraura
                                end)
                            end
                        end 
                    end
                end
        
                local subaddcon
                subaddcon = room.DescendantAdded:Connect(function(v)
                    check(v) 
                end)
                
                for i,v in pairs(room:GetDescendants()) do
                    check(v)
                end
                
                task.spawn(function()
                    repeat task.wait() until not flags.draweraura
                    subaddcon:Disconnect() 
                end)
            end
            
            local addconnect
            addconnect = workspace.CurrentRooms.ChildAdded:Connect(function(room)
                setup(room)
            end)
            
            for i,room in pairs(workspace.CurrentRooms:GetChildren()) do
                if room:FindFirstChild("Assets") then
                    setup(room) 
                end
            end
            
            repeat task.wait() until not flags.draweraura
            addconnect:Disconnect()
        end
    end
})

local LeftGroupBox = Tabs.Player:AddLeftGroupbox('Movement')

LeftGroupBox:AddSlider('MySlider', {
    Text = 'Speed Boost',
    Default = 16,
    Min = 16,
    Max = 50,
    Rounding = 1,
    Compact = true,
    Callback = function(Value)
        while true do
            task.wait()
            game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value
        end
    end
})

LeftGroupBox:AddToggle('NoAcceleration', {
    Text = 'No Acceleration',
    Default = false,
    Callback = function(Value)
        if Value then
            -- Функция для настройки мгновенного движения
            local function setupNoAccel()
                local character = game.Players.LocalPlayer.Character
                if character then
                    local humanoid = character:FindFirstChildOfClass("Humanoid")
                    local rootPart = character:FindFirstChild("HumanoidRootPart")
                    
                    if humanoid and rootPart then
                        -- Создаем BodyVelocity для мгновенного перемещения
                        local velocity = Instance.new("BodyVelocity")
                        velocity.MaxForce = Vector3.new(math.huge, 0, math.huge)
                        velocity.P = 10000
                        velocity.Velocity = Vector3.new(0, 0, 0)
                        velocity.Name = "NoAccelBodyVelocity"
                        velocity.Parent = rootPart
                        
                        -- Создаем BodyGyro для стабилизации
                        local gyro = Instance.new("BodyGyro")
                        gyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
                        gyro.P = 10000
                        gyro.D = 1000
                        gyro.CFrame = rootPart.CFrame
                        gyro.Name = "NoAccelBodyGyro"
                        gyro.Parent = rootPart
                        
                        -- Подключаем обработчик движения
                        _G.NoAccelConnection = game:GetService("RunService").Heartbeat:Connect(function()
                            if character and humanoid and rootPart then
                                local moveDirection = humanoid.MoveDirection
                                
                                if moveDirection.Magnitude > 0 then
                                    -- Мгновенное движение без ускорения
                                    velocity.Velocity = moveDirection * humanoid.WalkSpeed
                                    gyro.CFrame = CFrame.new(rootPart.Position, rootPart.Position + moveDirection)
                                else
                                    -- Мгновенная остановка
                                    velocity.Velocity = Vector3.new(0, velocity.Velocity.Y, 0)
                                end
                            end
                        end)
                    end
                end
            end
            
            -- Запускаем
            setupNoAccel()
            
            -- Применяем при смене персонажа
            game.Players.LocalPlayer.CharacterAdded:Connect(function()
                task.wait(0.5)
                if Value then
                    setupNoAccel()
                end
            end)
            
        else
            -- Отключаем
            if _G.NoAccelConnection then
                _G.NoAccelConnection:Disconnect()
                _G.NoAccelConnection = nil
            end
            
            local character = game.Players.LocalPlayer.Character
            if character then
                local rootPart = character:FindFirstChild("HumanoidRootPart")
                if rootPart then
                    local velocity = rootPart:FindFirstChild("NoAccelBodyVelocity")
                    if velocity then velocity:Destroy() end
                    
                    local gyro = rootPart:FindFirstChild("NoAccelBodyGyro")
                    if gyro then gyro:Destroy() end
                end
            end
        end
    end
})

LeftGroupBox:AddToggle('Fly', {
    Text = 'Fly (F)',
    Default = false,
    Callback = function(Value)
        local flyEnabled = false
        local flySpeed = 10
        local flyConnection
        local bodyGyro
        
        -- Функция переключения полета
        local function toggleFlight()
            flyEnabled = not flyEnabled
            local player = game.Players.LocalPlayer
            local character = player.Character
            local humanoid = character and character:FindFirstChild("Humanoid")
            local rootPart = character and character:FindFirstChild("HumanoidRootPart")
            
            if flyEnabled and rootPart then
                -- Включаем полет
                if humanoid then
                    humanoid.PlatformStand = true
                end
                
                -- Создаем BodyGyro для стабилизации вращения
                if bodyGyro then
                    bodyGyro:Destroy()
                end
                
                bodyGyro = Instance.new("BodyGyro")
                bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
                bodyGyro.P = 10000
                bodyGyro.CFrame = rootPart.CFrame
                bodyGyro.Parent = rootPart
                
                -- Запускаем цикл полета
                if flyConnection then
                    flyConnection:Disconnect()
                end
                
                flyConnection = game:GetService("RunService").Heartbeat:Connect(function()
                    if not flyEnabled or not rootPart then
                        if flyConnection then
                            flyConnection:Disconnect()
                        end
                        return
                    end
                    
                    -- Обновляем BodyGyro для фиксации направления
                    if bodyGyro then
                        bodyGyro.CFrame = workspace.CurrentCamera.CFrame
                    end
                    
                    -- Управление полетом
                    local velocity = Vector3.new(0, 0, 0)
                    local camera = workspace.CurrentCamera
                    
                    -- Движение вперед/назад (W/S) - по направлению камеры
                    if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.W) then
                        velocity = velocity + (camera.CFrame.LookVector * flySpeed)
                    end
                    if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.S) then
                        velocity = velocity - (camera.CFrame.LookVector * flySpeed)
                    end
                    
                    -- Движение влево/вправо (A/D) - по направлению камеры
                    if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.A) then
                        velocity = velocity - (camera.CFrame.RightVector * flySpeed)
                    end
                    if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.D) then
                        velocity = velocity + (camera.CFrame.RightVector * flySpeed)
                    end
                    
                    -- Движение вверх/вниз (Space/Shift) - вертикально
                    if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.Space) then
                        velocity = velocity + Vector3.new(0, flySpeed, 0)
                    end
                    if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.LeftShift) then
                        velocity = velocity - Vector3.new(0, flySpeed, 0)
                    end
                    
                    -- Применяем скорость
                    rootPart.Velocity = velocity
                end)
            else
                -- Выключаем полет
                if flyConnection then
                    flyConnection:Disconnect()
                    flyConnection = nil
                end
                
                if bodyGyro then
                    bodyGyro:Destroy()
                    bodyGyro = nil
                end
                
                if humanoid then
                    humanoid.PlatformStand = false
                end
                
                if rootPart then
                    rootPart.Velocity = Vector3.new(0, 0, 0)
                end
            end
        end
        
        -- Обработка клавиши F
        local fKeyConnection
        if Value then
            fKeyConnection = game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
                if gameProcessed then return end
                if input.KeyCode == Enum.KeyCode.F then
                    toggleFlight()
                end
            end)
        else
            -- Очистка при выключении
            if fKeyConnection then
                fKeyConnection:Disconnect()
            end
            
            if flyConnection then
                flyConnection:Disconnect()
            end
            
            if bodyGyro then
                bodyGyro:Destroy()
            end
            
            -- Возвращаем персонажа в нормальное состояние
            local player = game.Players.LocalPlayer
            local character = player.Character
            if character then
                local humanoid = character:FindFirstChild("Humanoid")
                local rootPart = character:FindFirstChild("HumanoidRootPart")
                
                if humanoid then
                    humanoid.PlatformStand = false
                end
                
                if rootPart then
                    rootPart.Velocity = Vector3.new(0, 0, 0)
                end
            end
        end
    end
})

LeftGroupBox:AddToggle('Noclip', {
    Text = 'Noclip (N)',
    Default = false,
    Callback = function(Value)
        local noclipEnabled = false
        local noclipConnection
        
        -- Функция переключения ноклипа
        local function toggleNoclip()
            noclipEnabled = not noclipEnabled
            local player = game.Players.LocalPlayer
            local character = player.Character
            
            if character then
                for _, part in pairs(character:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then
                        part.CanCollide = not noclipEnabled
                    end
                end
            end
        end
        
        -- Автоматический ноклип при движении
        local function autoNoclip()
            if noclipConnection then
                noclipConnection:Disconnect()
            end
            
            noclipConnection = game:GetService("RunService").Stepped:Connect(function()
                if not noclipEnabled then
                    noclipConnection:Disconnect()
                    return
                end
                
                local player = game.Players.LocalPlayer
                local character = player.Character
                
                if character then
                    for _, part in pairs(character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
            end)
        end
        
        -- Обработка клавиши V
        local vKeyConnection
        if Value then
            vKeyConnection = game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
                if gameProcessed then return end
                if input.KeyCode == Enum.KeyCode.N then
                    toggleNoclip()
                    if noclipEnabled then
                        autoNoclip()
                    end
                end
            end)
        else
            -- Очистка при выключении
            if vKeyConnection then
                vKeyConnection:Disconnect()
            end
            
            if noclipConnection then
                noclipConnection:Disconnect()
            end
            
            -- Восстанавливаем коллизии
            local player = game.Players.LocalPlayer
            local character = player.Character
            if character then
                for _, part in pairs(character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = true
                    end
                end
            end
        end
    end
})

local LeftGroupBox = Tabs.Cheats:AddLeftGroupbox('Entity Removers')

LeftGroupBox:AddToggle('', {
    Text = 'No Screech',
    Default = false,
    Callback = function(Value)
        flags.noscreech = Value
        if Value then
            local entityinfo = game:GetService("ReplicatedStorage"):FindFirstChild("EntityInfo")
            if entityinfo then
                local screechremote = entityinfo:FindFirstChild("Screech")
                if screechremote then
                    screechremote.Parent = nil
                    repeat task.wait() until not flags.noscreech
                    screechremote.Parent = entityinfo
                end
            end
        end
    end
})

LeftGroupBox:AddToggle('', {
    Text = 'No Seek Chase',
    Default = false,
    Callback = function(Value)
        flags.noseek = Value
        if Value then
            local addconnect
            addconnect = workspace.CurrentRooms.ChildAdded:Connect(function(room)
                local trigger = room:WaitForChild("TriggerEventCollision",2)
                if trigger then
                    trigger:Destroy() 
                end
            end)
            repeat task.wait() until not flags.noseek
            addconnect:Disconnect()
        end
    end
})

LeftGroupBox:AddToggle('', {
    Text = 'No A-90',
    Default = false,
    Callback = function(Value)
        flags.noa90 = Value
            
            if Value then
                local jumpscare = plr.PlayerGui:WaitForChild("MainUI"):WaitForChild("Jumpscare"):FindFirstChild("Jumpscare_A90")
               
                if jumpscare then
                    jumpscare.Parent = nil
                    
                    a90remote.Parent = nil
                    repeat task.wait()
                        game.SoundService.Main.Volume = 1 
                    until not flags.noa90
                    jumpscare.Parent = plr.PlayerGui.MainUI.Jumpscare
                    a90remote.Parent = entityinfo 
                end
            end
    end
})

local LeftGroupBox = Tabs.Visuals:AddLeftGroupbox('Camera')

LeftGroupBox:AddSlider('MySlider', {
    Text = 'FOV',
    Default = 70,
    Min = 70,
    Max = 120,
    Rounding = 1,
    Compact = true,
    Callback = function(Value)
        _G.FOVChangerConnection = _G.FOVChangerConnection or nil
 
        if _G.FOVChangerConnection then
            _G.FOVChangerConnection:Disconnect()
            _G.FOVChangerConnection = nil
        end
 
        local camera = workspace.Camera
 
        _G.FOVChangerConnection = camera:GetPropertyChangedSignal("FieldOfView"):Connect(function()
            if camera.FieldOfView ~= Value then
                camera.FieldOfView = Value
            end
        end)
 
        camera.FieldOfView = Value
    end
})

local LeftGroupBox = Tabs.Visuals:AddLeftGroupbox('Lighting')

LeftGroupBox:AddToggle('', {
    Text = 'Fullbright',
    Default = false,
    Callback = function(Value)
        if Value then
            game:GetService("Lighting").GlobalShadows = false
            game:GetService("Lighting").FogEnd = 100000
            
            local lighting = game:GetService("Lighting")
            lighting.Brightness = 0
            lighting.ClockTime = 14
            lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
            lighting.Ambient = Color3.fromRGB(255, 255, 255)
            
            for _, obj in pairs(lighting:GetChildren()) do
                if obj:IsA("SunRaysEffect") or 
                   obj:IsA("BloomEffect") or 
                   obj:IsA("BlurEffect") or 
                   obj:IsA("ColorCorrectionEffect") or
                   obj:IsA("DepthOfFieldEffect") then
                    obj.Enabled = false
                end
            end
            
            local newLight = Instance.new("PointLight")
            newLight.Brightness = 1
            newLight.Range = 1000
            newLight.Color = Color3.fromRGB(255, 255, 255)
            newLight.Parent = game:GetService("Lighting")
            
        else
            game:GetService("Lighting").GlobalShadows = true
            game:GetService("Lighting").FogEnd = 10000
            
            local lighting = game:GetService("Lighting")
            lighting.Brightness = 1
            lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
            lighting.Ambient = Color3.fromRGB(128, 128, 128)
            
            for _, obj in pairs(lighting:GetChildren()) do
                if obj:IsA("PointLight") and obj.Brightness == 1 then
                    obj:Destroy()
                end
                if obj:IsA("SunRaysEffect") or 
                   obj:IsA("BloomEffect") or 
                   obj:IsA("BlurEffect") or 
                   obj:IsA("ColorCorrectionEffect") or
                   obj:IsA("DepthOfFieldEffect") then
                    obj.Enabled = true
                end
            end
        end
    end
})

local RightGroupBox = Tabs.Visuals:AddRightGroupbox('ESP')

-- Добавляем оригинальные ESP тогглы из первого скрипта
RightGroupBox:AddToggle('', {
    Text = 'Item ESP',
    Default = false,
    Callback = function(Value)
        ItemESP = Value
        for _,Object in pairs(workspace:GetDescendants()) do
            if ESP_Items[Object.Name] then
                ApplySettings(Object)
            end
        end
    end
})

RightGroupBox:AddToggle('', {
    Text = 'Entity ESP',
    Default = false,
    Callback = function(Value)
        EntityESP = Value
        for _,Object in pairs(workspace:GetDescendants()) do
            if ESP_Entities[Object.Name] then
                ApplySettings(Object)
            end
        end
    end
})

RightGroupBox:AddToggle('', {
    Text = 'Other ESP',
    Default = false,
    Callback = function(Value)
        OtherESP = Value
        for _,Object in pairs(workspace:GetDescendants()) do
            if ESP_Other[Object.Name] then
                ApplySettings(Object)
            end
        end
    end
})

local LeftGroupBox = Tabs.Floors:AddLeftGroupbox('Bypass')



local MenuGroup = Tabs['Configs']:AddLeftGroupbox('Menu')
MenuGroup:AddToggle("KeybindMenuOpen", { Default = Library.KeybindFrame.Visible, Text = "Open Keybind Menu", Callback = function(value) Library.KeybindFrame.Visible = value end})
MenuGroup:AddToggle("ShowCustomCursor", {Text = "Custom Cursor", Default = true, Callback = function(Value) Library.ShowCustomCursor = Value end})
MenuGroup:AddButton('Close Gui', function() Library:Unload() end)
MenuGroup:AddLabel('Gui Menu Bind'):AddKeyPicker('MenuKeybind', { Default = 'RightShift', NoUI = true, Text = 'Menu keybind' })

Library.ToggleKeybind = Options.MenuKeybind

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ 'MenuKeybind' })
ThemeManager:SetFolder('LNHUB')
SaveManager:SetFolder('LNHUB/Doors')
SaveManager:BuildConfigSection(Tabs['Configs'])
ThemeManager:ApplyToTab(Tabs['Configs'])
SaveManager:LoadAutoloadConfig()
