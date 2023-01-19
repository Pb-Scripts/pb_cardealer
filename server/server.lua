ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

local Using = {false, false, false}

ESX.RegisterServerCallback('pb_cardealer:isPlateTaken', function (source, cb, plate)
	MySQL.Async.fetchAll('SELECT * FROM owned_vehicles WHERE plate = @plate', {
		['@plate'] = plate
	}, function (result)
		cb(result[1] ~= nil)
	end)
end)

ESX.RegisterServerCallback('pb_cardealer:InUse', function (source, cb, veh)
	cb(Using[veh])
end)

RegisterNetEvent('pb_cardealer:False')
AddEventHandler('pb_cardealer:False', function(i)
	Using[i] = false
end)

RegisterNetEvent('pb_cardealer:True')
AddEventHandler('pb_cardealer:True', function(i)
	Using[i] = true
end)

ESX.RegisterServerCallback('pb_cardealer:HaveMoney', function (source, cb, price, money)
	local xPlayer     = ESX.GetPlayerFromId(source)

	if xPlayer.getAccount('bank').money >= price then
		TriggerEvent("okokBanking:TransferMoneyToSociety", price, "GOV", "Governo", "society_governo", "billing", source, "noui")
		cb(true)
	elseif money >= price then
		TriggerClientEvent("inventory:removeItem", source, 'money', price)
		TriggerEvent("okokBanking:TransferMoneyToSociety", price, "GOV", "Governo", "society_governo", "onlysend", source, "noui")
		cb(true)
	else	
		cb(false)
	end
end)

Citizen.CreateThread(function()
	MySQL.ready(function()
		local vehicles1 = MySQL.Sync.fetchAll('SELECT * FROM vehicles WHERE category = @type', {["@type"] = 1})
		local vehicles2 = MySQL.Sync.fetchAll('SELECT * FROM vehicles WHERE category = @type', {["@type"] = 2})
		local vehicles3 = MySQL.Sync.fetchAll('SELECT * FROM vehicles WHERE category = @type', {["@type"] = 3})
		local max1 = 0
		local max2 = 0
		local max3 = 0

		for i=1, #vehicles1, 1 do
			max1 = max1 + 1
		end

		for i=1, #vehicles2, 1 do
			max2 = max2 + 1
		end

		for i=1, #vehicles3, 1 do
			max3 = max3 + 1
		end

		-- send information after db has loaded, making sure everyone gets vehicle information
		TriggerClientEvent('pb_cardealer:sendVehicles', -1, vehicles1, max1, 1)
		TriggerClientEvent('pb_cardealer:sendVehicles', -1, vehicles2, max2, 2)
		TriggerClientEvent('pb_cardealer:sendVehicles', -1, vehicles3, max3, 3)
	end)
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(playerData)
    MySQL.ready(function()
        local vehicles1 = MySQL.Sync.fetchAll('SELECT * FROM vehicles WHERE category = @type', {["@type"] = 1})
        local vehicles2 = MySQL.Sync.fetchAll('SELECT * FROM vehicles WHERE category = @type', {["@type"] = 2})
        local vehicles3 = MySQL.Sync.fetchAll('SELECT * FROM vehicles WHERE category = @type', {["@type"] = 3})
        local max1 = 0
		local max2 = 0
		local max3 = 0

        for i=1, #vehicles1, 1 do
            max1 = max1 + 1
        end

		for i=1, #vehicles2, 1 do
            max2 = max2 + 1
        end

		for i=1, #vehicles3, 1 do
            max3 = max3 + 1
        end

        -- send information after db has loaded, making sure everyone gets vehicle information
        TriggerClientEvent('pb_cardealer:sendVehicles', -1, vehicles1, max1, 1)
		TriggerClientEvent('pb_cardealer:sendVehicles', -1, vehicles2, max2, 2)
		TriggerClientEvent('pb_cardealer:sendVehicles', -1, vehicles3, max3, 3)
    end)
end)

RegisterServerEvent('pb_cardealer:setVehicleOwned')
AddEventHandler('pb_cardealer:setVehicleOwned', function (vehicleProps)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)

	MySQL.Async.execute('INSERT INTO owned_vehicles (owner, plate, vehicle, job, stored) VALUES (@owner, @plate, @vehicle, @job, @stored)',
	{
		['@owner']   = xPlayer.identifier,
		['@plate']   = vehicleProps.plate,
		['@vehicle'] = json.encode(vehicleProps),
		['@job'] = 'civ',
		['@stored']  = 0
	}, function (rowsChanged)
	end)
end)

ESX.RegisterServerCallback('pbcardealer:getOwnedVehicles', function(source, cb)
    local ownedCars = {}
    local xPlayer = ESX.GetPlayerFromId(source)
    MySQL.Async.fetchAll('SELECT * FROM owned_vehicles WHERE owner = @owner AND job = @job', {
        ['@owner'] = xPlayer.identifier,
        ['@job'] = 'civ'
    }, function(result)
		for _,v in pairs(result) do
			local vehicle = json.decode(v.vehicle)
			table.insert(ownedCars, {vehicle = vehicle, stored = v.stored, plate = v.plate, fuel = v.fuel, health = v.engine})
		end
		cb(ownedCars)
    end)
end)