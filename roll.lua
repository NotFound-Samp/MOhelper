script_name('RollForMOhelper')
script_author('NotFound')
script_version(script_vers_roll_text)

require "lib.moonloader"
require "lib.sampfuncs"
local dlstatus = require('moonloader').download_status
local pie = require 'imgui_piemenu'
local themes = import "resources/imgui_themes.lua"
local imgui = require 'imgui'
local key = require 'vkeys'
local encoding = require 'encoding'
imgui.BufferingBar = require('imgui_addons').BufferingBar
encoding.default = 'CP1251'
u8 = encoding.UTF8

local ffi = require 'ffi'
ffi.cdef [[
bool SetCursorPos(int X, int Y);
]]

local main_color = 0x5A90CE
local inicfg = require 'inicfg'
local directIni = 'moonloader\\settings.ini'

--[[Для автообсновления
update_state = false

local script_roll_vers = 1
local script_vers_roll_text = "2.1"

local update_url = "https://raw.githubusercontent.com/NotFound-Samp/MOhelper/main/update.ini" -- тут тоже свою ссылку
local update_path = getWorkingDirectory() .. "/update.ini" -- и тут свою ссылку

local script_url = "https://github.com/NotFound-Samp/MOhelper/blob/main/roll.luac?raw=true" -- тут свою ссылку
local script_path = thisScript().path
]]

local x, y = getScreenResolution()

ini = inicfg.load({
	main = {
		theme = 1,
		position = "None",
		subdivision = "None",
		rang = "None",
	},
	auto = {
		conf1 = false,
		conf2 = false,
		conf3 = false,
		conf4 = false,
        f = false,
        r = false,
	},
}, directIni)
inicfg.save(ini, directIni)


local mainIni = inicfg.load(nil, directIni)
local pie_mode = imgui.ImBool(false) -- режим PieMenu
local pie_keyid = 0 -- 0 ЛКМ, 1 ПКМ, 2 СКМ

local coordinates =
{
  -- {x1, y1, z1, x2, y2, z2, 'base', 'name', false/true}
  --Авик

  {-1214, 537, -34, -1736, 261, 94, 'Авианосца'},
  {-1334, 455, 28, -1482, 340, 36, 'Авианосца', 'Ангар-Б'},
  {-1486, 360, 50, -1532, 467, 30, 'Авианосца','Ангар-А'},
  {-1573, 360, 50, -1469, 280, 60, 'Авианосца','Ангар-С'},
  {-1567, 445, 7, -1517, 503, 27, 'Авианосца','КПП'},
  {-1525, 380, 7, -1641, 360, 10, 'Авианосца','Нижнее'},
  {-1609, 359, 7, -1690, 329, 10, 'Авианосца','Нижнее'},
  {-1733, 263, 7, -1328, 328, 10, 'Авианосца','Нижнее'},
  {-1329, 345, 7, -1328, 442, 16, 'Авианосца','Внутри Ангаров'},
  {-1685, 460, 15, -1478, 596, 35, 'Авианосца','ЖД'},
  {-1352, 473, 7, -1320, 492, 12, 'Авианосца','Вход А'},
  {-1321, 488, 21, -1406, 504, 59, 'Авианосца','Рубка'},
  {-1244, 515, 20, -1467, 486, 16, 'Авианосца','ВПП'},
  {-1467, 489, 11, -1284, 515, 15, 'Авианосца','Средняя Палуба'},
  {-1387, 488, 7, -1473, 519, -5, 'Авианосца','Лодочная'},
  --СВ

  {38, 2091, -50, 390, 1767, 75, 'Базы СВ'},
  {341, 1789, 10, 351, 1822, 40, 'Базы СВ', 'КПП-1'},
  {59, 1918, 10, 36, 1888, 40, 'Базы СВ', 'КПП-2'},
  {59, 2039, 10, 38, 2088, 40, 'Базы СВ', 'КПП-3'},
  {311, 1924, 10, 323, 1884, 40, 'Базы СВ', 'Главный Склад'},
  --ВВС
  {470, 2583, 88, 79, 2335, 10, 'Базы ВВС'},
  {-114, 2575, 10, 78, 2335, 79, 'Базы ВВС'},
  {442, 2548, 10, 458, 2572, 33, 'Базы ВВС', 'КПП-1'},
  {-114, 2575, 25, -86, 2550, 10, 'Базы ВВС', 'КПП-2'},
  {220, 2477, 10, 207, 2456, 21, 'Базы ВВС', 'Главный Склад'},
  --ВМФ
  {-2155, 2198, 0, -2339, 2344, 75, 'Базы ВМФ'},
  {-2283, 2345, 0, -2263, 2525, 75, 'Базы ВМФ'},
  {-2294, 2344, 0, -2264, 2357, 75, 'Базы ВМФ', 'КПП'},
  {-2309, 2313, 0, -2276, 2335, 75, 'Базы ВМФ', 'Главный Склад'},
	--Важное место
  {1694, 2582, 0, 1649, 2551, 75, 'Дом Эстрады'},
}

local position = u8:decode(ini.main.position)
local autof = (ini.auto.f)

