local QBCore = exports['qb-core']:GetCoreObject()
local PlayerData = {}
local activeVehicles = {}
local nearGarage = nil

-- Khởi tạo
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    PlayerData = QBCore.Functions.GetPlayerData()
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo)
    PlayerData.job = JobInfo
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    PlayerData = {}
    activeVehicles = {}
end)

-- Kiểm tra xem người chơi có đủ điều kiện sử dụng garage không
local function hasAccess(jobName)
    if not PlayerData.job then return false end
    return PlayerData.job.name == jobName
end

-- Tạo blips nếu được cấu hình
local function CreateBlips()
    for job, garageData in pairs(Config.JobGarages) do
        for _, location in ipairs(garageData.locations) do
            if location.blip and location.blip.enabled then
                local blip = AddBlipForCoord(location.coords.x, location.coords.y, location.coords.z)
                SetBlipSprite(blip, location.blip.sprite)
                SetBlipDisplay(blip, 4)
                SetBlipScale(blip, location.blip.scale)
                SetBlipColour(blip, location.blip.color)
                SetBlipAsShortRange(blip, true)
                BeginTextCommandSetBlipName("STRING")
                AddTextComponentString(location.blip.label)
                EndTextCommandSetBlipName(blip)
            end
        end
    end
end

-- Hiển thị menu lấy xe
local function OpenGarageMenu(jobName, locationIndex)
    local garage = Config.JobGarages[jobName]
    if not garage then return end
    
    QBCore.Functions.TriggerCallback('qb-jobgarage:server:GetVehicles', function(vehicles, activeCount, maxVehicles)
        if activeCount >= maxVehicles then
            if Config.UseOxLib then
                lib.notify({
                    title = 'Garage',
                    description = string.format(Config.Notifications.limitReached, maxVehicles),
                    type = 'error'
                })
            else
                QBCore.Functions.Notify(string.format(Config.Notifications.limitReached, maxVehicles), 'error')
            end
            return
        end
        
        local options = {}
        local jobGrade = PlayerData.job.grade.level
        local availableVehicles = garage.vehicles[jobGrade] or {}
        
        if #availableVehicles == 0 then
            if Config.UseOxLib then
                lib.notify({
                    title = 'Garage',
                    description = Config.Notifications.noVehicles,
                    type = 'error'
                })
            else
                QBCore.Functions.Notify(Config.Notifications.noVehicles, 'error')
            end
            return
        end
        
        for _, vehicle in ipairs(availableVehicles) do
            table.insert(options, {
                title = vehicle.label,
                description = 'Lấy xe ' .. vehicle.label,
                onSelect = function()
                    SpawnVehicle(jobName, vehicle, locationIndex)
                end
            })
        end
        
        if Config.UseOxLib then
            lib.showContext('job_garage_menu', {
                id = 'job_garage_menu',
                title = garage.label,
                options = options
            })
        else
            -- Sử dụng menu mặc định của QBCore nếu không dùng ox_lib
            local menu = {
                {
                    header = garage.label,
                    isMenuHeader = true
                }
            }
            
            for i, option in ipairs(options) do
                menu[#menu+1] = {
                    header = option.title,
                    txt = option.description,
                    params = {
                        event = 'qb-jobgarage:client:SpawnVehicle',
                        args = {
                            jobName = jobName,
                            vehicle = availableVehicles[i],
                            locationIndex = locationIndex
                        }
                    }
                }
            end
            
            exports['qb-menu']:openMenu(menu)
        end
    end, jobName)
end

