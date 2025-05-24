local RSGCore = exports['rsg-core']:GetCoreObject()


RSGCore.Functions.CreateUseableItem('guitar', function(source, item)
    local Player = RSGCore.Functions.GetPlayer(source)
    if not Player then return end
    TriggerClientEvent('rsg-guitar:client:openGuitarMenu', source)
end)


RegisterNetEvent('rsg-guitar:server:placementSuccess', function()
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    if not Player then return end
    if Player.Functions.RemoveItem('guitar', 1) then
        TriggerClientEvent('inventory:client:ItemBox', src, RSGCore.Shared.Items['guitar'], 'remove')
    else
        TriggerClientEvent('lib.notify', src, { title = 'Error', description = 'No guitar in inventory!', type = 'error' })
    end
end)


RegisterNetEvent('rsg-guitar:server:returnGuitar', function(ownerId)
    local src = source
    if src ~= ownerId then
        TriggerClientEvent('lib.notify', src, { title = 'Error', description = 'You can only pick up your own guitar!', type = 'error' })
        return
    end
    local Player = RSGCore.Functions.GetPlayer(src)
    if not Player then return end
    if Player.Functions.AddItem('guitar', 1) then
        TriggerClientEvent('inventory:client:ItemBox', src, RSGCore.Shared.Items['guitar'], 'add')
    else
        TriggerClientEvent('lib.notify', src, { title = 'Inventory Full', description = 'Cannot pick up guitar, inventory is full!', type = 'error' })
    end
end)