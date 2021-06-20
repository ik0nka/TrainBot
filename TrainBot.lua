script_name('Train bot for Arizona-RP')
script_version("1.1")
script_author("ik0nka and Gruzin Gang")

require "lib.moonloader"
local imgui = require 'imgui'
local encoding = require 'encoding'
local samp = require 'lib.samp.events'
local memory = require 'memory'
local dlstatus = require('moonloader').download_status
encoding.default = 'CP1251'
u8 = encoding.UTF8

update_state = false
local script_vers = 2
local script_vers_text = "1.1"
local update_url = "https://raw.githubusercontent.com/ik0nka/TrainBot/main/update.ini"
local update_path = getWorkingDirectory() .. "/update.ini"
local script_url = "https://raw.githubusercontent.com/ik0nka/TrainBot/main/TrainBot.lua"
local script_path = thisScript().path

local window = imgui.ImBool(false)
local window_stats = imgui.ImBool(false)

local TrainBot = imgui.ImBool(false)
local AutoRes = imgui.ImBool(false)
local Statistik = imgui.ImBool(false)
local AntiAfk = imgui.ImBool(false)


local menu = 0

function main()
    while not isSampAvailable() do wait(200) end
    imgui.Process = false
    sampAddChatMessage('{FFFFFF}[{E06666}TrainBot{FFFFFF}] Бот успешно загружен', -1)
    sampAddChatMessage('{FFFFFF}[{E06666}TrainBot{FFFFFF}] Авторы: {FFFF00}ik0nka,{FFAD40} Gruzin Gang', -1)
    sampRegisterChatCommand('train', function()
        window.v = not window.v
    end)
    while true do
        wait(0)
        imgui.Process = window.v
        if TrainBot.v and isCharInAnyTrain(PLAYER_PED) then
            local x, y, z = getCharCoordinates(PLAYER_PED) 
            local BoostTrain = storeCarCharIsInNoSave(PLAYER_PED)
            if getDistanceBetweenCoords3d(x, y, z, chkx, chky, chkz) < 3 and isCharInAnyTrain(PLAYER_PED) then
                setTrainSpeed(BoostTrain, 0)
            elseif getDistanceBetweenCoords3d(x, y, z, chkx, chky, chkz) > 10 and isCharInAnyTrain(PLAYER_PED) then
                setTrainSpeed(BoostTrain, 35)
            end
        end
        if AutoRes.v and TrainBot.v and not isCharInAnyCar(PLAYER_PED) then
            setCharCoordinates(PLAYER_PED, -2262.91, 507.04, 1485.69)
            wait(500)
            setGameKeyState(21, 255)
			wait(0)
			setGameKeyState(21, 0)
            wait(200)
        end
        if Statistik.v and isCharInAnyTrain(PLAYER_PED) then
            local x, y, z = getCharCoordinates(PLAYER_PED) 
            local dist = getDistanceBetweenCoords3d(x, y, z, chkx, chky, chkz)
            local LockTrain = storeCarCharIsInNoSave(PLAYER_PED)
            local printspeed = getCarSpeed(LockTrain)
            printStringNow('Dist:'..math.floor(dist)..' Speed: '..math.floor(printspeed))
        end
        if AntiAfk.v then 
            writeMemory(7634870, 1, 1, 1)
            writeMemory(7635034, 1, 1, 1)
            memory.fill(7623723, 144, 8)
            memory.fill(5499528, 144, 6)
        else
            writeMemory(7634870, 1, 0, 0)
            writeMemory(7635034, 1, 0, 0)
            memory.hex2bin('5051FF1500838500', 7623723, 8)
            memory.hex2bin('0F847B010000', 5499528, 6)
        end
        if update_state then
            downloadUrlToFile(script_url, script_path, function(id, status)
                if status == dlstatus.STATUS_ENDDOWNLOADDATA then
                    sampAddChatMessage("Обновление прошло успешно!", -1)
                    thisScript():reload()
                end
            end)
            break
        end
    end
end

