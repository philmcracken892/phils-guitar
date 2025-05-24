local RSGCore = exports['rsg-core']:GetCoreObject()
local deployedGuitar = nil
local deployedOwner = nil
local isPlaying = false


local function ShowGuitarMenu()
    ExecuteCommand('closeInv')
    lib.registerContext({
        id = 'guitar_selection_menu',
        title = 'Place Guitar',
        options = {
            {
                title = 'Place Guitar',
                description = 'Place a guitar on the ground.',
                icon = 'fas fa-guitar',
                onSelect = function()
                    TriggerEvent('rsg-guitar:client:placeGuitar')
                end
            }
        }
    })
    lib.showContext('guitar_selection_menu')
end


local function RegisterGuitarTargeting()
    exports['ox_target']:addModel(Config.GuitarModels[1].model, {
        {
            name = 'play_guitar',
            event = 'rsg-guitar:client:playGuitar',
            icon = 'fas fa-guitar',
            label = 'Play Guitar',
            distance = 2.0,
            canInteract = function(entity)
                return not isPlaying
            end
        },
        {
            name = 'pickup_guitar',
            event = 'rsg-guitar:client:pickupGuitar',
            icon = 'fas fa-hand',
            label = 'Pick Up Guitar',
            distance = 2.0,
            canInteract = function(entity)
                return not isPlaying
            end
        }
    })
end


RegisterNetEvent('rsg-guitar:client:placeGuitar', function()
    if deployedGuitar then
        lib.notify({
            title = 'Guitar Already Placed',
            description = 'You already have a guitar placed.',
            type = 'error'
        })
        return
    end

    local guitarData = Config.GuitarModels[1]
    local coords = GetEntityCoords(PlayerPedId())
    local heading = GetEntityHeading(PlayerPedId())
    local forward = GetEntityForwardVector(PlayerPedId())
    
    local offsetDistance = 1.0
    local guitarX = coords.x + forward.x * offsetDistance
    local guitarY = coords.y + forward.y * offsetDistance
    local guitarZ = coords.z

    RequestModel(guitarData.model)
    while not HasModelLoaded(guitarData.model) do
        Wait(100)
    end

    TaskStartScenarioInPlace(PlayerPedId(), GetHashKey('WORLD_HUMAN_CROUCH_INSPECT'), -1, true, false, false, false)
    Wait(2000)

   
    local guitarObject = CreateObject(guitarData.model, guitarX, guitarY, guitarZ, true, false, false)
    PlaceObjectOnGroundProperly(guitarObject)
    SetEntityHeading(guitarObject, heading)
    FreezeEntityPosition(guitarObject, true)

    
    deployedGuitar = guitarObject
    deployedOwner = GetPlayerServerId(PlayerId())

    SetModelAsNoLongerNeeded(guitarData.model)
    Wait(500)
    ClearPedTasks(PlayerPedId())

    TriggerServerEvent('rsg-guitar:server:placementSuccess')
end)


RegisterNetEvent('rsg-guitar:client:playGuitar', function()
    if isPlaying then return end
    isPlaying = true

    local ped = PlayerPedId()
    
   
    if deployedGuitar then
        DeleteObject(deployedGuitar)
        TriggerServerEvent('rsg-guitar:server:returnGuitar', deployedOwner)
        deployedGuitar = nil
        deployedOwner = nil
        
    end

   
    TaskStartScenarioInPlace(ped, GetHashKey('WORLD_HUMAN_SIT_GUITAR'), -1, true, false, false, false)

    lib.notify({
        title = 'Playing Guitar',
        description = 'Press [E] to stop playing',
        type = 'info'
    })

   
    CreateThread(function()
        while isPlaying do
            if IsControlJustPressed(0, 0xCEFD9220) then
                isPlaying = false
                ClearPedTasksImmediately(ped)
                ClearPedSecondaryTask(ped)
                TaskClearLookAt(ped)
               
                
                break
            end
            Wait(0)
        end
    end)

   
    CreateThread(function()
        Wait(1800000)
        if isPlaying then
            isPlaying = false
            ClearPedTasksImmediately(ped)
            ClearPedSecondaryTask(ped)
            TaskClearLookAt(ped)
            
            
        end
    end)
end)


RegisterNetEvent('rsg-guitar:client:pickupGuitar', function()
    if not deployedGuitar then
        lib.notify({
            title = 'No Guitar!',
            description = 'There is no guitar to pick up.',
            type = 'error'
        })
        return
    end

    if isPlaying then
        lib.notify({
            title = 'Cannot Pick Up',
            description = 'You cannot pick up the guitar while playing it.',
            type = 'error'
        })
        return
    end

    local ped = PlayerPedId()
    LocalPlayer.state:set('inv_busy', true, true)
    TaskStartScenarioInPlace(ped, GetHashKey('WORLD_HUMAN_CROUCH_INSPECT'), -1, true, false, false, false)
    Wait(2000)

    if deployedGuitar then
        DeleteObject(deployedGuitar)
        deployedGuitar = nil
        deployedOwner = nil
        TriggerServerEvent('rsg-guitar:server:returnGuitar', deployedOwner)
    end

    ClearPedTasks(ped)
    LocalPlayer.state:set('inv_busy', false, true)

    
end)


AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    if deployedGuitar then
        DeleteObject(deployedGuitar)
        deployedGuitar = nil
    end
    if isPlaying then
        local ped = PlayerPedId()
        ClearPedTasksImmediately(ped)
        ClearPedSecondaryTask(ped)
        TaskClearLookAt(ped)
        isPlaying = false
    end
end)


CreateThread(function()
    RegisterGuitarTargeting()
end)


RegisterNetEvent('rsg-guitar:client:openGuitarMenu', function()
    ShowGuitarMenu()
end)