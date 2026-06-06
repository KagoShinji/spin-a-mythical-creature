local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Network = {}

local RemoteFolder = ReplicatedStorage:FindFirstChild("Remotes")
if not RemoteFolder then
    if RunService:IsServer() then
        RemoteFolder = Instance.new("Folder")
        RemoteFolder.Name = "Remotes"
        RemoteFolder.Parent = ReplicatedStorage
    else
        RemoteFolder = ReplicatedStorage:WaitForChild("Remotes")
    end
end

function Network.getEvent(name: string): RemoteEvent
    local event = RemoteFolder:FindFirstChild(name)
    if not event then
        if RunService:IsServer() then
            event = Instance.new("RemoteEvent")
            event.Name = name
            event.Parent = RemoteFolder
        else
            event = RemoteFolder:WaitForChild(name)
        end
    end
    return event :: RemoteEvent
end

function Network.getFunction(name: string): RemoteFunction
    local func = RemoteFolder:FindFirstChild(name)
    if not func then
        if RunService:IsServer() then
            func = Instance.new("RemoteFunction")
            func.Name = name
            func.Parent = RemoteFolder
        else
            func = RemoteFolder:WaitForChild(name)
        end
    end
    return func :: RemoteFunction
end

return Network