-- Spawn xe
function SpawnVehicle(jobName, vehicleData, locationIndex)
    local garage = Config.JobGarages[jobName]
    local spawnPoint = garage.locations[locationIndex].spawnPoint
    
    QBCore.Functions.TriggerCallback('qb-jobgarage:server:SpawnVehicle', function(success, plate, vehicleProps)
        if success then
            QBCore.Functions.SpawnVehicle(vehicleData.model, function(vehicle)
                SetEntityHeading(vehicle, spawnPoint.w)
                SetVehicleNumberPlateText(vehicle, plate)
                
                if vehicleProps then
                    QBCore.Functions.SetVehicleProperties(vehicle, vehicleProps)
                end
                
                if vehicleData.livery then
                    SetVehicleLivery(vehicle, vehicleData.livery)
                end
                
                if vehicleData.extras then
                    for extraId, enabled in pairs(vehicleData.extras) do
                        SetVehicleExtra(vehicle, tonumber(extraId), not enabled)
                    end
                end
                
                SetVehicleFuelLevel(vehicle, vehicleProps and vehicleProps.fuelLevel or 100.0)
                SetVehicleEngineHealth(vehicle, vehicleProps and vehicleProps.engineHealth or 1000.0)
                SetVehicleBodyHealth(vehicle, vehicleProps and vehicleProps.bodyHealth or 1000.0)
                
                TriggerEvent("vehiclekeys:client:SetOwner", QBCore.Functions.GetPlate(vehicle))
                SetVehicleEngineOn(vehicle, true, true)
                
                if Config.UseOxLib then
                    lib.notify({
                        title = 'Garage',
                        description = string.format(Config.Notifications.vehicleOut, vehicleData.label),
                        type = 'success'
                    })
                else
                    QBCore.Functions.Notify(string.format(Config.Notifications.vehicleOut, vehicleData.label), 'success')
                end
                
                table.insert(activeVehicles, {
                    plate = plate,
                    job = jobName
                })
            end, spawnPoint, true)
        end
    end, jobName, vehicleData.model)
end

RegisterNetEvent('qb-jobgarage:client:SpawnVehicle', function(data)
    SpawnVehicle(data.jobName, data.vehicle, data.locationIndex)
end)

-- Cất xe
local function StoreVehicle(jobName, returnPoint)
    local ped = PlayerPedId()
    if not IsPedInAnyVehicle(ped, false) then
        if Config.UseOxLib then
            lib.notify({
                title = 'Garage',
                description = Config.Notifications.notInVehicle,
                type = 'error'
            })
        else
            QBCore.Functions.Notify(Config.Notifications.notInVehicle, 'error')
        end
        return
    end
    
    local vehicle = GetVehiclePedIsIn(ped, false)
    local plate = QBCore.Functions.GetPlate(vehicle)
    
    -- Kiểm tra xem xe có phải là xe của nghề nghiệp không
    local isJobVehicle = false
    for i, veh in ipairs(activeVehicles) do
        if veh.plate == plate and veh.job == jobName then
            isJobVehicle = true
            table.remove(activeVehicles, i)
            break
        end
    end
    
    if not isJobVehicle then
        QBCore.Functions.TriggerCallback('qb-jobgarage:server:CheckJobVehicle', function(result)
            isJobVehicle = result
            
            if not isJobVehicle then
                if Config.UseOxLib then
                    lib.notify({
                        title = 'Garage',
                        description = Config.Notifications.notJobVehicle,
                        type = 'error'
                    })
                else
                    QBCore.Functions.Notify(Config.Notifications.notJobVehicle, 'error')
                end
                return
            else
                ProcessVehicleStorage(vehicle, plate, jobName)
            end
        end, plate, jobName)
    else
        ProcessVehicleStorage(vehicle, plate, jobName)
    end
end

function ProcessVehicleStorage(vehicle, plate, jobName)
    local vehicleProps = QBCore.Functions.GetVehicleProperties(vehicle)
    vehicleProps.fuelLevel = GetVehicleFuelLevel(vehicle)
    vehicleProps.bodyHealth = GetVehicleBodyHealth(vehicle)
    vehicleProps.engineHealth = GetVehicleEngineHealth(vehicle)
    
    TriggerServerEvent('qb-jobgarage:server:StoreVehicle', plate, vehicleProps, jobName)
    
    QBCore.Functions.DeleteVehicle(vehicle)
    
    if Config.UseOxLib then
        lib.notify({
            title = 'Garage',
            description = Config.Notifications.vehicleStored,
            type = 'success'
        })
    else
        QBCore.Functions.Notify(Config.Notifications.vehicleStored, 'success')
    end
end