function imgui.OnDrawFrame()
    if not window.v and not window_stats.v then 
        imgui.Process = false
    end
    if window.v then
        imgui.SetNextWindowPos(imgui.ImVec2(350.0, 250.0), imgui.Cond.FirstUseEver)
        imgui.SetNextWindowSize(imgui.ImVec2(360.0, 200.0), imgui.Cond.FirstUseEver)

        imgui.Begin('Train Bot', window)
        if imgui.Button(u8'Бот', imgui.ImVec2(100, 0)) then 
            menu = 0
        end
        imgui.SameLine(0, 15)
        if imgui.Button(u8'Настройки', imgui.ImVec2(100, 0)) then 
            menu = 1
        end
        imgui.SameLine(0, 15)
        if imgui.Button(u8'О скрипте', imgui.ImVec2(100, 0)) then 
            menu = 2
        end

        imgui.Spacing() imgui.Separator() imgui.Spacing()
        if menu == 0 then
            imgui.Checkbox(u8'Бот', TrainBot)
            imgui.Checkbox(u8'Авто взятие рейса', AutoRes) 
            imgui.Checkbox(u8'Статистика', Statistik)
        elseif menu == 1 then
            imgui.Checkbox(u8'Анти-Афк', AntiAfk)
        elseif menu == 2 then
            imgui.Text(u8'Авторы: ik0nka, Gruzin Gang')
            imgui.Text(u8'Версия скрипта: 1.1')
            imgui.SameLine(0, 15)
            if imgui.Button(u8'Проверить обновление', imgui.ImVec2(145, 20)) then
                downloadUrlToFile(update_url, update_path, function(id, status)
                    if status == dlstatus.STATUS_ENDDOWNLOADDATA then
                        updateIni = inicfg.load(nil, update_path)
                        if tonumber(updateIni.info.vers) > script_vers then
                            sampAddChatMessage("Вышла новая версия! Номер версии: " .. updateIni.info.vers_text, -1)
                            update_state = true
                        end
                        os.remove(update_path)
                    end
                end)
            end
        end

        imgui.End()
    end
    if window_stats.v == true then
        imgui.Begin('Stats', window_stats)
        imgui.Text(u8'разработка')

        imgui.End()
    end
end

function samp.onShowDialog(id, style, title, but_1, but_2, text)
	if AutoRes.v and id == 4297 then
		sampSendDialogResponse(id, 1, nil, nil)
		return false
	end
    if AutoRes.v and id == 4296 then
		sampSendDialogResponse(id, 1, nil, nil)
		return false
	end
end

function samp.onSendVehicleSync(data)
    if TrainBot.v then
        local LockTrain = storeCarCharIsInNoSave(PLAYER_PED)
        local rspeed = getCarSpeed(LockTrain)
        if rspeed > 20 then
            data.moveSpeed.x = 0
            data.moveSpeed.y = 0.33498126268
            data.moveSpeed.z = 0.00167687726
        end
    end
end

function samp.onSetRaceCheckpoint(type, pos, nextpos, radius)
    chkx = pos.x
    chky = pos.y
    chkz = pos.z
    print(chkx..' '..chky)
end

