ESX = nil

Citizen.CreateThread(function ()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

local Vehicles1 = {}
local Max1
local Vehicles2 = {}
local Max2
local Vehicles3 = {}
local Max3
local inUse = nil
local Veiculos = {nil, nil, nil}
local canSpawn = true

RegisterNetEvent('pb_cardealer:sendVehicles')
AddEventHandler('pb_cardealer:sendVehicles', function (vehicles, max, type)
  if type == 1 then
	  Vehicles1 = vehicles
    Max1 = max
  elseif type == 2 then
	  Vehicles2 = vehicles
    Max2 = max
  elseif type == 3 then 
	  Vehicles3 = vehicles
    Max3 = max
  end
end)

local coordonate = {
  {143.17,-159.72,53.79,333.92,0x9760192E,"cs_bankman", true},
  {135.52,-156.64,53.79,329.64,0xB3B3F5E6,"a_m_y_business_02", true},
	{127.79,-153.57,53.79,321.47,0x9760192E,"cs_bankman", true}
}

Citizen.CreateThread(function()

    for _,v in pairs(coordonate) do
      RequestModel(GetHashKey(v[6]))
      while not HasModelLoaded(GetHashKey(v[6])) do
        Wait(1)
      end
  
      RequestAnimDict("mini@strip_club@idles@bouncer@base")
      while not HasAnimDictLoaded("mini@strip_club@idles@bouncer@base") do
        Wait(1)
      end

      ped =  CreatePed(4, v[5],v[1],v[2],v[3], 3374176, false, true)
      SetEntityHeading(ped, v[4])
      FreezeEntityPosition(ped, true)
      SetEntityInvincible(ped, true)
      SetBlockingOfNonTemporaryEvents(ped, true)
      -- TaskPlayAnim(ped,"mini@strip_club@idles@bouncer@base","base", 8.0, 0.0, -1, 1, 0, 0, 0, 0)
    end
end)

RegisterNetEvent("pb_cardealer:vehicle1")
AddEventHandler("pb_cardealer:vehicle1", function()
  ESX.TriggerServerCallback('pb_cardealer:InUse', function(InUse) 
    if not InUse then
      inUse = 1
      TriggerServerEvent('pb_cardealer:True', inUse)
      CreateCam(1)
      SetNuiFocus(true, true)
      ExecuteCommand("hud")
      SendNUIMessage({
        type = "cars",
        id = 1,
        cars = Vehicles1,
        max = Max1
      })
    else
      exports['okokNotify']:Alert("ERRO", "Aguarda até o funcionario estar disponível!", 5000, 'error')  
    end
  end, 1)
end)

RegisterNetEvent("pb_cardealer:vehicle2")
AddEventHandler("pb_cardealer:vehicle2", function()
  ESX.TriggerServerCallback('pb_cardealer:InUse', function(InUse) 
    if not InUse then
      inUse = 2
      TriggerServerEvent('pb_cardealer:True', inUse)
      CreateCam(2)
      SetNuiFocus(true, true)
      ExecuteCommand("hud")
      SendNUIMessage({
        type = "cars",
        id = 2,
        cars = Vehicles2,
        max = Max2
      })
    else
      exports['okokNotify']:Alert("ERRO", "Aguarda até o funcionario estar disponível!", 5000, 'error')  
    end
  end, 2)
end)

RegisterNetEvent("pb_cardealer:vehicle3")
AddEventHandler("pb_cardealer:vehicle3", function()
  ESX.TriggerServerCallback('pb_cardealer:InUse', function(InUse) 
    if (not InUse) then
      inUse = 3
      TriggerServerEvent('pb_cardealer:True', inUse)
      CreateCam(3)
      SetNuiFocus(true, true)
      ExecuteCommand("hud")
      SendNUIMessage({
        type = "cars",
        id = 3,
        cars = Vehicles3,
        max = Max3
      })
    else
      exports['okokNotify']:Alert("ERRO", "Aguarda até o funcionario estar disponível!", 5000, 'error')  
    end
  end, 3)
end)

local cam
local heading = 148.14

function CreateCam(i)
  local coords = {vector3(143.95, -160.23, 54.99), vector3(135.75, -157.1, 54.99), vector3(128.09, -154.02, 54.99)}
	cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", coords[i], 0, 0, heading, 100.00, false, 0)
	SetCamActive(cam, true)
  RenderScriptCams(true, false, 2000, true, true)
end

RegisterNUICallback("FecharC", function(data)
  TriggerEvent('ClearArea', data.tipo)
  SetNuiFocus(false, false)
  RenderScriptCams(0)
  TriggerServerEvent('pb_cardealer:False', inUse)
  inUse = nil
end)

-- Create Blips
Citizen.CreateThread(function ()
	local blip = AddBlipForCoord(136.46, -148.9, 54.86)

	SetBlipSprite (blip, 326)
	SetBlipDisplay(blip, 4)
	SetBlipScale  (blip, 0.8)
	SetBlipAsShortRange(blip, true)

	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString('Concessionária')
	EndTextCommandSetBlipName(blip)
end)

RegisterNetEvent('ClearArea')
AddEventHandler('ClearArea', function(i)
  local coords = {vector3(142.17, -162.95, 53.74), vector3(134.28, -160.63, 53.74), vector3(126.49, -157.56, 53.74)}
  local vehicles = ESX.Game.GetVehiclesInArea(coords[i], 2)
  for k,entity in ipairs(vehicles) do
    local attempt = 0

    while not NetworkHasControlOfEntity(entity) and attempt < 100 and DoesEntityExist(entity) do
      Citizen.Wait(100)
      NetworkRequestControlOfEntity(entity)
      attempt = attempt + 1
    end

    if DoesEntityExist(entity) and NetworkHasControlOfEntity(entity) then
      ESX.Game.DeleteVehicle(entity)
    end
  end
  ESX.Game.DeleteVehicle(Veiculos[inUse])
end)

RegisterNUICallback("SpawnCar", function(data)
  if canSpawn then
    TriggerEvent('ClearArea', data.tipo)
    canSpawn = false
    local coords = {vector3(142.17, -162.95, 53.74), vector3(134.28, -160.63, 53.74), vector3(126.49, -157.56, 53.74)}
    ESX.Game.SpawnVehicle(data.modelo, coords[data.tipo], 8.24, function (vehicle)
      Veiculos[inUse] = vehicle
      SetVehicleCustomPrimaryColour(vehicle, 255, 255, 255)
      SetVehicleNumberPlateText(vehicle, "SHOW")
      SetVehicleDoorShut(vehicle, 0, false)
      SetVehicleDoorShut(vehicle, 1, false)
      SetVehicleDoorShut(vehicle, 2, false)
      SetVehicleDoorShut(vehicle, 3, false)
      SetVehicleDoorsLocked(vehicle, 4)
      SetVehicleDoorsLockedForAllPlayers(vehicle, 4)
      Wait(500)
      canSpawn = true
    end)
  end
end)

RegisterNUICallback('TestDrive', function(data)
  ESX.TriggerServerCallback('pb_cardealer:HaveMoney', function(hasEnoughMoney)
    if hasEnoughMoney then
      local veh = data.modelo
      local playerPed = PlayerPedId()
      local testdrive_timer = 40

      ESX.Game.SpawnVehicle(veh, vector3(138.09, -122.2, 54.79), 63.2, function (vehicle)
        TaskWarpPedIntoVehicle(playerPed, vehicle, -1)

        SetVehicleCustomPrimaryColour(vehicle, 255, 255, 255)
        SetVehicleNumberPlateText(vehicle, "TEST")
        SetVehicleDoorShut(vehicle, 0, false)
        SetVehicleDoorShut(vehicle, 1, false)
        SetVehicleDoorShut(vehicle, 2, false)
        SetVehicleDoorShut(vehicle, 3, false)
        SetVehicleDoorsLocked(vehicle, 4)
        SetVehicleDoorsLockedForAllPlayers(vehicle, 4)
        SetVehicleAlarm(vehicle, 1)
        exports['okokNotify']:Alert("SUCCESSO", "TestDrive iniciado por <span style='color:#47cf73'>".. data.price .."</span>!!", 5000, 'success')
        exports['okokNotify']:Alert("INFO", "Tens "..testdrive_timer.." segundos restantes!!", 5000, 'info')
        Citizen.CreateThread(function ()
          local counter = testdrive_timer

          while counter > 0 do
            counter = counter -1
            if (counter == testdrive_timer / 2) then
              exports['okokNotify']:Alert("INFO", "Tens "..(testdrive_timer / 2).." segundos restantes!!", 5000, 'info')
            elseif (counter == testdrive_timer / 4) then
              exports['okokNotify']:Alert("INFO", "Tens "..(testdrive_timer / 4).." segundos restantes!!", 5000, 'info')
            elseif (counter == 5) then
              exports['okokNotify']:Alert("INFO", "Tens "..(testdrive_timer / 8).." segundos restantes!!", 5000, 'info')
            end
            Citizen.Wait(1000)
          end
          DeleteVehicle(vehicle)
          SetEntityCoords(playerPed, 136.46, -148.9, 54.86, false, false, false, false)

          exports['okokNotify']:Alert("SUCCESSO", "Test Drive terminado!!", 5000, 'success')
        end)
      end)
      SendNUIMessage({type = "close"})
    else
      exports['okokNotify']:Alert("ERRO", "Não tens dinheiro suficiente!", 5000, 'error')
    end
  end, data.price, exports["pb-inventory"]:getQuantity("money",false))
end)

RegisterNUICallback('BuyVehicle', function(data, cb)
  local playerPed = PlayerPedId()

  ESX.TriggerServerCallback('pb_cardealer:HaveMoney', function(hasEnoughMoney)

    if hasEnoughMoney then

      ESX.Game.SpawnVehicle(data.modelo, vector3(138.09, -122.2, 54.79), 63.2, function (vehicle)
        TaskWarpPedIntoVehicle(playerPed, vehicle, -1)

        SetVehicleCustomPrimaryColour(vehicle, 255, 255, 255)
        local newPlate     = GeneratePlate()
        local vehicleProps = ESX.Game.GetVehicleProperties(vehicle)
        vehicleProps.plate = newPlate
        SetVehicleNumberPlateText(vehicle, newPlate)

      
        TriggerServerEvent('pb_cardealer:setVehicleOwned', vehicleProps)
        TriggerEvent( "player:receiveItem", "carkey", 1 , {}, {plate = vehicleProps.plate, model = data.nome})

        exports['okokNotify']:Alert("SUCCESSO", "Compras-te um novo veículo por <span style='color:#47cf73'>".. data.price .."</span>!!", 5000, 'success')
      end)
      SendNUIMessage({type = "close"})
    else
      exports['okokNotify']:Alert("ERRO", "Não tens dinheiro suficiente!", 5000, 'error')
    end

  end, data.price, exports["pb-inventory"]:getQuantity("money",false))
end)

local alreadyOpen = false

RegisterNetEvent('OpenKeys')
AddEventHandler('OpenKeys', function()
  if not alreadyOpen then
    TriggerEvent('pbkeys:OpenUI', 1)
  end
end)

RegisterNetEvent('nh-context:onClose')
AddEventHandler('nh-context:onClose', function()
  alreadyOpen = false
end)

RegisterNetEvent('pbkeys:OpenUI')
AddEventHandler('pbkeys:OpenUI', function(data)
    alreadyOpen = true
    local i
    if data == 1 then
        i = 1
    else
        i = data.value
        garage = data.garage
    end
    local elements = {}
    ESX.TriggerServerCallback('pbcardealer:getOwnedVehicles', function(ownedCars)
        if #ownedCars == 0 then 
            exports['okokNotify']:Alert("Erro", "Não tens carros!", 5000, 'error')
        else
            table.insert(elements, {id=0, header="Comprar Chaves($500): ", txt = ""})
            for k,v in pairs(ownedCars) do
                if k >= (i-1) * 10 and k < i * 10 then
                    local vehName = GetLabelText(GetDisplayNameFromVehicleModel(v.vehicle.model))
                    table.insert(elements, {id=k, header = vehName, txt = ("Placa: "..v.plate), params = {event = "pbkeys:BuyKey", args = {value = v, name = vehName}}})
                end
            end
            if i == 1 then
                if #ownedCars > 9 then
                    table.insert(elements, {id=(i*10)+1, header="Página Seguinte >> ", txt = "", params = {event = "pbkeys:OpenUI", args = {value = i+1, garage = garage}}})
                end
            else
                if #ownedCars > (((i-1) * 10) + 9) then
                    table.insert(elements, {id=(i*10)+1, header="Página Seguinte >> ", txt = "", params = {event = "pbkeys:OpenUI", args = {value = i+1, garage = garage}}})
                end
                table.insert(elements, {id=(i*10)+2, header="<< Página Anterior", txt = "", params = {event = "pbkeys:OpenUI", args = {value = i-1, garage = garage}}})
            end
            TriggerEvent('nh-context:sendMenu', elements)
        end
    end)
end)

RegisterNetEvent('pbkeys:BuyKey')
AddEventHandler('pbkeys:BuyKey', function(data)
  TriggerEvent('nh-context:onClose')
  ESX.TriggerServerCallback('pb_cardealer:HaveMoney', function(canBuy) 
    if canBuy then
      TriggerEvent( "player:receiveItem", "carkey", 1 , {}, {plate = data.value.plate, model = data.name})
      exports['okokNotify']:Alert("SUCCESSO", "Compras-te a chave do veículo por <span style='color:#47cf73'>500$</span>!!", 5000, 'success')
    else
      exports['okokNotify']:Alert("ERRO", "Não tens dinheiro suficiente!", 5000, 'error')
    end
  end, 500, exports["pb-inventory"]:getQuantity("money",false))
  
end)