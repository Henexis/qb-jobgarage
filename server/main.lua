local QBCore = exports['qb-core']:GetCoreObject()

-- Lấy danh sách xe của nghề nghiệp
QBCore.Functions.CreateCallback('qb-jobgarage:server:GetVehicles', function(source, cb, jobName)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then return cb({}, 0, 0) end
    
    if Player.PlayerData.job.name ~= jobName then
        return cb({}, 0, 0)
    end
    
    local citizenid = Player.PlayerData.citizenid
    local jobGrade = Player.PlayerData.job.grade.level
    local maxVehicles = Config.JobGarages[jobName].limits[jobGrade] or 1
    
    -- Đếm số xe đã lấy ra
    MySQL.Async.fetchAll('SELECT * FROM job_vehicles WHERE citizenid = ? AND job = ? AND `out` = 1', {
        citizenid,
        jobName
    }, function(results)
        local activeCount = #results
        cb(results, activeCount, maxVehicles)
    end)
end)

-- Kiểm tra xem xe có phải là xe của nghề nghiệp không
QBCore.Functions.CreateCallback('qb-jobgarage:server:CheckJobVehicle', function(source, cb, plate, jobName)
    MySQL.Async.fetchScalar('SELECT 1 FROM job_vehicles WHERE plate = ? AND job = ?', {
        plate,
        jobName
    }, function(result)
        cb(result ~= nil)
    end)
end)

-- Lấy xe ra khỏi garage
QBCore.Functions.CreateCallback('qb-jobgarage:server:SpawnVehicle', function(source, cb, jobName, model)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then return cb(false) end
    
    if Player.PlayerData.job.name ~= jobName then
        return cb(false)
    end
    
    local citizenid = Player.PlayerData.citizenid
    local jobGrade = Player.PlayerData.job.grade.level
    local maxVehicles = Config.JobGarages[jobName].limits[jobGrade] or 1
    
    -- Kiểm tra số lượng xe đã lấy ra
    MySQL.Async.fetchAll('SELECT COUNT(*) as count FROM job_vehicles WHERE citizenid = ? AND job = ? AND `out` = 1', {
        citizenid,
        jobName
    }, function(results)
        local activeCount = results[1].count
        
        if activeCount >= maxVehicles then
            TriggerClientEvent('QBCore:Notify', src, string.format(Config.Notifications.limitReached, maxVehicles), 'error')
            return cb(false)
        end
        
        -- Tạo biển số xe ngẫu nhiên
        local plate = GeneratePlate()
        
        -- Kiểm tra xem xe đã tồn tại trong database chưa
        MySQL.Async.fetchAll('SELECT * FROM job_vehicles WHERE citizenid = ? AND job = ? AND model = ? AND `out` = 0 LIMIT 1', {
            citizenid,
            jobName,
            model
        }, function(existingVehicles)
            if existingVehicles and #existingVehicles > 0 then
                -- Xe đã tồn tại, cập nhật trạng thái
                local existingVehicle = existingVehicles[1]
                MySQL.Async.execute('UPDATE job_vehicles SET `out` = 1 WHERE id = ?', {
                    existingVehicle.id
                }, function(rowsChanged)
                    if rowsChanged > 0 then
                        local vehicleProps = json.decode(existingVehicle.properties or '{}')
                        cb(true, existingVehicle.plate, vehicleProps)
                    else
                        -- Nếu không thể cập nhật, tạo xe mới
                        CreateNewVehicle(src, citizenid, jobName, model, plate, cb)
                    end
                end)
            else
                -- Tạo xe mới
                CreateNewVehicle(src, citizenid, jobName, model, plate, cb)
            end
        end)
    end)
end)

-- Hàm tạo xe mới
function CreateNewVehicle(src, citizenid, jobName, model, plate, cb)
    MySQL.Async.insert('INSERT INTO job_vehicles (citizenid, job, plate, model, `out`) VALUES (?, ?, ?, ?, 1)', {
        citizenid,
        jobName,
        plate,
        model
    }, function(id)
        if id > 0 then
            cb(true, plate, nil)
        else
            TriggerClientEvent('QBCore:Notify', src, 'Không thể tạo xe mới', 'error')
            cb(false)
        end
    end)
end