-- Thiết lập các điểm tương tác
local function SetupJobGarages()
    if Config.UseTarget then
        -- Sử dụng qb-target hoặc ox_target
        for jobName, garageData in pairs(Config.JobGarages) do
            for i, location in ipairs(garageData.locations) do
                -- Điểm lấy xe
                exports['qb-target']:AddBoxZone(
                    'jobgarage_' .. jobName .. '_' .. i,
                    vector3(location.coords.x, location.coords.y, location.coords.z),
                    2.0, 2.0,
                    {
                        name = 'jobgarage_' .. jobName .. '_' .. i,
                        heading = location.coords.w,
                        debugPoly = false,
                        minZ = location.coords.z - 1.0,
                        maxZ = location.coords.z + 1.0
                    },
                    {
                        options = {
                            {
                                type = 'client',
                                event = 'qb-jobgarage:client:OpenGarage',
                                icon = 'fas fa-car',
                                label = 'Mở Garage ' .. garageData.label,
                                job = jobName,
                                canInteract = function()
                                    return hasAccess(jobName)
                                end,
                                locationIndex = i
                            }
                        },
                        distance = Config.TargetDistance
                    }
                )
                
                -- Điểm cất xe
                exports['qb-target']:AddBoxZone(
                    'jobgarage_return_' .. jobName .. '_' .. i,
                    vector3(location.returnPoint.x, location.returnPoint.y, location.returnPoint.z),
                    3.0, 3.0,
                    {
                        name = 'jobgarage_return_' .. jobName .. '_' .. i,
                        heading = location.coords.w,
                        debugPoly = false,
                        minZ = location.returnPoint.z - 1.0,
                        maxZ = location.returnPoint.z + 1.0
                    },
                    {
                        options = {
                            {
                                type = 'client',
                                event = 'qb-jobgarage:client:StoreVehicle',
                                icon = 'fas fa-parking',
                                label = 'Cất Xe Vào Garage',
                                job = jobName,
                                canInteract = function()
                                    return hasAccess(jobName) and IsPedInAnyVehicle(PlayerPedId(), false)
                                end,
                                returnPoint = location.returnPoint
                            }
                        },
                        distance = Config.TargetDistance
                    }
                )
            end
        end
    else
        -- Sử dụng polyzone nếu không dùng target
        CreateThread(function()
            while true do
                local sleep = 1000
                local playerPed = PlayerPedId()
                local playerCoords = GetEntityCoords(playerPed)
                local inVehicle = IsPedInAnyVehicle(playerPed, false)
                
                nearGarage = nil
                
                for jobName, garageData in pairs(Config.JobGarages) do
                    if hasAccess(jobName) then
                        for i, location in ipairs(garageData.locations) do
                            -- Điểm lấy xe
                            local dist = #(playerCoords - vector3(location.coords.x, location.coords.y, location.coords.z))
                            if dist < 10.0 then
                                sleep = 0
                                if dist < 3.0 then
                                    nearGarage = {
                                        type = 'spawn',
                                        jobName = jobName,
                                        locationIndex = i
                                    }
                                    
                                    if not inVehicle then
                                        DrawMarker(2, location.coords.x, location.coords.y, location.coords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.2, 0.15, 200, 0, 0, 222, false, false, false, true, false, false, false)
                                        if dist < 1.5 then
                                            DrawText3D(location.coords.x, location.coords.y, location.coords.z + 0.2, '[E] Mở Garage ' .. garageData.label)
                                            if IsControlJustPressed(0, 38) then -- E key
                                                OpenGarageMenu(jobName, i)
                                            end
                                        end
                                    end
                                end
                            end
                            
                            -- Điểm cất xe
                            if inVehicle then
                                local returnDist = #(playerCoords - vector3(location.returnPoint.x, location.returnPoint.y, location.returnPoint.z))
                                if returnDist < 10.0 then
                                    sleep = 0
                                    if returnDist < 3.0 then
                                        nearGarage = {
                                            type = 'return',
                                            jobName = jobName,
                                            returnPoint = location.returnPoint
                                        }
                                        
                                        DrawMarker(2, location.returnPoint.x, location.returnPoint.y, location.returnPoint.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.2, 0.15, 200, 0, 0, 222, false, false, false, true, false, false, false)
                                        if returnDist < 1.5 then
                                            DrawText3D(location.returnPoint.x, location.returnPoint.y, location.returnPoint.z + 0.2, '[E] Cất Xe Vào Garage')
                                            if IsControlJustPressed(0, 38) then -- E key
                                                StoreVehicle(jobName, location.returnPoint)
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
                
                Wait(sleep)
            end
        end)
    end
end

-- Hàm vẽ text 3D
function DrawText3D(x, y, z, text)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x, y, z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0+0.0125, 0.017+ factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end

-- Events
RegisterNetEvent('qb-jobgarage:client:OpenGarage', function(data)
    OpenGarageMenu(data.job, data.locationIndex)
end)

RegisterNetEvent('qb-jobgarage:client:StoreVehicle', function(data)
    StoreVehicle(data.job, data.returnPoint)
end)

-- Khởi tạo
CreateThread(function()
    while not QBCore.Functions.GetPlayerData().job do
        Wait(100)
    end
    
    PlayerData = QBCore.Functions.GetPlayerData()
    CreateBlips()
    SetupJobGarages()
end)