function apply_custom_style()
    imgui.SwitchContext()
    local style = imgui.GetStyle()
    local colors = style.Colors
    local clr = imgui.Col
    local ImVec4 = imgui.ImVec4
    local ImVec2 = imgui.ImVec2
 
     style.WindowPadding = ImVec2(15, 15)
     style.WindowRounding = 15.0
     style.FramePadding = ImVec2(5, 5)
     style.ItemSpacing = ImVec2(12, 8)
     style.ItemInnerSpacing = ImVec2(8, 6)
     style.IndentSpacing = 25.0
     style.ScrollbarSize = 15.0
     style.ScrollbarRounding = 15.0
     style.GrabMinSize = 15.0
     style.GrabRounding = 7.0
     style.ChildWindowRounding = 8.0
     style.FrameRounding = 6.0
   
 
       colors[clr.Text] = ImVec4(0.95, 0.96, 0.98, 1.00)
       colors[clr.TextDisabled] = ImVec4(0.36, 0.42, 0.47, 1.00)
       colors[clr.WindowBg] = ImVec4(0.11, 0.15, 0.17, 1.00)
       colors[clr.ChildWindowBg] = ImVec4(0.15, 0.18, 0.22, 1.00)
       colors[clr.PopupBg] = ImVec4(0.08, 0.08, 0.08, 0.94)
       colors[clr.Border] = ImVec4(0.43, 0.43, 0.50, 0.50)
       colors[clr.BorderShadow] = ImVec4(0.00, 0.00, 0.00, 0.00)
       colors[clr.FrameBg] = ImVec4(0.20, 0.25, 0.29, 1.00)
       colors[clr.FrameBgHovered] = ImVec4(0.12, 0.20, 0.28, 1.00)
       colors[clr.FrameBgActive] = ImVec4(0.09, 0.12, 0.14, 1.00)
       colors[clr.TitleBg] = ImVec4(0.09, 0.12, 0.14, 0.65)
       colors[clr.TitleBgCollapsed] = ImVec4(0.00, 0.00, 0.00, 0.51)
       colors[clr.TitleBgActive] = ImVec4(0.08, 0.10, 0.12, 1.00)
       colors[clr.MenuBarBg] = ImVec4(0.15, 0.18, 0.22, 1.00)
       colors[clr.ScrollbarBg] = ImVec4(0.02, 0.02, 0.02, 0.39)
       colors[clr.ScrollbarGrab] = ImVec4(0.20, 0.25, 0.29, 1.00)
       colors[clr.ScrollbarGrabHovered] = ImVec4(0.18, 0.22, 0.25, 1.00)
       colors[clr.ScrollbarGrabActive] = ImVec4(0.09, 0.21, 0.31, 1.00)
       colors[clr.ComboBg] = ImVec4(0.20, 0.25, 0.29, 1.00)
       colors[clr.CheckMark] = ImVec4(0.28, 0.56, 1.00, 1.00)
       colors[clr.SliderGrab] = ImVec4(0.28, 0.56, 1.00, 1.00)
       colors[clr.SliderGrabActive] = ImVec4(0.37, 0.61, 1.00, 1.00)
       colors[clr.Button] = ImVec4(0.20, 0.25, 0.29, 1.00)
       colors[clr.ButtonHovered] = ImVec4(0.28, 0.56, 1.00, 1.00)
       colors[clr.ButtonActive] = ImVec4(0.06, 0.53, 0.98, 1.00)
       colors[clr.Header] = ImVec4(0.20, 0.25, 0.29, 0.55)
       colors[clr.HeaderHovered] = ImVec4(0.26, 0.59, 0.98, 0.80)
       colors[clr.HeaderActive] = ImVec4(0.26, 0.59, 0.98, 1.00)
       colors[clr.ResizeGrip] = ImVec4(0.26, 0.59, 0.98, 0.25)
       colors[clr.ResizeGripHovered] = ImVec4(0.26, 0.59, 0.98, 0.67)
       colors[clr.ResizeGripActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
       colors[clr.CloseButton] = ImVec4(0.40, 0.39, 0.38, 0.16)
       colors[clr.CloseButtonHovered] = ImVec4(0.40, 0.39, 0.38, 0.39)
       colors[clr.CloseButtonActive] = ImVec4(0.40, 0.39, 0.38, 1.00)
       colors[clr.PlotLines] = ImVec4(0.61, 0.61, 0.61, 1.00)
       colors[clr.PlotLinesHovered] = ImVec4(1.00, 0.43, 0.35, 1.00)
       colors[clr.PlotHistogram] = ImVec4(0.90, 0.70, 0.00, 1.00)
       colors[clr.PlotHistogramHovered] = ImVec4(1.00, 0.60, 0.00, 1.00)
       colors[clr.TextSelectedBg] = ImVec4(0.25, 1.00, 0.00, 0.43)
       colors[clr.ModalWindowDarkening] = ImVec4(1.00, 0.98, 0.95, 0.73)
 end
 apply_custom_style()