-- Cất xe vào garage
RegisterNetEvent('qb-jobgarage:server:StoreVehicle', function(plate, vehicleProps, jobName)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then return end
    
    if Player.PlayerData.job.name ~= jobName then
        TriggerClientEvent('QBCore:Notify', src, Config.Notifications.wrongJob, 'error')
        return
    end
    
    local citizenid = Player.PlayerData.citizenid
    
    -- Kiểm tra xem xe có tồn tại trong database không
    MySQL.Async.fetchAll('SELECT * FROM job_vehicles WHERE plate = ? AND job = ?', {
        plate,
        jobName
    }, function(results)
        if results and #results > 0 then
            -- Xe đã tồn tại, cập nhật thông tin
            MySQL.Async.execute('UPDATE job_vehicles SET `out` = 0, fuel = ?, body = ?, engine = ?, properties = ? WHERE plate = ? AND job = ?', {
                vehicleProps.fuelLevel or 100,
                vehicleProps.bodyHealth or 1000.0,
                vehicleProps.engineHealth or 1000.0,
                json.encode(vehicleProps),
                plate,
                jobName
            })
        else
            -- Xe chưa tồn tại, thêm mới
            MySQL.Async.insert('INSERT INTO job_vehicles (citizenid, job, plate, model, fuel, body, engine, properties, `out`) VALUES (?, ?, ?, ?, ?, ?, ?, ?, 0)', {
                citizenid,
                jobName,
                plate,
                vehicleProps.model,
                vehicleProps.fuelLevel or 100,
                vehicleProps.bodyHealth or 1000.0,
                vehicleProps.engineHealth or 1000.0,
                json.encode(vehicleProps)
            })
        end
    end)
end)

-- Tạo biển số xe ngẫu nhiên
function GeneratePlate()
    local plate = ""
    local charset = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    
    for i = 1, 8 do
        local rand = math.random(1, #charset)
        plate = plate .. string.sub(charset, rand, rand)
    end
    
    -- Kiểm tra xem biển số đã tồn tại chưa
    local result = MySQL.Sync.fetchScalar('SELECT 1 FROM job_vehicles WHERE plate = ?', {plate})
    if result then
        -- Nếu biển số đã tồn tại, tạo biển số mới
        return GeneratePlate()
    end
    
    return plate
end

-- Xóa xe khi người chơi đăng xuất
RegisterNetEvent('QBCore:Server:OnPlayerUnload', function(source)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then return end
    
    local citizenid = Player.PlayerData.citizenid
    
    -- Đặt tất cả xe của người chơi về trạng thái đã cất
    MySQL.Async.execute('UPDATE job_vehicles SET `out` = 0 WHERE citizenid = ? AND `out` = 1', {
        citizenid
    })
end)

-- Xóa xe khi server khởi động lại
AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        -- Đặt tất cả xe về trạng thái đã cất khi script khởi động
        MySQL.Async.execute('UPDATE job_vehicles SET `out` = 0 WHERE `out` = 1', {})
    end
end)

-- Lệnh admin để xóa tất cả xe của một người chơi
QBCore.Commands.Add('clearvehicles', 'Xóa tất cả xe của một người chơi (Admin)', {{name = 'id', help = 'ID người chơi'}}, true, function(source, args)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player.PlayerData.job.name == 'admin' and not IsPlayerAceAllowed(src, 'command') then
        TriggerClientEvent('QBCore:Notify', src, 'Bạn không có quyền sử dụng lệnh này', 'error')
        return
    end
    
    local targetId = tonumber(args[1])
    local TargetPlayer = QBCore.Functions.GetPlayer(targetId)
    
    if not TargetPlayer then
        TriggerClientEvent('QBCore:Notify', src, 'Người chơi không tồn tại', 'error')
        return
    end
    
    local citizenid = TargetPlayer.PlayerData.citizenid
    
    MySQL.Async.execute('DELETE FROM job_vehicles WHERE citizenid = ?', {
        citizenid
    }, function(rowsChanged)
        TriggerClientEvent('QBCore:Notify', src, 'Đã xóa ' .. rowsChanged .. ' xe của người chơi ' .. TargetPlayer.PlayerData.name, 'success')
    end)
end)

-- Lệnh admin để xóa tất cả xe của một nghề nghiệp
QBCore.Commands.Add('clearjobvehicles', 'Xóa tất cả xe của một nghề nghiệp (Admin)', {{name = 'job', help = 'Tên nghề nghiệp'}}, true, function(source, args)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player.PlayerData.job.name == 'admin' and not IsPlayerAceAllowed(src, 'command') then
        TriggerClientEvent('QBCore:Notify', src, 'Bạn không có quyền sử dụng lệnh này', 'error')
        return
    end
    
    local jobName = args[1]
    
    if not Config.JobGarages[jobName] then
        TriggerClientEvent('QBCore:Notify', src, 'Nghề nghiệp không tồn tại', 'error')
        return
    end
    
    MySQL.Async.execute('DELETE FROM job_vehicles WHERE job = ?', {
        jobName
    }, function(rowsChanged)
        TriggerClientEvent('QBCore:Notify', src, 'Đã xóa ' .. rowsChanged .. ' xe của nghề nghiệp ' .. jobName, 'success')
    end)
end)