local pie_elements =
{
  {name = 'lock', action = function() end, next = {
    {name = 'lock 1', action = function() sampSendChat('/lock 1') end, next = nil},
    {name = 'lock 6', action = function() sampSendChat('/lock 6') end, next = nil},
}},
  {name = 'fast', action = function() end, next = {
    {name = 'heal', action = function() sampSendChat('/me достал обезбаливающее и принял его.') sampSendChat('/healme') end, next = nil},
    {name = 'mask', action = function() sampSendChat('/me надел балаклаву.') sampSendChat('/mask') sampSendChat('/reset') end, next = nil},
    {name = 'fix', action = function() sampSendChat('/fix') end, next = nil},
}},
  {name = 'Kit', action = function() end, next = {
      {name = 'ЗК', action = function()
				if not autof then
					if base and name then sampSendChat('/f Докладываю: Охрана ' .. base ..' | Пост: ' .. name ..' | Состояние: ЗК.', -1)
	        elseif base then sampSendChat('/f Докладываю: Охрана ' .. base .. ' | Состояние: ЗК.', -1)
	        else sampAddChatMessage('Вне зоны', -1) end
				else
        	if base and name then sampSendChat('/f ' .. position .. ' Докладываю: Охрана ' .. base ..' | Пост: ' .. name ..' | Состояние: ЗК.', -1)
        	elseif base then sampSendChat('/f ' .. position .. ' Докладываю: Охрана ' .. base .. ' | Состояние: ЗК.', -1)
        	else sampAddChatMessage('Вне зоны', -1) end end end, next = nil},
      {name = 'ЖК', action = function()
				if not autof then
        	if base and name then sampSendChat('/f Докладываю: Охрана ' .. base ..' | Пост: ' .. name ..' | Состояние: ЖК.')
        	elseif base then sampSendChat('/f Докладываю: Охрана ' .. base .. ' | Состояние: ЖК.')
        	else sampAddChatMessage('Вне зоны', -1) end
				else
					if base and name then sampSendChat('/f ' .. position .. ' Докладываю: Охрана ' .. base ..' | Пост: ' .. name ..' | Состояние: ЖК.')
        	elseif base then sampSendChat('/f ' .. position .. ' Докладываю: Охрана ' .. base .. ' | Состояние: ЖК.')
        	else sampAddChatMessage('Вне зоны', -1) end end end, next = nil},
      {name = 'КК', action = function()
				if not autof then
        	if base and name then sampSendChat('/f Докладываю: Охрана ' .. base ..' | Пост: ' .. name ..' | Состояние: КК.')
        	elseif base then sampSendChat('/f Докладываю: Охрана ' .. base .. ' | Состояние: КК.')
        	else sampAddChatMessage('Вне зоны', -1) end
				else
					if base and name then sampSendChat('/f ' .. position .. ' Докладываю: Охрана ' .. base ..' | Пост: ' .. name ..' | Состояние: КК.')
        	elseif base then sampSendChat('/f ' .. position .. ' Докладываю: Охрана ' .. base .. ' | Состояние: КК.')
        	else sampAddChatMessage('Вне зоны', -1) end end end, next = nil},
    },
  },
  --{name = 'test', action = function() sampSendChat('[' .. position .. ']: Докладываю: Охрана Авианосца | Пост: КПП-А | Состояние: ЗК') end, next = nil},
  {name = 'gate', action = function() sampSendChat('/gate') end, next = nil},
  {name = 'MO', action = function() --[[runSampfuncsConsoleCommand("0afd:68")]] sampProcessChatInput('/mo') end, next = nil},
}

function main()
	--[[downloadUrlToFile(update_url, update_path, function(id, status)
			if status == dlstatus.STATUS_ENDDOWNLOADDATA then
					updateIni = inicfg.load(nil, update_path)
					if tonumber(updateIni.info.roll_vers) > script_roll_vers then
							sampAddChatMessage("RollForMOhelper обновился! Версия: " .. updateIni.info.vers_roll_text, main_color)
							update_state = true
					end
					os.remove(update_path)
			end
	end)]]


  imgui.Process = true
  imgui.SwitchContext()
  themes.SwitchColorTheme(ini.main.theme)

    while true do
        wait(0)

				--[[if update_state then
					downloadUrlToFile(script_url, script_path, function(id, status)
						if status == dlstatus.STATUS_ENDDOWNLOADDATA then
							sampAddChatMessage("Скрипт успешно обновлен!", main_color)
							thisScript():reload()
						end
					end)
					break
				end]]

        pie_mode.v = isKeyDown(key.VK_X) and not sampIsChatInputActive() and not sampIsDialogActive() and true or false
        imgui.ShowCursor = pie_mode.v
        result, base, name = checkArea()
        if not result then
          base, name = nil, nil
        end
    end
end

function imgui.OnDrawFrame()
    if pie_mode.v then
        imgui.OpenPopup('PieMenu')
        if pie.BeginPiePopup('PieMenu', pie_keyid) then
          for k, v in ipairs(pie_elements) do
            if v.next == nil then
              if pie.PieMenuItem(u8(v.name)) then v.action() end
            elseif type(v.next) == 'table' then drawPieSub(v) end
          end
          pie.EndPiePopup()
        end
    end
end

function drawPieSub(v)
  if pie.BeginPieMenu(u8(v.name)) then
    for i, l in ipairs(v.next) do
      if l.next == nil then
        if pie.PieMenuItem(u8(l.name)) then l.action() end
      elseif type(l.next) == 'table' then
        drawPieSub(l)
      end
    end
    pie.EndPieMenu()
  end
end

function checkArea()
  local en, baseZone, nameZone = false, nil, nil
  for i = 1, #coordinates do
    if isCharInArea3d(PLAYER_PED, coordinates[i][1], coordinates[i][2], coordinates[i][3], coordinates[i][4], coordinates[i][5], coordinates[i][6], false) then
      en = true; baseZone = coordinates[i][7]; nameZone = coordinates[i][8] end
  end
  return en, baseZone, nameZone;
end
