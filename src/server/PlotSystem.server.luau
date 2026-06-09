local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local MAX_PLOTS = 6
local plots = {}

-- Discover plots in Workspace
for i = 1, MAX_PLOTS do
    local plot = Workspace:WaitForChild("Plot" .. i, 5)
    if plot then
        plots[i] = { model = plot, owner = nil }
        
        -- Create a BillboardGui for the base
        local base = plot:FindFirstChild("Base") or plot:FindFirstChildOfClass("BasePart")
        if base then
            local bg = Instance.new("BillboardGui")
            bg.Name = "PlotNameplate"
            bg.Size = UDim2.new(0, 400, 0, 150)
            bg.StudsOffset = Vector3.new(0, base.Size.Y/2 + 7, 0)
            bg.AlwaysOnTop = true
            
            local frame = Instance.new("Frame", bg)
            frame.Size = UDim2.new(1, 0, 1, 0)
            frame.BackgroundTransparency = 1
            
            local avatar = Instance.new("ImageLabel", frame)
            avatar.Name = "Avatar"
            avatar.Size = UDim2.new(0, 100, 0, 100)
            avatar.Position = UDim2.new(0, 20, 0.5, -50)
            avatar.BackgroundTransparency = 1
            avatar.Image = ""
            
            local label = Instance.new("TextLabel", frame)
            label.Name = "NameLabel"
            label.Size = UDim2.new(1, -140, 1, 0)
            label.Position = UDim2.new(0, 140, 0, 0)
            label.BackgroundTransparency = 1
            label.Text = "Unowned Plot"
            label.Font = Enum.Font.FredokaOne
            label.TextScaled = true
            label.TextColor3 = Color3.new(1,1,1)
            
            local stroke = Instance.new("UIStroke", label)
            stroke.Thickness = 3
            
            bg.Parent = base
        end
    end
end

local function assignPlot(player)
    for i = 1, MAX_PLOTS do
        if plots[i] and plots[i].owner == nil then
            plots[i].owner = player
            plots[i].model:SetAttribute("OwnerUserId", player.UserId)
            
            local base = plots[i].model:FindFirstChild("Base") or plots[i].model:FindFirstChildOfClass("BasePart")
            if base then
                local bg = base:FindFirstChild("PlotNameplate")
                if bg then
                    local label = bg.Frame.NameLabel
                    local avatar = bg.Frame.Avatar
                    
                    label.Text = player.Name .. "'s Plot"
                    
                    task.spawn(function()
                        local content, isReady = Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
                        if isReady then
                            avatar.Image = content
                        end
                    end)
                end
            end
            
            return plots[i].model
        end
    end
    return nil
end

local function releasePlot(player)
    for i = 1, MAX_PLOTS do
        if plots[i] and plots[i].owner == player then
            plots[i].owner = nil
            plots[i].model:SetAttribute("OwnerUserId", nil)
            
            local base = plots[i].model:FindFirstChild("Base") or plots[i].model:FindFirstChildOfClass("BasePart")
            if base then
                local bg = base:FindFirstChild("PlotNameplate")
                if bg then
                    local label = bg.Frame.NameLabel
                    local avatar = bg.Frame.Avatar
                    
                    label.Text = "Unowned Plot"
                    avatar.Image = ""
                end
            end
            break
        end
    end
end

Players.PlayerAdded:Connect(function(player)
    local assignedPlot = assignPlot(player)
    
    player.CharacterAdded:Connect(function(character)
        task.wait(0.5) -- wait for physics to settle
        if assignedPlot then
            local spawnLoc = assignedPlot:FindFirstChildOfClass("SpawnLocation") 
            local base = assignedPlot:FindFirstChild("Base") or assignedPlot:FindFirstChildOfClass("BasePart")
            
            local hrp = character:WaitForChild("HumanoidRootPart", 5)
            if hrp then
                if spawnLoc then
                    hrp.CFrame = spawnLoc.CFrame + Vector3.new(0, 3, 0)
                elseif base then
                    hrp.CFrame = base.CFrame + Vector3.new(0, base.Size.Y/2 + 3, 0)
                end
            end
        end
    end)
end)

Players.PlayerRemoving:Connect(releasePlot)
