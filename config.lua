Config = {}

-- Cài đặt chung
Config.UseOxLib = true -- Sử dụng ox_lib
Config.UseTarget = true -- Sử dụng qb-target hoặc ox_target
Config.TargetDistance = 3.0 -- Khoảng cách hiển thị target

-- Cài đặt garage
Config.JobGarages = {
    ['police'] = {
        label = 'Garage Cảnh Sát',
        locations = {
            {
                coords = vector4(442.0, -1026.0, 28.7, 90.0), -- Vị trí lấy xe
                spawnPoint = vector4(449.0, -1025.0, 28.5, 90.0), -- Vị trí spawn xe
                returnPoint = vector3(453.0, -1022.0, 28.0), -- Vị trí cất xe
                blip = {
                    enabled = false, -- Không hiển thị trên bản đồ
                    sprite = 357,
                    color = 3,
                    scale = 0.8,
                    label = 'Garage Cảnh Sát'
                }
            },
            {
                coords = vector4(1868.5, 3694.5, 33.6, 90.0), -- Sandy Shores
                spawnPoint = vector4(1866.0, 3700.0, 33.5, 215.0),
                returnPoint = vector3(1860.0, 3706.0, 33.0),
                blip = {
                    enabled = false,
                    sprite = 357,
                    color = 3,
                    scale = 0.8,
                    label = 'Garage Cảnh Sát Sandy'
                }
            }
        },
        vehicles = {
            [0] = { -- Cấp bậc 0 (Cadet)
                {
                    model = 'police',
                    label = 'Xe Tuần Tra',
                    livery = 0,
                    extras = {
                        [1] = true,
                        [2] = true,
                        [3] = false
                    }
                }
            },
            [1] = { -- Cấp bậc 1 (Officer)
                {
                    model = 'police',
                    label = 'Xe Tuần Tra',
                    livery = 0,
                    extras = {
                        [1] = true,
                        [2] = true,
                        [3] = false
                    }
                },
                {
                    model = 'police2',
                    label = 'Xe Tuần Tra 2',
                    livery = 1,
                    extras = {}
                }
            },
            [2] = { -- Cấp bậc 2 (Sergeant)
                {
                    model = 'police',
                    label = 'Xe Tuần Tra',
                    livery = 0,
                    extras = {}
                },
                {
                    model = 'police2',
                    label = 'Xe Tuần Tra 2',
                    livery = 1,
                    extras = {}
                },
                {
                    model = 'police3',
                    label = 'Xe Tuần Tra Cao Cấp',
                    livery = 0,
                    extras = {}
                }
            },
            [3] = { -- Cấp bậc 3 (Lieutenant)
                {
                    model = 'police',
                    label = 'Xe Tuần Tra',
                    livery = 0,
                    extras = {}
                },
                {
                    model = 'police2',
                    label = 'Xe Tuần Tra 2',
                    livery = 1,
                    extras = {}
                },
                {
                    model = 'police3',
                    label = 'Xe Tuần Tra Cao Cấp',
                    livery = 0,
                    extras = {}
                },
                {
                    model = 'policeb',
                    label = 'Mô Tô Cảnh Sát',
                    livery = 0,
                    extras = {}
                }
            ],
            [4] = { -- Cấp bậc 4 (Chief)
                {
                    model = 'police',
                    label = 'Xe Tuần Tra',
                    livery = 0,
                    extras = {}
                },
                {
                    model = 'police2',
                    label = 'Xe Tuần Tra 2',
                    livery = 1,
                    extras = {}
                },
                {
                    model = 'police3',
                    label = 'Xe Tuần Tra Cao Cấp',
                    livery = 0,
                    extras = {}
                },
                {
                    model = 'police4',
                    label = 'Xe Chỉ Huy',
                    livery = 0,
                    extras = {}
                },
                {
                    model = 'policeb',
                    label = 'Mô Tô Cảnh Sát',
                    livery = 0,
                    extras = {}
                }
            }
        },
        limits = { -- Giới hạn số xe theo cấp bậc
            [0] = 1, -- Cadet
            [1] = 2, -- Officer
            [2] = 3, -- Sergeant
            [3] = 4, -- Lieutenant
            [4] = 5  -- Chief
        }
    },
    ['ambulance'] = {
        label = 'Garage Y Tế',
        locations = {
            {
                coords = vector4(295.0, -600.0, 43.3, 70.0),
                spawnPoint = vector4(290.0, -605.0, 43.1, 250.0),
                returnPoint = vector3(288.0, -610.0, 43.0),
                blip = {
                    enabled = false,
                    sprite = 357,
                    color = 1,
                    scale = 0.8,
                    label = 'Garage Y Tế'
                }
            }
        },
        vehicles = {
            [0] = { -- EMT
                {
                    model = 'ambulance',
                    label = 'Xe Cứu Thương',
                    livery = 0,
                    extras = {}
                }
            },
            [1] = { -- Paramedic
                {
                    model = 'ambulance',
                    label = 'Xe Cứu Thương',
                    livery = 0,
                    extras = {}
                }
            },
            [2] = { -- Doctor
                {
                    model = 'ambulance',
                    label = 'Xe Cứu Thương',
                    livery = 0,
                    extras = {}
                },
                {
                    model = 'ambulance2',
                    label = 'Xe Cứu Thương Cao Cấp',
                    livery = 0,
                    extras = {}
                }
            },
            [3] = { -- Surgeon
                {
                    model = 'ambulance',
                    label = 'Xe Cứu Thương',
                    livery = 0,
                    extras = {}
                },
                {
                    model = 'ambulance2',
                    label = 'Xe Cứu Thương Cao Cấp',
                    livery = 0,
                    extras = {}
                }
            },
            [4] = { -- Chief
                {
                    model = 'ambulance',
                    label = 'Xe Cứu Thương',
                    livery = 0,
                    extras = {}
                },
                {
                    model = 'ambulance2',
                    label = 'Xe Cứu Thương Cao Cấp',
                    livery = 0,
                    extras = {}
                },
                {
                    model = 'firetruk',
                    label = 'Xe Cứu Hỏa',
                    livery = 0,
                    extras = {}
                }
            }
        },
        limits = {
            [0] = 1, -- EMT
            [1] = 2, -- Paramedic
            [2] = 2, -- Doctor
            [3] = 3, -- Surgeon
            [4] = 4  -- Chief
        }
    }
}

-- Thông báo
Config.Notifications = {
    noVehicles = 'Không còn xe nào có sẵn cho cấp bậc của bạn',
    vehicleOut = 'Bạn đã lấy xe %s ra khỏi garage',
    vehicleStored = 'Bạn đã cất xe vào garage',
    notJobVehicle = 'Đây không phải là xe của nghề nghiệp bạn',
    wrongJob = 'Bạn không có quyền sử dụng garage này',
    limitReached = 'Bạn đã đạt giới hạn số xe có thể lấy ra (%d xe)',
    notInVehicle = 'Bạn cần phải ngồi trong xe để cất xe',
    tooFarAway = 'Xe quá xa để cất vào garage'
}
