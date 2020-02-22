script_name("FBI Tools")
script_authors("Thomas Lawson, Sesh Jefferson, Edward Franklin")
script_version(3.33)
local test_version = 2

require 'lib.moonloader'
require 'lib.sampfuncs'

local lsg, sf               = pcall(require, 'sampfuncs')
local lkey, key             = pcall(require, 'vkeys')
local lmemory, memory       = pcall(require, 'memory')
local lsampev, sp           = pcall(require, 'lib.samp.events')
local lrkeys, rkeys         = pcall(require, 'rkeys')
local limadd, imadd         = pcall(require, 'imgui_addons')
local limgui, imgui         = pcall(require, 'imgui')
local lsha1, sha1           = pcall(require, 'sha1')
local lbasexx, basexx       = pcall(require, 'basexx')
local lcopas, copas         = pcall(require, "copas")
local lhttp, http           = pcall(require, 'copas.http')
local bNotf, notf           = pcall(import, "imgui_notf.lua")
local dlstatus              = require('moonloader').download_status
local wm                    = require 'lib.windows.message'
local gk                    = require 'game.keys'
local encoding              = require 'encoding'
local band                  = bit.band
encoding.default            = 'CP1251'
u8 = encoding.UTF8

local groupNames = {
    u8'��/���', u8'���������', u8'������', u8'�����', u8'�����'
}

local request_data = {
    members = 0,
    updated = 0,
    last_request = os.time(),
    last_online = os.time()
}

local cfg =
{
    main = {
        posX = 1566,
        posY = 916,
        widehud = 350,
        male = true,
        clear = false,
        hud = false,
        tar = '���',
        parol = '������',
        parolb = false,
        tarb = false,
        clistb = false,
        spzamen = false,
        clist = 0,
        offptrl = false,
        offwntd = false,
        tchat = false,
        autocar = false,
        strobs = true,
        megaf = true,
        autobp = false,
        googlecode = '',
        googlecodeb = false,
        group = 'unknown',
        nwanted = false,
        nclear = false,
        hudopacity = 1,
        hudrounding = 0,
        hudshowtitle = true,
        rpguns = true,
        modr = true,
        modm = true
    },
    commands = {
        cput = true,
        ceject = true,
        deject = true,
        ftazer = true,
        zaderjka = 1400,
        ticket = true,
        kmdctime = true
    },
    showhud = {true, true, true, true, true, true, true},
    autopbguns = {true,true,false,true,true,true,false}
}

sInfo = {
    flood = 0,
    weapon = 0
}

if limgui then 
    mainw           = imgui.ImBool(false)
    setwindows      = imgui.ImBool(false)
    shpwindow       = imgui.ImBool(false)
    ykwindow        = imgui.ImBool(false)
    fpwindow        = imgui.ImBool(false)
    akwindow        = imgui.ImBool(false)
    pozivn          = imgui.ImBool(false)
    updwindows      = imgui.ImBool(false)
    bMainWindow     = imgui.ImBool(false)
    bindkey         = imgui.ImBool(false)
    cmdwind         = imgui.ImBool(false)
    memw            = imgui.ImBool(false)
    sInputEdit      = imgui.ImBuffer(256)
    bIsEnterEdit    = imgui.ImBool(false)
    piew            = imgui.ImBool(false)
    imegaf          = imgui.ImBool(false)
    bindname        = imgui.ImBuffer(256)
    bindtext        = imgui.ImBuffer(20480)
    groupInt        = imgui.ImInt(0)
    editpost        = imgui.ImBool(false)
    postname        = imgui.ImBuffer(256)
    postcoords      = imgui.ImFloat3(0,0,0)
    rpedit          = imgui.ImBool(false)
    otigtext        = imgui.ImBuffer(10240)
    vars = {
        menuselect  = 0,
        mainwindow  = imgui.ImBool(false),
        cmdbuf      = imgui.ImBuffer(256),
        cmdparams   = imgui.ImInt(0),
        cmdtext     = imgui.ImBuffer(20480)
    }
end

function ftext(text)
    sampAddChatMessage((' %s | {ffffff}%s'):format(script.this.name, text),0x9966CC)
end

local config_keys = {
    oopda = { v = {key.VK_F12}},
    oopnet = { v = {key.VK_F11}},
    tazerkey = { v = {key.VK_X}},
    fastmenukey = { v = {key.VK_F2}},
    megafkey = { v = {18,77}},
    dkldkey = { v = {18,80}},
    cuffkey = { v = {}},
    followkey = { v = {}},
    cputkey = { v = {}},
    cejectkey = { v = {}},
    takekey = { v = {}},
    arrestkey = { v = {}},
    uncuffkey = { v = {}},
    dejectkey = { v = {}},
    sirenkey = { v = {}},
    hikey = {v = {key.VK_I}},
	summakey = {v = {key.VK_L}},
	freenalkey = {v = {key.VK_Y}},
    freebankkey = {v = {key.VK_U}},
    vzaimkey = {v = {key.VK_Z}},
    offotig = {v = {}}
}

local trash = {}

local mcheckb = false
local stazer = false
local rabden = false
local frak = -1
local rang = -1
local warnst = false
local changetextpos = false
local opyatstat = false
local gmegafid = -1
local targetid = -1
local smsid = -1
local smstoid = -1
local mcid = -1
local vixodid = {}
local ins = {}
local ooplistt = {}
local tLastKeys = {}
local departament = {}
local radio = {}
local sms = {}
local wanted = {}
local incar = {}
local suz = {}
local show = 1
local autoBP = 1
local autoBPCounter = 0
local checkstat = false
local fileb = getWorkingDirectory() .. "\\config\\fbitools.bind"
local tMembers = {}
local Player = {}
local tBindList = {}
local commands = {}
local fthelp = {
    {
        cmd = '/ft',
        desc = '������� ���� �������',
        use = '/ft'
    },
    {
        cmd = '/st',
        desc = '��������� ������ ��������� ���� �/� ����� ������� [/m]',
        use = '/st [id]'
    },
    {
        cmd = '/oop',
        desc = '�������� � ����� ������������ �� ���',
        use = '/oop [id]'
    },
    {
        cmd = '/warn',
        desc = '������������ ������ � ����� ������������ � ��������� ������ � ������',
        use = '/warn [id]'
    },
    {
        cmd = '/su',
        desc = '������ ������ ����� ������',
        use = '/su [id]'
    },
    {
        cmd = '/ssu',
        desc = '������ ������ ����� ��������� �������',
        use = '/ssu [id] [���-�� �����] [�������]'
    },
    {
        cmd = '/cput',
        desc = '�� ��������� ������� ����������� � ����������/����',
        use = '/cput [id] [�������(�� �����������)]'
    },
    {
        cmd = '/ceject',
        desc = '�� ��������� ������� ����������� �� ����������/����',
        use = '/ceject [id]'
    },
    {
        cmd = '/deject',
        desc = '�� ��������� ������������ ����������� �� ����������/����',
        use = '/deject [id]'
    },
    {
        cmd = '/ms',
        desc = '�� ��������� ������ ����������',
        use = '/ms [���]'
    },
    {
        cmd = '/keys',
        desc = "�� ��������� ��������� ������ �� ���",
        use = '/keys'
    },
    {
        cmd = '/rh',
        desc = "��������� ���������� ������ � ������� �������",
        use = "/rh [�����������(1 - LSPD, 2 - SFPD, 3 - LVPD)]"
    },
    {
        cmd = '/tazer',
        desc = "�� �����",
        use = '/tazer'
    },
    {
        cmd = "/gr",
        desc = "�������� � ����� ������������ � ����������� ����������",
        use = "/gr [�����������(1 - LSPD, 2 - SFPD, 3 - LVPD)] [�������]"
    },
    {
        cmd = '/df',
        desc = "������� ������ � ��������������� ����",
        use = '/df'
    },
    {
        cmd = '/dmb',
        desc = '������� /members � �������',
        use = '/dmb'
    },
    {
        cmd = '/ar',
        desc = '��������� ���������� �� ����� �� ������� ���������� � ����� ������������',
        use = '/ar [�����(1 - LVA, 2 - SFA)]'
    },
    {
        cmd = '/pr',
        desc = '������� �������',
        use = '/pr'
    },
    {
        cmd = '/kmdc',
        desc = '�� �� ������� ������ � ���',
        use = '/kmdc [id]'
    },
    {
        cmd = '/ftazer',
        desc = '�� ��������� /ftazer',
        use = '/ftazer [���]'
    },
    {
        cmd = '/fvz',
        desc = '������� ������ � ���� ��� �� ��������',
        use = '/fvz [id]'
    },
    {
        cmd = '/fbd',
        desc = '��������� ������� ��������� �� �� ����� ������������',
        use = '/fbd [id]'
    },
    {
        cmd = '/blg',
        desc = '�������� ������������� �� ����� ������������',
        use = "/blg [id] [�������] [�������]"
    },
    {
        cmd = '/yk',
        desc = "������� ����� �� (����� ����� ����� �������� � ����� moonloader/fbitools/yk.txt)",
        use = "/yk"
    },
    {
        cmd = '/ak',
        desc = "������� ����� �� (����� ����� ����� �������� � ����� moonloader/fbitools/ak.txt)",
        use = "/ak"
    },
    {
        cmd = '/fp',
        desc = "������� ����� �� (����� ����� ����� �������� � ����� moonloader/fbitools/fp.txt)",
        use = "/fp"
    },
    {
        cmd = '/shp',
        desc = "������� ����� (����� ����� ����� �������� � ����� moonloader/fbitools/shp.txt)",
        use = "/shp"
    },
    {
        cmd = '/fyk',
        desc = '����� �� ����� ��',
        use = '/fyk [�����]'
    },
    {
        cmd = '/fak',
        desc = '����� �� ����� ��',
        use = '/fak [�����]'
    },
    {
        cmd = '/ffp',
        desc = '����� �� ����� ��',
        use = '/ffp [�����]'
    },
    {
        cmd = '/fshp',
        desc = '����� �� �����',
        use = '/fshp [�����]'
    },
    {
        cmd = '/fst',
        desc = '�������� �����',
        use = '/fst [�����]'
    },
    {
        cmd = '/fsw',
        desc = '�������� ������',
        use = '/fsw [������]'
    },
    {
        cmd = '/cc',
        desc = '�������� ���',
        use = '/cc'
    },
    {
        cmd = '/dkld',
        desc = '������� ������',
        use = '/dkld'
    },
    {
        cmd = '/mcheck',
        desc = '������� �� /mdc ���� �� ���������� 200 ������',
        use = '/mcheck'
    },
    {
        cmd = '/megaf',
        desc = '������� � ����������������� ����',
        use = '/megaf'
    },
    {
        cmd = '/rlog',
        desc = '������� ��� 25 ��������� ��������� � �����',
        use = '/rlog'
    },
    {
        cmd = '/dlog',
        desc = '������� ��� 25 ��������� ��������� � �����������',
        use = '/dlog'
    },
    {
        cmd = '/sulog',
        desc = '������� ��� 25 ��������� ������ �������',
        use = '/sulog'
    },
    {
        cmd = '/smslog',
        desc = '������� ��� 25 ��������� SMS',
        use = '/smslog'
    },
    {
        cmd = '/z',
        desc = '������ ������ �� ������������ �������',
        use = '/z [id] [��������(�� �����������)]'
    },
    {
        cmd = '/rt',
        desc = '��������� � ����� ��� ����',
        use = '/rt [�����]'
    },
    {
        cmd = '/ooplist',
        desc = '������ ���',
        use = '/ooplist [id(�� �����������)]'
    },
    {
        cmd = '/fkv',
        desc = '��������� ����� �� ������� �� �����',
        use = '/fkv [�������]'
    },
    {
        cmd = '/fnr',
        desc = '������� ����������� �� ������',
        use = '/fnr'
    }
}

local rpguns = {
    ["0"] = {"������� ������", "/me ������� ������", "/me �������� ������"},
    ["1"] = {"������", "/me ������ � ������� ������ � ����� ��� �� ������ ����", "/me ������� � ������� ������ � ������ ��� �� ������ ����"},
    ["3"] = {"�������", "/me ������� ��������� ���� ���� � �������� ��������� �������", "/me ������� ��������� ���� ����� � �������� ��������� �������"},
    ["4"] = {"���", "/me ���������� ��������� ���� ������ � ��� ����� ���", "/me ���������� ��������� ���� ������� � ��� ����� ���"},
    ["9"] = {"���������", "/me ���� ��������� � ���� � ����� �", "/me ����� ��������� � ���� � ������ �"},
    ["16"] = {"�������", "/me ������ ������� � ����� � �������� � �� ����", "/me ������� ������� � ����� � ��������� � �� ����"},
    ["17"] = {"������� �������", "/me ����� ����������, ����� ������ � ����� ������������ �������", "/me ������ ����������, ����� ������� � ����� ������������ �������"},
    ["18"] = {"�������� ��������", "/me ������ � ����� �������� �������� � ����� ������", "/me ������� � ����� �������� �������� � ��������� ������"},
    ["22"] = {"Colt 9mm", "/me ������ � ������ �������� ����� �� - 9 � ���������� ��� � ��������", "/me ������� � ������ �������� ����� �� - 9 � ����������� ��� � ��������"},
    ["23"] = {"Silenced 9mm", "/me ������ � ��������� ������������ � ����� �� ������ \"On\"", "/me ������� � ��������� ������������ � ������ �� ������ \"On\""},
    ["24"] = {'Desert Eagle', "/me ������ � ������ �������� ����� \"Desert Eagle\" � ����������� ���", "/me ������� � ������ �������� ����� \"Desert Eagle\" � ������������ ���"},
    ["25"] = {'Shotgun', "/me ������ � ����� �� ����� �������� �������� � ������� ���", "/me ������ � ����� �� ����� �������� �������� � ������� ���"},
    ["26"] = {'Sawnoff Shotgun', "/me ������ � ����� ����� � ������� ���", "/me ������� � ����� ����� � �������� ���"},
    ["27"] = {'Combat Shotgun', "/me ������ � ����� �������������� �������� � ������� � ���� �������", "/me ������� � ����� �������������� �������� � �������� � ���� �������"},
    ["28"] = {'Micro Uzi', "/me ���� � ��������� \"Micro Uz\" � ����������� ���", "/me ����� � ��������� \"Micro Uz\" � ������������ ���"},
    ["29"] = {'MP5', "/me c��� � ����� ��������-������� \"MP-5\" � ����������� ���", "/me c���� � ����� ��������-������� \"MP-5\" � ������������ ���"},
    ["30"] = {'��-47', "/me ���� � ����� ������� \"�����������\" � ���������� ������", "/me ����� � ����� ������� \"�����������\" � ����������� ������"},
    ["31"] = {'M4A1', "/me ���� � ����� ������� \"M4A1\" � ���������� ������", "/me ����� � ����� ������� \"M4A1\" � ����������� ������"},
    ["33"] = {'Rifle', "/me ���� � ����� ����-�������������� �������� � ����������� �", "/me ����� � ����� ����-�������������� �������� � ������������ �"},
    ["34"] = {'Sniper Rifle', "/me ������ � ����� ����������� �������� ����� ������� ������� � ����������� �", "/me ������� � ����� ����������� �������� ����� �������� ������� � ������������ �"},
    ["46"] = {'Parachute', '/me ������� ������� �� �����', '/me �������� ������� �� �����'}
}

local posts = {
    onFoot = {
        {-1984.6375732422, 106.85540008545, 27.42943572998, "����"},
        {-2055.283203125, -84.472702026367, 35.064281463623, "��"},
        {-1521.4412841797, 503.20678710938, 6.7215604782104, "SFa"},
        {-1574.4406738281, 662.24047851563, 7.3254537582397, "A"}, -- SFPD
        {-1702.3824462891, 684.79150390625, 25.01790618896, "B"}, -- SFPD
        {-2013.1629638672, 464.77380371094, 35.313331604004, "SFn"},
        {1481.77734375, -1739.9536132813, 13.546875, "�����"},
        {-2448.3591308594, 725.09326171875, 34.756977081299, "���-����"},
        {1186.5642089844, -1322.2257080078,13.098788261414, "�������� ��"},
        {1195.8181152344, -1741.1024169922, 13.131011962891, "����"},
        {2033.3028564453, 1007.163269043, 10.8203125, "������"}, -- LVPD [�������]
        {2824.7353515625, 1292.9085693359, 10.764576911926, "����"}, -- LVPD
        {2180.99609375, 1676.2248535156, 11.060985565186, "������"}, --LVPD [���������]
        {1545.6296386719, -1631.2828369141, 13.3828125, "���"}, -- LSPD
        {2753.5388183594, -2432.2268066406, 13.64318561554, "���� ��"},
        {2238.6533203125,   2449.4895019531,   11.037217140198, "���"}, -- LVPD
        {373.66720581055,   173.75173950195,   1008.3893432617, "���� �����"},
        {361.3515, -1785.0653, 5.4350, "�����������"}
    },
    inCar = {
        posts = {
            {-1749.7822265625, -591.34033203125, 16.62273979187, "�������"},
            {1667.1462402344, -768.31890869141, 54.092594146729, "���� ��-��"},
            {90.924819946289, -1554.7308349609, 5.9468450546265, "���� ��-��"},
            {1301.8980712891, -1868.2631835938, 13.546875, "�����"},
            {1766.12109375,   874.89379882813,   10.887091636658, "�����������"},
            {1155.6971435547, 831.9443359375, 10.409364700317, "��������"}
        },
        patruls = {
            {2293.4145507813, -1584.8774414063, 3.5703411102295, 670.0, "������� �������� ������"},
            {186.95843505859, 1901.0294189453, 17.640625, 300.0, "������� LVa"}
        },
        yris = {
            {-422, -1195, 60, 500.0}, -- LS-SF
            {1644, -25, 36, 300.0}, -- LS-LV
            {413, 625, 18, 300.0}, -- LS-LV
            {-129, 518, 8, 300.0}, -- LS-LV
            {-1003, 1285, 40, 300.0}, -- SF-LV
            {-2126, 2654, 53, 300.0}, -- SF-LV
            {-1006, -442, 36, 300.0}, -- LS-SF
            {-1126, -2574, 72, 300.0}, -- LS-SF
            {-1248, -2867, 64, 300.0} -- LS-SF
        }
    }
}

local tEditData = {
	id = -1,
	inputActive = false
}
local quitReason = {
    [1] = '�����',
    [2] = '���/���',
    [0] = '����/�����'
}
local sut = [[
��������� �������� ����������� - 2 ����
����������� ��������� �� ����������� - 3 ����
����������� ��������� �� ��� - 6 ���, ������ �� ��������
����������� - 1 ���
������������ ��������� - 1 ���
���������������� - 1 ���
����������� - 2 ����
���� ������������� �������� - 2 ����
������������ ����������� �� - 1 ���
���� �� ����������� �� - 2 ����
����� � ����� ���������� - 6 ���
������� ������ ��� �������� - 1 ��� � ����� � ������� 2000$.
������������ ������������ ������ - 3 ���� � �������
������������ ������������ ������ - 3 ���� � �������
������� ������������ ������ - 3 ���� � �������
�������� ���������� - 3 ���� � �������
�������� ���������� - 3 ���� � �������
������������ ���������� - 3 ���� � �������
����� ������ ��������� - 1 ��� � ����� � ������� 5000$
����������� ������ ��������� - 4 ���� � ����� � ������� 15000$
������������� �� ���. ���������� - 2 ����
������������� �� ����. ���������� - 1 ���
�������������� - 2 ����
������ - 1 ���
���������� - 2 ����
������������� - 2 ����
����������� �������� ����� - 1 ���
������������� ���������� - 3 ���
�������������� ������������ - 2 ����
������������� ��������� ���������� - 1 ���
������� �� ���. ���� - 1 ���
������� �� ���. ����������� - 2 ����
������� ������� ����� - 2 ����, ����� �������� �������.
������� ������ �� ������ - 6 ���
����������� ������ - 2 ����
���������� ������� - 6 ���, ������� ���� ��������
�������� ������ - 2 ����
������������� ����. ����� - 1 ���
���������� ���������� �������� - 3 ����
��������� ���. ���������� - 4 ����
�������������� ��������� - 1 ���
����� �� �������� - 2 ����
���� � ����� ��� - 3 ����
���������� - 3 ����
��� - 6 ���
���� - 6 ���
]]

local shpt = [[
���� ��� �� �� ��������� �����.
��� �� �������� ���� ���� ����� ��� ����� ��������� ��� ��������:
1. ������� ����� fbitools ������� ��������� � ����� moonloader
2. ������� ���� shp.txt ����� ���������
3. �������� ����� � ��� �� ����� ��� �����
4. ��������� ����
]]

function fcdgvh(idGun)
    local text = rpguns[idGun][cfg.main.male == true and 2 or 3]
    return text
end

function sampGetStreamedPlayers()
	local t = {}
	for i = 0, sampGetMaxPlayerId(false) do
		if sampIsPlayerConnected(i) then
			local result, sped = sampGetCharHandleBySampPlayerId(i)
			if result then
				if doesCharExist(sped) then
					table.insert(t, i)
                end
			end
		end
    end
	return t
end

function sirenk()
    if cfg.main.group == '��/���' then 
        if isCharInAnyCar(PLAYER_PED) then
            local car = storeCarCharIsInNoSave(PLAYER_PED)
            switchCarSiren(car, not isCarSirenOn(car))
        end
    end
end

function getClosestPlayerId()
    local minDist = 9999
    local closestId = -1
    local x, y, z = getCharCoordinates(PLAYER_PED)
    for i = 0, 999 do
        local streamed, pedID = sampGetCharHandleBySampPlayerId(i)
        if streamed then
            local xi, yi, zi = getCharCoordinates(pedID)
            local dist = math.sqrt( (xi - x) ^ 2 + (yi - y) ^ 2 + (zi - z) ^ 2 )
            if dist < minDist and sampGetFraktionBySkin(i) ~= '�������' and sampGetFraktionBySkin(i) ~= 'FBI' then
                minDist = dist
                closestId = i
            end
        end
    end
    return closestId
end
function getClosestPlayerIDinCar()
    local minDist = 9999
    local closestId = -1
    local x, y, z = getCharCoordinates(PLAYER_PED)
    local veh = storeCarCharIsInNoSave(PLAYER_PED)
    for i = 0, 999 do
        local streamed, pedID = sampGetCharHandleBySampPlayerId(i)
        if streamed then
            local xi, yi, zi = getCharCoordinates(pedID)
            local dist = math.sqrt( (xi - x) ^ 2 + (yi - y) ^ 2 + (zi - z) ^ 2 )
            if dist < minDist and sampGetFraktionBySkin(i) ~= '�������' and sampGetFraktionBySkin(i) ~= 'FBI' and isCharInAnyCar(pedID) then
                if storeCarCharIsInNoSave(pedID) == veh then
                    minDist = dist
                    closestId = i
                end
            end
        end
    end
    return closestId
end

function getClosestPlayerIDinCarD()
    local minDist = 9999
    local closestId = -1
    local x, y, z = getCharCoordinates(PLAYER_PED)
    for i = 0, 999 do
        local streamed, pedID = sampGetCharHandleBySampPlayerId(i)
        if streamed then
            local xi, yi, zi = getCharCoordinates(pedID)
            local dist = math.sqrt( (xi - x) ^ 2 + (yi - y) ^ 2 + (zi - z) ^ 2 )
            if dist < minDist and sampGetFraktionBySkin(i) ~= '�������' and sampGetFraktionBySkin(i) ~= 'FBI' and isCharInAnyCar(pedID) then
                minDist = dist
                closestId = i
            end
        end
    end
    return closestId
end

function cuffk()
    if cfg.main.group == '��/���' then 
        local valid, ped = getCharPlayerIsTargeting(PLAYER_HANDLE)
        if valid then
            result, targetid = sampGetPlayerIdByCharHandle(ped)
            if result then
                thread = lua_thread.create(function()
                    for line in cfg.otigrov.cuff:gmatch('[^\r\n]+') do

                        if line:match("^{wait%:%d+}$") then
                            wait(line:match("^%{wait%:(%d+)}$"))
                        elseif line:match("^{screen}$") then
                            screen()
                        else
                            local keys = {
                                ["{myid}"] = select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)),
                                ["{kv}"] = kvadrat(),
                                ["{targetid}"] = targetid,
                                ["{targetrpnick}"] = sampGetPlayerNicknameForBinder(targetid):gsub('_', ' '),
                                ["{naparnik}"] = naparnik(),
                                ["{myrpnick}"] = sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))):gsub("_", " "),
                                ["{rang}"] = rang,
                                ["{frak}"] = frak,
                                ["{megafid}"] = gmegafid,
                                ["{dl}"] = mcid,
                                ["{playerid}"] = targetid
                            }
                            for k1, v1 in pairs(keys) do
                                line = line:gsub(k1, v1)
                            end

                            sampSendChat(line)
                        end

                    end
                end)
                gmegafhandle = ped
                gmegafid = targetid
                gmegaflvl = sampGetPlayerScore(targetid)
                gmegaffrak = sampGetFraktionBySkin(targetid)
            end
        else
            local closeid = getClosestPlayerId()
            if closeid ~= -1 then 
                local result, closehandle = sampGetCharHandleBySampPlayerId(closeid)
                if doesCharExist(closehandle) then
                    thread = lua_thread.create(function()
                        for line in cfg.otigrov.cuff:gmatch('[^\r\n]+') do
    
                            if line:match("^{wait%:%d+}$") then
                                wait(line:match("^%{wait%:(%d+)}$"))
                            elseif line:match("^{screen}$") then
                                screen()
                            else
                                local keys = {
                                    ["{myid}"] = select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)),
                                    ["{kv}"] = kvadrat(),
                                    ["{targetid}"] = targetid,
                                    ["{targetrpnick}"] = sampGetPlayerNicknameForBinder(targetid):gsub('_', ' '),
                                    ["{naparnik}"] = naparnik(),
                                    ["{myrpnick}"] = sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))):gsub("_", " "),
                                    ["{rang}"] = rang,
                                    ["{frak}"] = frak,
                                    ["{megafid}"] = gmegafid,
                                    ["{dl}"] = mcid,
                                    ["{playerid}"] = closeid
                                }
                                for k1, v1 in pairs(keys) do
                                    line = line:gsub(k1, v1)
                                end
    
                                sampSendChat(line)
                            end

                        end
                    end)
                    gmegafhandle = ped
                    gmegafid = closeid
                    gmegaflvl = sampGetPlayerScore(closeid)
                    gmegaffrak = sampGetFraktionBySkin(closeid)
                end
            end
        end
    end
end

function uncuffk()
    if cfg.main.group == '��/���' then 
        local valid, ped = getCharPlayerIsTargeting(PLAYER_HANDLE)
        if valid then
            local result, targetid = sampGetPlayerIdByCharHandle(ped)
            if result then
                thread = lua_thread.create(function()
                    sampSendChat(string.format('/me %s ��������� � �����������', cfg.main.male and '����' or '�����'))
                    wait(1400)
                    sampSendChat('/uncuff '..targetid)
                    gmegafhandle = nil
                    gmegafid = -1
                    gmegaflvl = nil
                    gmegaffrak = nil
                end)
            end
        else
            local closeid = getClosestPlayerId()
            if sampIsPlayerConnected(closeid) then
                if closeid ~= -1 then
                    local result, closehandle = sampGetCharHandleBySampPlayerId(closeid)
                    if doesCharExist(closehandle) then
                        thread = lua_thread.create(function()
                            sampSendChat(string.format('/me %s ��������� � �����������', cfg.main.male and '����' or '�����'))
                            wait(1400)
                            sampSendChat('/uncuff '..closeid)
                            gmegafhandle = nil
                            gmegafid = -1
                            gmegaflvl = nil
                            gmegaffrak = nil
                        end)
                    end
                end
            end
        end
    end
end

function followk()
    if cfg.main.group == '��/���' then 
        local valid, ped = getCharPlayerIsTargeting(PLAYER_HANDLE)
        if valid then
            result, targetid = sampGetPlayerIdByCharHandle(ped)
            if result then
                thread = lua_thread.create(function()
                    for line in cfg.otigrov.follow:gmatch('[^\r\n]+') do

                        if line:match("^{wait%:%d+}$") then
                            wait(line:match("^%{wait%:(%d+)}$"))
                        elseif line:match("^{screen}$") then
                            screen()
                        else
                            local keys = {
                                ["{myid}"] = select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)),
                                ["{kv}"] = kvadrat(),
                                ["{targetid}"] = targetid,
                                ["{targetrpnick}"] = sampGetPlayerNicknameForBinder(targetid):gsub('_', ' '),
                                ["{naparnik}"] = naparnik(),
                                ["{myrpnick}"] = sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))):gsub("_", " "),
                                ["{rang}"] = rang,
                                ["{frak}"] = frak,
                                ["{megafid}"] = gmegafid,
                                ["{dl}"] = mcid,
                                ["{playerid}"] = targetid
                            }
                            for k1, v1 in pairs(keys) do
                                line = line:gsub(k1, v1)
                            end

                            sampSendChat(line)
                        end

                    end
                end)
                gmegafhandle = ped
                gmegafid = targetid
                gmegaflvl = sampGetPlayerScore(targetid)
                gmegaffrak = sampGetFraktionBySkin(targetid)
            end
        else
            local closeid = getClosestPlayerId()
            if closeid ~= -1 then 
                local result, closehandle = sampGetCharHandleBySampPlayerId(closeid)
                if doesCharExist(closehandle) then
                    thread = lua_thread.create(function()
                        for line in cfg.otigrov.follow:gmatch('[^\r\n]+') do
    
                            if line:match("^{wait%:%d+}$") then
                                wait(line:match("^%{wait%:(%d+)}$"))
                            elseif line:match("^{screen}$") then
                                screen()
                            else
                                local keys = {
                                    ["{myid}"] = select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)),
                                    ["{kv}"] = kvadrat(),
                                    ["{targetid}"] = targetid,
                                    ["{targetrpnick}"] = sampGetPlayerNicknameForBinder(targetid):gsub('_', ' '),
                                    ["{naparnik}"] = naparnik(),
                                    ["{myrpnick}"] = sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))):gsub("_", " "),
                                    ["{rang}"] = rang,
                                    ["{frak}"] = frak,
                                    ["{megafid}"] = gmegafid,
                                    ["{dl}"] = mcid,
                                    ["{playerid}"] = closeid
                                }
                                for k1, v1 in pairs(keys) do
                                    line = line:gsub(k1, v1)
                                end
    
                                sampSendChat(line)
                            end

                        end
                    end)
                    gmegafhandle = ped
                    gmegafid = closeid
                    gmegaflvl = sampGetPlayerScore(closeid)
                    gmegaffrak = sampGetFraktionBySkin(closeid)
                end
            end
        end
    end
end

function cputk()
    if cfg.main.group == '��/���' then 
        local closeid = getClosestPlayerId()
        if closeid ~= -1 then
            local result, closehandle = sampGetCharHandleBySampPlayerId(closeid)
            if doesCharExist(closehandle) then
                thread = lua_thread.create(function()
                    if isCharOnAnyBike(PLAYER_PED) then
                        sampSendChat(string.format("/me %s ����������� �� ������� ���������", cfg.main.male and '�������' or '��������'))
                        wait(1400)
                        sampSendChat("/cput "..closeid.." 1", -1)
                    else
                        sampSendChat(string.format("/me %s ����� ���������� � %s ���� �����������", cfg.main.male and '������' or '�������', cfg.main.male and '���������' or '����������'))
                        wait(1400)
                        sampSendChat("/cput "..closeid.." "..getFreeSeat(), -1)
                    end
                    gmegafhandle = closehandle
                    gmegafid = closeid
                    gmegaflvl = sampGetPlayerScore(closeid)
                    gmegaffrak = sampGetFraktionBySkin(closeid)
                end)
            end
        end
    end
end

function cejectk()
    if cfg.main.group == '��/���' then 
        if isCharInAnyCar(PLAYER_PED) then
            local closestId = getClosestPlayerIDinCar()
            if closestId ~= -1 then
                local result, closehandle = sampGetCharHandleBySampPlayerId(closestId)
                thread = lua_thread.create(function()
                    if isCharOnAnyBike(PLAYER_PED) then
                        sampSendChat(string.format("/me %s ����������� � ���������", cfg.main.male and '�������' or '��������'))
                        wait(1400)
                        sampSendChat("/ceject "..closestId, -1)
                    else
                        sampSendChat(string.format("/me %s ����� ���������� � %s �����������", cfg.main.male and '������' or '������', cfg.main.male and '�������' or '��������'))
                        wait(1400)
                        sampSendChat("/ceject "..closestId)
                    end
                    gmegafhandle = closehandle
                    gmegafid = closestId
                    gmegaflvl = sampGetPlayerScore(closestId)
                    gmegaffrak = sampGetFraktionBySkin(closestId)
                end)
            end
        end
    end
end

function takek()
    if cfg.main.group == '��/���' then 
        local valid, ped = getCharPlayerIsTargeting(PLAYER_HANDLE)
        if valid then
            result, targetid = sampGetPlayerIdByCharHandle(ped)
            if result then
                thread = lua_thread.create(function()
                    for line in cfg.otigrov.take:gmatch('[^\r\n]+') do

                        if line:match("^{wait%:%d+}$") then
                            wait(line:match("^%{wait%:(%d+)}$"))
                        elseif line:match("^{screen}$") then
                            screen()
                        else
                            local keys = {
                                ["{myid}"] = select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)),
                                ["{kv}"] = kvadrat(),
                                ["{targetid}"] = targetid,
                                ["{targetrpnick}"] = sampGetPlayerNicknameForBinder(targetid):gsub('_', ' '),
                                ["{naparnik}"] = naparnik(),
                                ["{myrpnick}"] = sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))):gsub("_", " "),
                                ["{rang}"] = rang,
                                ["{frak}"] = frak,
                                ["{megafid}"] = gmegafid,
                                ["{dl}"] = mcid,
                                ["{playerid}"] = targetid
                            }
                            for k1, v1 in pairs(keys) do
                                line = line:gsub(k1, v1)
                            end

                            sampSendChat(line)
                        end

                    end
                end)
                gmegafhandle = ped
                gmegafid = targetid
                gmegaflvl = sampGetPlayerScore(targetid)
                gmegaffrak = sampGetFraktionBySkin(targetid)
            end
        else
            local closeid = getClosestPlayerId()
            if closeid ~= -1 then 
                local result, closehandle = sampGetCharHandleBySampPlayerId(closeid)
                if doesCharExist(closehandle) then
                    thread = lua_thread.create(function()
                        for line in cfg.otigrov.take:gmatch('[^\r\n]+') do
    
                            if line:match("^{wait%:%d+}$") then
                                wait(line:match("^%{wait%:(%d+)}$"))
                            elseif line:match("^{screen}$") then
                                screen()
                            else
                                local keys = {
                                    ["{myid}"] = select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)),
                                    ["{kv}"] = kvadrat(),
                                    ["{targetid}"] = targetid,
                                    ["{targetrpnick}"] = sampGetPlayerNicknameForBinder(targetid):gsub('_', ' '),
                                    ["{naparnik}"] = naparnik(),
                                    ["{myrpnick}"] = sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))):gsub("_", " "),
                                    ["{rang}"] = rang,
                                    ["{frak}"] = frak,
                                    ["{megafid}"] = gmegafid,
                                    ["{dl}"] = mcid,
                                    ["{playerid}"] = closeid
                                }
                                for k1, v1 in pairs(keys) do
                                    line = line:gsub(k1, v1)
                                end
    
                                sampSendChat(line)
                            end

                        end
                    end)
                    gmegafhandle = ped
                    gmegafid = closeid
                    gmegaflvl = sampGetPlayerScore(closeid)
                    gmegaffrak = sampGetFraktionBySkin(closeid)
                end
            end
        end
    end
end

function arrestk()
    if cfg.main.group == '��/���' then 
        local valid, ped = getCharPlayerIsTargeting(PLAYER_HANDLE)
        if valid then
            result, targetid = sampGetPlayerIdByCharHandle(ped)
            if result then
                thread = lua_thread.create(function()
                    for line in cfg.otigrov.arrest:gmatch('[^\r\n]+') do

                        if line:match("^{wait%:%d+}$") then
                            wait(line:match("^%{wait%:(%d+)}$"))
                        elseif line:match("^{screen}$") then
                            screen()
                        else
                            local keys = {
                                ["{myid}"] = select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)),
                                ["{kv}"] = kvadrat(),
                                ["{targetid}"] = targetid,
                                ["{targetrpnick}"] = sampGetPlayerNicknameForBinder(targetid):gsub('_', ' '),
                                ["{naparnik}"] = naparnik(),
                                ["{myrpnick}"] = sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))):gsub("_", " "),
                                ["{rang}"] = rang,
                                ["{frak}"] = frak,
                                ["{megafid}"] = gmegafid,
                                ["{dl}"] = mcid,
                                ["{playerid}"] = targetid
                            }
                            for k1, v1 in pairs(keys) do
                                line = line:gsub(k1, v1)
                            end

                            sampSendChat(line)
                        end

                    end
                end)
                gmegafhandle = nil
                gmegafid = -1
                gmegaflvl = nil
                gmegaffrak = nil
            end
        else
            local closeid = getClosestPlayerId()
            if closeid ~= -1 then 
                local result, closehandle = sampGetCharHandleBySampPlayerId(closeid)
                if doesCharExist(closehandle) then
                    thread = lua_thread.create(function()
                        for line in cfg.otigrov.arrest:gmatch('[^\r\n]+') do
    
                            if line:match("^{wait%:%d+}$") then
                                wait(line:match("^%{wait%:(%d+)}$"))
                            elseif line:match("^{screen}$") then
                                screen()
                            else
                                local keys = {
                                    ["{myid}"] = select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)),
                                    ["{kv}"] = kvadrat(),
                                    ["{targetid}"] = targetid,
                                    ["{targetrpnick}"] = sampGetPlayerNicknameForBinder(targetid):gsub('_', ' '),
                                    ["{naparnik}"] = naparnik(),
                                    ["{myrpnick}"] = sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))):gsub("_", " "),
                                    ["{rang}"] = rang,
                                    ["{frak}"] = frak,
                                    ["{megafid}"] = gmegafid,
                                    ["{dl}"] = mcid,
                                    ["{playerid}"] = closeid
                                }
                                for k1, v1 in pairs(keys) do
                                    line = line:gsub(k1, v1)
                                end
    
                                sampSendChat(line)
                            end

                        end
                    end)
                    gmegafhandle = nil
                    gmegafid = -1
                    gmegaflvl = nil
                    gmegaffrak = nil
                end
            end
        end
    end
end

function dejectk()
    if cfg.main.group == '��/���' then 
        local closestId = getClosestPlayerIDinCarD()
        if closestId ~= -1 then
            local result, closehandle = sampGetCharHandleBySampPlayerId(closestId)
            if result then
                thread = lua_thread.create(function()
                    if isCharInFlyingVehicle(closehandle) then
                        sampSendChat(string.format("/me %s ����� �������� � %s �����������", cfg.main.male and '������' or '�������', cfg.main.male and '�������' or '��������'))
                        wait(1400)
                        sampSendChat("/deject "..closestId)
                    elseif isCharInModel(closehandle, 481) or isCharInModel(closehandle, 510) then
                        sampSendChat(string.format("/me ������ ����������� � ����������", cfg.main.male and '������' or '�������'))
                        wait(1400)
                        sampSendChat("/deject "..closestId)
                    elseif isCharInModel(closehandle, 462) then
                        sampSendChat(string.format("/me %s ����������� �� �������", cfg.main.male and '������' or '�������'))
                        wait(1400)
                        sampSendChat("/deject "..closestId)
                    elseif isCharOnAnyBike(closehandle) then
                        sampSendChat(string.format("/me %s ����������� � ���������", cfg.main.male and '������' or '�������'))
                        wait(1400)
                        sampSendChat("/deject "..closestId)
                    elseif isCharInAnyCar(closehandle) then
                        sampSendChat(string.format("/me %s ���� � %s ����������� �� ������", cfg.main.male and '������' or '�������', cfg.main.male and '���������' or '����������'))
                        wait(1400)
                        sampSendChat("/deject "..closestId)
                    end
                end)
            end
        end
    end
end

function hikeyk()
	if cfg.main.group == '�����' then
		thread = lua_thread.create(function()
			sampSendChat(string.format('�����������, � ������� %s. ��� ��������� � ���� �������?', sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))):gsub('_', ' ')))
			wait(1400)
			sampSendChat(string.format('/b /showpass %s', select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))))
		end)
	end
end

function summakeyk()
	if cfg.main.group == '�����' then
		thread = lua_thread.create(function()
			local valid, tped = getCharPlayerIsTargeting(PLAYER_HANDLE)
			if valid and doesCharExist(tped) then
				local result, tid = sampGetPlayerIdByCharHandle(tped)
				if result then
					local tlvl = sampGetPlayerScore(tid)
					sampSendChat(string.format('����� ������ ���������� ���������� %s.', getFreeCost(tlvl)))
					wait(1400)
					sampSendChat('��� ������� ��������, ������ ��� ���������?')
				end
			end
		end)
	end
end

function freenalkeyk()
	if cfg.main.group == '�����' then
		thread = lua_thread.create(function()
			local valid, tped = getCharPlayerIsTargeting(PLAYER_HANDLE)
			if valid and doesCharExist(tped) then
				local result, tid = sampGetPlayerIdByCharHandle(tped)
				if result then
					local tlvl = sampGetPlayerScore(tid)
					sampSendChat('/me ������ ����� �� ����� � ����� ��� ���������')
					wait(1400)
					sampSendChat('/me �������� ������ � ������ � ������� ������������')
					wait(1400)
					sampSendChat(string.format('/free %s 1 %s', tid, getFreeCost(tlvl)))
				end
			end
		end)
	end
end

function freebankkeyk()
	if cfg.main.group == '�����' then
		thread = lua_thread.create(function()
			local valid, tped = getCharPlayerIsTargeting(PLAYER_HANDLE)
			if valid and doesCharExist(tped) then
				local result, tid = sampGetPlayerIdByCharHandle(tped)
				if result then
					local tlvl = sampGetPlayerScore(tid)
					sampSendChat('/me ������ ����� �� ����� � ����� ��� ���������')
					wait(1400)
					sampSendChat('/me �������� ������ � ������ � ������� ������������')
					wait(1400)
					sampSendChat(string.format('/free %s 2 %s', tid, getFreeCost(tlvl)))
				end
			end
		end)
	end
end

function vzaimk()
    local valid, ped = getCharPlayerIsTargeting(PLAYER_HANDLE)
    if valid and doesCharExist(ped) then
        local result, id = sampGetPlayerIdByCharHandle(ped)
        --targetid = id
        if result then
            if cfg.main.group == '��/���' then
                gmegafhandle = ped
                gmegafid = id
                gmegaflvl = sampGetPlayerScore(id)
                gmegaffrak = sampGetFraktionBySkin(id)
                submenus_show(pkmmenuPD(id), "{9966cc}"..script.this.name.." {ffffff}| "..sampGetPlayerNickname(id).." ["..id.."] ")
            elseif cfg.main.group == "���������" then
                submenus_show(pkmmenuAS(id), "{9966cc}"..script.this.name.." {ffffff}| "..sampGetPlayerNickname(id).." ["..id.."] ")
            elseif cfg.main.group == "������" then
                submenus_show(pkmmenuMOH(id), "{9966cc}"..script.this.name.." {ffffff}| "..sampGetPlayerNickname(id).." ["..id.."] ")
            end
        end
    end
end

function sampGetFraktionBySkin(id)
    local skin = 0
    local t = '�����������'
    --if sampIsPlayerConnected(id) then
        local result, ped = sampGetCharHandleBySampPlayerId(id)
        if result then
            skin = getCharModel(ped)
        else
            skin = getCharModel(PLAYER_PED)
        end
        if skin == 102 or skin == 103 or skin == 104 or skin == 195 or skin == 21 then t = 'Ballas Gang' end
        if skin == 105 or skin == 106 or skin == 107 or skin == 269 or skin == 270 or skin == 271 or skin == 86 or skin == 149 or skin == 297 then t = 'Grove Gang' end
        if skin == 108 or skin == 109 or skin == 110 or skin == 190 or skin == 47 then t = 'Vagos Gang' end
        if skin == 114 or skin == 115 or skin == 116 or skin == 48 or skin == 44 or skin == 41 or skin == 292 then t = 'Aztec Gang' end
        if skin == 173 or skin == 174 or skin == 175 or skin == 193 or skin == 226 or skin == 30 or skin == 119 then t = 'Rifa Gang' end
        if skin == 191 or skin == 252 or skin == 287 or skin == 61 or skin == 179 or skin == 255 or skin == 73 then t = 'Army' end
        if skin == 57 or skin == 98 or skin == 147 or skin == 150 or skin == 187 or skin == 216 then t = '�����' end
        if skin == 59 or skin == 172 or skin == 189 or skin == 240 then t = '���������' end
        if skin == 201 or skin == 247 or skin == 248 or skin == 254 or skin == 248 or skin == 298 then t = '�������' end
        if skin == 272 or skin == 112 or skin == 125 or skin == 214 or skin == 111  or skin == 126 then t = '������� �����' end
        if skin == 113 or skin == 124 or skin == 214 or skin == 223 then t = 'La Cosa Nostra' end
        if skin == 120 or skin == 123 or skin == 169 or skin == 186 then t = 'Yakuza' end
        if skin == 211 or skin == 217 or skin == 250 or skin == 261 then t = 'News' end
        if skin == 70 or skin == 219 or skin == 274 or skin == 275 or skin == 276 or skin == 70 then t = '������' end
        if skin == 286 or skin == 141 or skin == 163 or skin == 164 or skin == 165 or skin == 166 then t = 'FBI' end
        if skin == 280 or skin == 265 or skin == 266 or skin == 267 or skin == 281 or skin == 282 or skin == 288 or skin == 284 or skin == 285 or skin == 304 or skin == 305 or skin == 306 or skin == 307 or skin == 309 or skin == 283 or skin == 303 then t = '�������' end
    --end
    return t
end

function sampGetPlayerIdByNickname(nick)
    local _, myid = sampGetPlayerIdByCharHandle(playerPed)
    if tostring(nick) == sampGetPlayerNickname(myid) then return myid end
    for i = 0, 1000 do if sampIsPlayerConnected(i) and sampGetPlayerNickname(i) == tostring(nick) then return i end end
end

function getMaskList(forma)
	local mask = {
		['������������'] = 0,
		['������������'] = 1,
		['��������'] = 2,
		['�����������'] = 3,
		['������'] = 3,
		['���������� �����'] = 4,
		['��������� ���������'] = 5,
		['��������� ��������'] = 6,
		['��� LCN'] = 7,
		['��� Yakuza'] = 8,
		['��� Russian Mafia'] = 9,
		['�� Rifa'] = 10,
		['�� Grove'] = 11,
		['�� Ballas'] = 12,
		['�� Vagos'] = 13,
		['�� Aztec'] = 14,
		['��������'] = 15
	}
	return mask[forma]
end

local russian_characters = {
    [168] = '�', [184] = '�', [192] = '�', [193] = '�', [194] = '�', [195] = '�', [196] = '�', [197] = '�', [198] = '�', [199] = '�', [200] = '�', [201] = '�', [202] = '�', [203] = '�', [204] = '�', [205] = '�', [206] = '�', [207] = '�', [208] = '�', [209] = '�', [210] = '�', [211] = '�', [212] = '�', [213] = '�', [214] = '�', [215] = '�', [216] = '�', [217] = '�', [218] = '�', [219] = '�', [220] = '�', [221] = '�', [222] = '�', [223] = '�', [224] = '�', [225] = '�', [226] = '�', [227] = '�', [228] = '�', [229] = '�', [230] = '�', [231] = '�', [232] = '�', [233] = '�', [234] = '�', [235] = '�', [236] = '�', [237] = '�', [238] = '�', [239] = '�', [240] = '�', [241] = '�', [242] = '�', [243] = '�', [244] = '�', [245] = '�', [246] = '�', [247] = '�', [248] = '�', [249] = '�', [250] = '�', [251] = '�', [252] = '�', [253] = '�', [254] = '�', [255] = '�',
}
function string.rlower(s)
    s = s:lower()
    local strlen = s:len()
    if strlen == 0 then return s end
    s = s:lower()
    local output = ''
    for i = 1, strlen do
        local ch = s:byte(i)
        if ch >= 192 and ch <= 223 then
            output = output .. russian_characters[ch + 32]
        elseif ch == 168 then
            output = output .. russian_characters[184]
        else
            output = output .. string.char(ch)
        end
    end
    return output
end
function string.rupper(s)
    s = s:upper()
    local strlen = s:len()
    if strlen == 0 then return s end
    s = s:upper()
    local output = ''
    for i = 1, strlen do
        local ch = s:byte(i)
        if ch >= 224 and ch <= 255 then
            output = output .. russian_characters[ch - 32]
        elseif ch == 184 then
            output = output .. russian_characters[168]
        else
            output = output .. string.char(ch)
        end
    end
    return output
end
function submenus_show(menu, caption, select_button, close_button, back_button)
    select_button, close_button, back_button = select_button or '�', close_button or 'x', back_button or '�'
    prev_menus = {}
    function display(menu, id, caption)
        local string_list = {}
        for i, v in ipairs(menu) do
            table.insert(string_list, type(v.submenu) == 'table' and v.title .. ' �' or v.title)
        end
        sampShowDialog(id, caption, table.concat(string_list, '\n'), select_button, (#prev_menus > 0) and back_button or close_button, sf.DIALOG_STYLE_LIST)
        repeat
            wait(0)
            local result, button, list = sampHasDialogRespond(id)
            if result then
                if button == 1 and list ~= -1 then
                    local item = menu[list + 1]
                    if type(item.submenu) == 'table' then
                        table.insert(prev_menus, {menu = menu, caption = caption})
                        if type(item.onclick) == 'function' then
                            item.onclick(menu, list + 1, item.submenu)
                        end
                        return display(item.submenu, id + 1, item.submenu.title and item.submenu.title or item.title)
                    elseif type(item.onclick) == 'function' then
                        local result = item.onclick(menu, list + 1)
                        if not result then return result end
                        return display(menu, id, caption)
                    end
                else
                    if #prev_menus > 0 then
                        local prev_menu = prev_menus[#prev_menus]
                        prev_menus[#prev_menus] = nil
                        return display(prev_menu.menu, id - 1, prev_menu.caption)
                    end
                    return false
                end
            end
        until result
    end
    return display(menu, 31337, caption or menu.title)
end

local dfmenu = {
    {
        title = '����� � ������� ����������',
        onclick = function()
            sampSendChat(("/me %s �������� �����"):format(cfg.main.male and '������' or '�������'))
            wait(3500)
            sampSendChat(("/me %s �������� �����"):format(cfg.main.male and '������' or '�������'))
            wait(3500)
            sampSendChat(("/me %s �������� ����������"):format(cfg.main.male and '��������' or '���������'))
            wait(3500)
            sampSendChat(("/do %s ��� ��������� ����������. ����� � ������� ����������."):format(cfg.main.male and '���������' or '����������'))
            wait(3500)
            sampSendChat(("/do %s ��� ������� ��������� � ���������."):format(cfg.main.male and '������' or '�������'))
            wait(3500)
            sampSendChat(("/me %s ��� �� ��������� ������"):format(cfg.main.male and '������' or '�������'))
            wait(3500)
            sampSendChat(("/me ��������� %s ������ ������"):format(cfg.main.male and '��������' or '���������'))
            wait(3500)
            sampSendChat(("/try %s �������� � ����������� � %s ���� �������� � �������� �������"):format(cfg.main.male and '������' or '�������', cfg.main.male and '���������' or '����������'))
        end
    },
    {
        title = '����� � ������� ���������� ���� {63c600}[������]',
        onclick = function()
            sampSendChat(("/me %s ��������"):format(cfg.main.male and '���������' or '����������'))
            wait(3500)
            sampSendChat(("/me %s � ����������"):format(cfg.main.male and '�����������' or '������������'))
            wait(3500)
            sampSendChat("/do �������� �������� �������� �������� �����.")
            wait(3500)
            sampSendChat("/do ����� �����������.")
            wait(3500)
            sampSendChat(("/me %s ����������� ������� � �������� �����"):format(cfg.main.male and '������' or '�������'))
            wait(3500)
            sampSendChat(("/me %s ������������� ���� � ��������� %s ���� �����"):format(cfg.main.male and '������' or '�������', cfg.main.male and '������' or '�������'))
        end
    },
    {
        title = '����� � ������� ���������� ���� {bf0000}[��������]',
        onclick = function()
            sampSendChat(("/me ��������� %s ������ ������"):format(cfg.main.male and '��������' or '���������'))
            wait(3500)
            sampSendChat(("/me %s ��������"):format(cfg.main.male and '���������' or '����������'))
            wait(3500)
            sampSendChat(("/me %s � ����������"):format(cfg.main.male and '�����������' or '������������'))
            wait(3500)
            sampSendChat("/do �������� �������� �������� �������� �����.")
            wait(3500)
            sampSendChat("/do ����� �����������.")
            wait(3500)
            sampSendChat(("/me %s ����������� ������� � �������� �����"):format(cfg.main.male and '������' or '�������'))
            wait(3500)
            sampSendChat(("/me %s ������������� ���� � ��������� %s ���� �����"):format(cfg.main.male and '������' or '�������', cfg.main.male and '������' or '�������'))
        end
    },
    {
        title = '����� � ������������� �����������',
        onclick = function()
            sampSendChat(("/me %s �������� �����"):format(cfg.main.male and '������' or '�������'))
            wait(3500)
            sampSendChat(("/me %s �������� �����"):format(cfg.main.male and '������' or '�������'))
            wait(3500)
            sampSendChat(("/me %s �������� ����������"):format(cfg.main.male and '��������' or '���������'))
            wait(3500)
            sampSendChat(("/do %s ��� ��������� ����������. ����� � ������������� �����������."):format(cfg.main.male and '���������' or '����������'))
            wait(3500)
            sampSendChat(("/do %s ��� ������ �� ����� � ����������."):format(cfg.main.male and '������' or '�������'))
            wait(3500)
            sampSendChat(("/me %s �������� �� ��������� ������"):format(cfg.main.male and '������' or '�������'))
            wait(3500)
            sampSendChat("/me ��������� ����������� �����")
            wait(3500)
            sampSendChat(("/me %s ������ ����� � %s �������"):format(cfg.main.male and '���������' or '����������', cfg.main.male and '������' or '�������'))
            wait(3500)
            sampSendChat(("/do %s ������� �������� ���������."):format(cfg.main.male and '������' or '�������'))
            wait(3500)
            sampSendChat(("/me %s ���� ���������� �� ������� � ����������"):format(cfg.main.male and '����������' or '�����������'))
            wait(3500)
            sampSendChat(("/me %s ��� �������"):format(cfg.main.male and '������' or '�������'))
            wait(3500)
            sampSendChat(("/try %s ������ ������. ��������� �������� ������."):format(cfg.main.male and '���������' or '����������'))
        end
    },
    {
        title = '����� � ������������� ����������� ���� {63c600}[������]',
        onclick = function()
            sampSendChat("/do ����� �����������.")
            wait(3500)
            sampSendChat(("/me %s ����������� ������� � �������� �����"):format(cfg.main.male and '������' or '�������'))
            wait(3500)
            sampSendChat(("/me %s ������������� ���� � ��������� %s ���� �����"):format(cfg.main.male and '������' or '�������', cfg.main.male and '������' or '�������'))
        end
    },
    {
        title = '����� � ������������� ����������� ���� {bf0000}[��������]',
        onclick = function()
            sampSendChat(("/me %s ������ ������"):format(cfg.main.male and '���������' or '����������'))
            wait(3500)
            sampSendChat("/do ��������� �������� ������.")
            wait(3500)
            sampSendChat("/do ����� �����������.")
            wait(3500)
            sampSendChat(("/me %s ����������� ������� � �������� �����"):format(cfg.main.male and '������' or '�������'))
            wait(3500)
            sampSendChat(("/me %s ������������� ���� � ��������� %s ���� �����"):format(cfg.main.male and '������' or '�������', cfg.main.male and '������' or '�������'))
        end
    },
    {
        title = '����� � ������������� �����',
        onclick = function()
            sampSendChat(("/me %s �������� �����"):format(cfg.main.male and '������' or '�������'))
            wait(3500)
            sampSendChat(("/me %s �������� �����"):format(cfg.main.male and '������' or '�������'))
            wait(3500)
            sampSendChat(("/me %s �������� ����������"):format(cfg.main.male and '��������' or '���������'))
            wait(3500)
            sampSendChat(("/do %s ��� ��������� ����������. ����� � ������������� �����."):format(cfg.main.male and '���������' or '����������'))
            wait(3500)
            sampSendChat(("/me %s �� ��������� ������ ������ ��� ������� ����"):format(cfg.main.male and '������' or '�������'))
            wait(3500)
            sampSendChat(("/me %s ������ � �����"):format(cfg.main.male and '���������' or '����������'))
            wait(3500)
            sampSendChat("/do �� ������� �����������: �������� ��������� ������.")
            wait(3500)
            sampSendChat("/do �� ������� �����������: ������ 5326.")
            wait(3500)
            sampSendChat(("/try %s ���������� ������. ����� ����� ����������"):format(cfg.main.male and '���' or '����'))
        end
    },
    {
        title = '����� � ������������� ����� ���� {63c600}[������]',
        onclick = function()
            sampSendChat("/do ����� �����������.")
            wait(3500)
            sampSendChat(("/me %s ����������� ������� � �������� �����"):format(cfg.main.male and '������' or '�������'))
            wait(3500)
            sampSendChat(("/me %s ������������� ���� � ��������� %s ���� �����"):format(cfg.main.male and '������' or '�������', cfg.main.male and '������' or '�������'))
        end
    },
    {
        title = '����� � ������������� ����� ���� {bf0000}[��������]',
        onclick = function()
            sampSendChat(("/me ������������� ������"):format(cfg.main.male and '������������' or '�������������'))
            wait(3500)
            sampSendChat("/do �� ������� �����������: �������� ��������� ������.")
            wait(3500)
            sampSendChat("/do �� ������� �����������: ������ 3789.")
            wait(3500)
            sampSendChat(("/me %s ���������� ������"):format(cfg.main.male and '���' or '����'))
            wait(3500)
            sampSendChat("/����� ����� ����������")
            wait(3500)
            sampSendChat("/do ����� �����������.")
            wait(3500)
            sampSendChat(("/me %s ����������� ������� � �������� �����"):format(cfg.main.male and '������' or '�������'))
            wait(3500)
            sampSendChat(("/me %s ������������� ���� � ��������� %s ���� �����"):format(cfg.main.male and '������' or '�������', cfg.main.male and '������' or '�������'))
        end
    }
}

local fcmenu =
{
  {
    title = '�������',
    submenu =
    {
      {
        title = '{00BFFF}� ����� �'
      },
      {
        title = '{00BFFF}������ ����� ��� ���������� � {ff0000}100.000$'
      },
      {
        title = '{00BFFF}������ ����� c ����������� � {ff0000}150.000$'
      },
      {
        title = '{9A9593}� ���� ��� �'
      },
      {
        title = '{9A9593}������ ����� ������������ ���� ��� ���������� � {ff0000}100.000$'
      },
      {
        title = '{9A9593}������ ����� ������������ ���� c ����������� � {ff0000}150.000$'
      },
      {
        title = '{0080FF}� ������� SFPD �'
      },
      {
        title = '{0080FF}������ ������� SAPD ��� ���������� � {ff0000}100.000$'
      },
      {
        title = '{0080FF}������ ������� SAPD c ����������� � {ff0000}150.000$'
      },
      {
        title = '{BF4040}� �������� �'
      },
      {
        title = '{BF4040}������ �������� ��� ���������� � {ff0000}75.000$'
      },
      {
        title = '{BF4040}������ �������� � ����������� � {ff0000}100.000$'
      },
      {
        title = '{00BFFF}� ��������� �'
      },
      {
        title = '{00BFFF}������ ��������� ��� ���������� � {ff0000}50.000$'
      },
      {
        title = '{00BFFF}������ ��������� � ����������� � {ff0000}75.000$'
      },
      {
        title = '{40BFBF}� C�� �'
      },
      {
        title = '{40BFBF}������ ��� ��� ���������� � {ff0000}50.000$'
      },
      {
        title = '{40BFBF}������ ��� � ����������� � {ff0000}75.000$'
      },
      {
        title = '� ��������� �'
      },
      {
        title = '������ ���������������/������� ��������� ��� ���������� � {ff0000}50.000$'
      },
      {
        title = '������ ���������������/������� ��������� � ����������� � {ff0000}75.000$'
      }
    }
  },
  {
    title = '���������',
    submenu =
    {
      {
        title = '�����',
        submenu =
        {
          {
            title = '{0040BF}���{ffffff} [6] - {ff0000}100.000$'
          },
          {
            title = '{0040BF}���.����{ffffff} [5] - {ff0000}80.000$'
          },
          {
            title = '{0040BF}��������� ������{ffffff} [4] - {ff0000}60.000$'
          },
          {
            title = '{0040BF}��������{ffffff} [3] - {ff0000}40.000$'
          },
          {
            title = '{0040BF}�������{ffffff} [2] - {ff0000}30.000$'
          },
          {
            title = '{0040BF}���������{ffffff} [1] - {ff0000}20.000$'
          }
        }
      },
      {
        title = '���',
        submenu =
        {
          {
            title = '{9A9593}��������{ffffff} [10] - {ff0000}100.000$'
          },
          {
            title = '{9A9593}���.���������{FFFFFF} [9] - {ff0000}80.000$'
          },
          {
            title = '{9A9593}���������{ffffff} [8] - {ff0000}70.000$'
          },
          {
            title = '{9A9593}����� CID{ffffff} [7] - {ff0000}60.000$'
          },
          {
            title = '{9A9593}����� DEA{ffffff} [6] - {ff0000}50.000$'
          },
          {
            title = '{9A9593}����� CID{ffffff} [5] - {ff0000}40.000$'
          },
          {
            title = '{9A9593}����� DEA{ffffff} [4] - {ff0000}30.000$'
          },
          {
            title = '{9A9593}��.�����{ffffff} [3] - {ff0000}25.000$'
          },
          {
            title = '{9A9593}��������{ffffff} [2] - {ff0000}20.000$'
          },
          {
            title = '{9A9593}������{ffffff} [1] - {ff0000}15.000$'
          }
        }
      },
      {
        title = '�������',
        submenu =
        {
          {
            title = '{0000FF}�����{ffffff} [14] - {ff0000}80.000$'
          },
          {
            title = '{0000FF}���������{ffffff} [13] - {ff0000}70.000$'
          },
          {
            title = '{0000FF}������������{ffffff} [12] - {ff0000}65.000$'
          },
          {
            title = '{0000FF}�����{ffffff} [11] - {ff0000}60.000$'
          },
          {
            title = '{0000FF}�������{ffffff} [10] - {ff0000}55.000$'
          },
          {
            title = '{0000FF}��.���������{ffffff} [9] - {ff0000}50.000$'
          },
          {
            title = '{0000FF}���������{ffffff} [8] - {ff0000}45.000$'
          },
          {
            title = '{0000FF}��.���������{ffffff} [7] - {ff0000}40.000$'
          },
          {
            title = '{0000FF}��.���������{ffffff} [6] - {ff0000}35.000$'
          },
          {
            title = '{0000FF}���������{ffffff} [5] - {ff0000}30.000$'
          },
          {
            title = '{0000FF}�������{ffffff} [4] - {ff0000}25.000$'
          },
          {
            title = '{0000FF}��.�������{ffffff} [3] - {ff0000}20.000$'
          },
          {
            title = '{0000FF}������{ffffff} [2] - {ff0000}15.000$'
          },
          {
            title = '{0000FF}�����{ffffff} [1] - {ff0000}10.000$'
          }
        }
      },
      {
        title = '�����',
        submenu =
        {
          {
            title = '{008040}�������{ffffff} [15] - {ff0000}80.000$'
          },
          {
            title = '{008040}���������{ffffff} [14] - {ff0000}75.000$'
          },
          {
            title = '{008040}������������{ffffff} [13] - {ff0000}70.000$'
          },
          {
            title = '{008040}�����{ffffff} [12] - {ff0000}65.000$'
          },
          {
            title = '{008040}�������{ffffff} [11] - {ff0000}60.000$'
          },
          {
            title = '{008040}��.���������{ffffff} [10] - {ff0000}55.000$'
          },
          {
            title = '{008040}���������{ffffff} [9] - {ff0000}50.000$'
          },
          {
            title = '{008040}��.���������{ffffff} [8] - {ff0000}45.000$'
          },
          {
            title = '{008040}���������{ffffff} [7] - {ff0000}40.000$'
          },
          {
            title = '{008040}��������{ffffff} [6] - {ff0000}35.000$'
          },
          {
            title = '{008040}��.�������{ffffff} [5] - {ff0000}30.000$'
          },
          {
            title = '{008040}�������{ffffff} [4] - {ff0000}25.000$'
          },
          {
            title = '{008040}��.�������{ffffff} [3] - {ff0000}20.000$'
          },
          {
            title = '{008040}��������{ffffff} [2] - {ff0000}15.000$'
          },
          {
            title = '{008040}�������{ffffff} [1] - {ff0000}10.000$'
          }
        }
      },
      {
        title = '������',
        submenu =
        {
          {
            title = '{BF4040}����.����{ffffff} [10] - {ff0000}80.000$'
          },
          {
            title = '{BF4040}���.����.�����{ffffff} [9] - {ff0000}75.000$'
          },
          {
            title = '{BF4040}������{ffffff} [8] - {ff0000}70.000$'
          },
          {
            title = '{BF4040}��������{ffffff} [7] - {ff0000}60.000$'
          },
          {
            title = '{BF4040}������{ffffff} [6] - {ff0000}40.000$'
          },
          {
            title = '{BF4040}��������{ffffff} [5] - {ff0000}35.000$'
          },
          {
            title = '{BF4040}���������{ffffff} [4] - {ff0000}30.000$'
          },
          {
            title = '{BF4040}���.����{ffffff} [3] - {ff0000}25.000$'
          },
          {
            title = '{BF4040}�������{ffffff} [2] - {ff0000}20.000$'
          },
          {
            title = '{BF4040}������{ffffff} [1] - {ff0000}15.000$'
          }
        }
      },
      {
        title = '���������',
        submenu =
        {
          {
            title = '{40BFFF}�����������{ffffff} [10] - {ff0000}80.000$'
          },
          {
            title = '{40BFFF}��������{ffffff} [9] - {ff0000}75.000$'
          },
          {
            title = '{40BFFF}��.��������{ffffff} [8] - {ff0000}70.000$'
          },
          {
            title = '{40BFFF}��.��������{ffffff} [7] - {ff0000}60.000$'
          },
          {
            title = '{40BFFF}�����������{ffffff} [6] - {ff0000}55.000$'
          },
          {
            title = '{40BFFF}����������{FFFFFF} [5] - {ff0000}50.000$'
          },
          {
            title = '{40BFFF}��.����������{ffffff} [4] - {ff0000}45.000$'
          },
          {
            title = '{40BFFF}�����������{ffffff} [3] - {ff0000}30.000$'
          },
          {
            title = '{40BFFF}�����������{ffffff} [2] - {ff0000}25.000$'
          },
          {
            title = '{40BFFF}������{ffffff} [1] - {ff0000}20.000$'
          }
        }
      },
      {
        title = '�������',
        submenu =
        {
          {
            title = '{FFFF80}����������� ��������{ffffff} [10] - {ff0000}70.000$'
          },
          {
            title = '{FFFF80}���������� ��������{ffffff} [9] - {ff0000}60.000$'
          },
          {
            title = '{FFFF80}����������� ��������{ffffff} [8] - {ff0000}55.000$'
          },
          {
            title = '{FFFF80}������� ��������{ffffff} [7] - {ff0000}50.000$'
          },
          {
            title = '{FFFF80}��������{ffffff} [6] - {ff0000}45.000$'
          },
          {
            title = '{FFFF80}�������{ffffff} [5] - {ff0000}40.000$'
          },
          {
            title = '{FFFF80}��������{ffffff} [4] - {ff0000}30.000$'
          },
          {
            title = '{FFFF80}�������������{ffffff} [3] - {ff0000}25.000$'
          },
          {
            title = '{FFFF80}�������������{ffffff} [2] - {ff0000}20.000$'
          },
          {
            title = '{FFFF80}������{ffffff} [1] - {ff0000}15.000$'
          }
        }
      }
    }
  }
}

local fthmenuPD = {
    {
        title = '{ffffff}� ��������� ��������� � ������� �������',
        onclick = function()
            if cfg.main.tarb then
                sampSendChat(string.format('/r %s: ����� ��������� � ������� %s', trash.tag, kvadrat()))
            else
                sampSendChat(string.format('/r ����� ��������� � ������� %s', kvadrat()))
            end
        end
    },
    {
        title = '{ffffff}� ��������� ��������� � ������� �������',
        onclick = function()
            sampShowDialog(1401, '{9966cc}'..script.this.name..' {ffffff}| ���������', '{ffffff}�������: ���-�� ����\n������: 3 �����', '���������', '������', 1)
        end
    },
    {
        title = '{ffffff}� ���� ������',
        onclick = function()
            submenus_show(fcmenu, '{9966cc}'..script.this.name..' {ffffff}| ���� ������')
        end
    }
}

local fthmenuAS = {
    {
        title = "{FFFFFF}� �����������",
        onclick = function() 
            sampSendChat(("������ ����. � ��������� ��������� %s, ��� ���� ������?"):format(sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))):gsub("_", " ")))
        end
    },
    {
        title = "{FFFFFF}� ��������� �������",
        onclick = function()
            sampSendChat("��� �������, ����������.")
            wait(1400)
            sampSendChat(("/b /showpass %s"):format(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))))
        end
    },
    {
        title = "{FFFFFF}� �����������",
        onclick = function() sampSendChat("�������� ���!") end
    },
    {
        title = "{FFFFFF}� ������� ������� (����������� ������)",
        onclick = function()
            sampSendChat(("/me %s ����� � �����"):format(cfg.main.male and '����' or '�����'))
            wait(cfg.commands.zaderjka)
            sampSendChat("/itazer")
            wait(cfg.commands.zaderjka)
            sampSendChat(("/me %s ����� �� ����"):format(cfg.main.male and '�������' or '��������'))
        end
    }
}

local fthmenuMOH = {
    {
        title = "� �����������",
        onclick = function()
            sampSendChat("������������, ��� ��� ���������? ")
        end
    },
    {
        title = "� �����������",
        onclick = function()
            sampSendChat("�������� ���, �� �������.")
        end
    },
    {
        title = "� �������� ��������� ������ �� ����������������",
        onclick = function()
            sampSendChat("��������� ������ �� ���������������� ���������� 10.000$.")
        end
    }
}

function getweaponname(weapon)
    local names = {
    [0] = "Fist",
    [1] = "Brass Knuckles",
    [2] = "Golf Club",
    [3] = "Nightstick",
    [4] = "Knife",
    [5] = "Baseball Bat",
    [6] = "Shovel",
    [7] = "Pool Cue",
    [8] = "Katana",
    [9] = "Chainsaw",
    [10] = "Purple Dildo",
    [11] = "Dildo",
    [12] = "Vibrator",
    [13] = "Silver Vibrator",
    [14] = "Flowers",
    [15] = "Cane",
    [16] = "Grenade",
    [17] = "Tear Gas",
    [18] = "Molotov Cocktail",
    [22] = "9mm",
    [23] = "Silenced 9mm",
    [24] = "Desert Eagle",
    [25] = "Shotgun",
    [26] = "Sawnoff Shotgun",
    [27] = "Combat Shotgun",
    [28] = "Micro SMG/Uzi",
    [29] = "MP5",
    [30] = "AK-47",
    [31] = "M4",
    [32] = "Tec-9",
    [33] = "Country Rifle",
    [34] = "Sniper Rifle",
    [35] = "RPG",
    [36] = "HS Rocket",
    [37] = "Flamethrower",
    [38] = "Minigun",
    [39] = "Satchel Charge",
    [40] = "Detonator",
    [41] = "Spraycan",
    [42] = "Fire Extinguisher",
    [43] = "Camera",
    [44] = "Night Vis Goggles",
    [45] = "Thermal Goggles",
    [46] = "Parachute" }
    return names[weapon]
end

function isInSuit(i)
    if cfg.main.group == "��/���" and (sampGetFraktionBySkin(i) == '�������' or sampGetFraktionBySkin(i) == 'FBI') then return true end
    if cfg.main.group == "���������" and sampGetFraktionBySkin(i) == "���������" then return true end
    if cfg.main.group == "������" and sampGetFraktionBySkin(i) == "������" then return true end
    if cfg.main.group == "�����" and sampGetFraktionBySkin(i) == "�����" then return true end
    if cfg.main.group == "�����" and sampGetFraktionBySkin(i) == "Army" then return true end
    return false
end

function naparnik()
    local v = {}

    for i = 0, sampGetMaxPlayerId(true) do
        if sampIsPlayerConnected(i) then
            local ichar = select(2, sampGetCharHandleBySampPlayerId(i))
            if doesCharExist(ichar) then
                if isCharInAnyCar(PLAYER_PED) then
                    if isCharInAnyCar(ichar) then
                        local veh  = storeCarCharIsInNoSave(PLAYER_PED)
                        local iveh = storeCarCharIsInNoSave(ichar)
                        if veh == iveh then
                            if isInSuit(i) then
                                local inick, ifam = sampGetPlayerNickname(i):match('(.+)_(.+)')
                                if inick and ifam then
                                    table.insert(v, string.format('%s.%s', inick:sub(1,1), ifam))
                                end
                            end
                        end
                    end
                else
                    local myposx, myposy, myposz = getCharCoordinates(PLAYER_PED)
                    local ix, iy, iz = getCharCoordinates(ichar)
                    if getDistanceBetweenCoords3d(myposx, myposy, myposz, ix, iy, iz) <= 100 then
                        if isInSuit(i) then
                            local inick, ifam = sampGetPlayerNickname(i):match('(.+)_(.+)')
                            if inick and ifam then
                                table.insert(v, string.format('%s.%s', inick:sub(1,1), ifam))
                            end
                        end
                    end
                end

            end
        end
    end

    if #v == 0 then
        return '���������� ���.'
    elseif #v == 1 then
        return '��������: '..table.concat(v, ', ').. '.'
    elseif #v >=2 then
        return '���������: '..table.concat(v, ', ').. '.'
    end
end

function onHotKey(id, keys)
    thread = lua_thread.create(function()
        local sKeys = tostring(table.concat(keys, " "))
        for k, v in pairs(tBindList) do
            if sKeys == tostring(table.concat(v.v, " ")) then
                local tostr = tostring(v.text)
                if tostr:len() > 0 then
                    for line in tostr:gmatch('[^\r\n]+') do
                        if line:match("^{wait%:%d+}$") then
                            wait(line:match("^%{wait%:(%d+)}$"))
                        elseif line:match("^{screen}$") then
                            screen()
                        else
                            local bIsEnter = string.match(line, "^{noe}(.+)") ~= nil
                            local bIsF6 = string.match(line, "^{f6}(.+)") ~= nil
                            local keys = {
                                ["{f6}"] = "",
                                ["{noe}"] = "",
                                ["{myid}"] = select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)),
                                ["{kv}"] = kvadrat(),
                                ["{targetid}"] = targetid,
                                ["{targetrpnick}"] = sampGetPlayerNicknameForBinder(targetid):gsub('_', ' '),
                                ["{naparnik}"] = naparnik(),
                                ["{myrpnick}"] = sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))):gsub("_", " "),
                                ["{smsid}"] = smsid,
                                ["{smstoid}"] = smstoid,
                                ["{rang}"] = rang,
                                ["{frak}"] = frak,
                                ["{megafid}"] = gmegafid,
                                ["{dl}"] = mcid,
                                ["{post}"] = getPost()
                            }
                            for k1, v1 in pairs(keys) do
                                line = line:gsub(k1, v1)
                            end

                            if not bIsEnter then
                                if bIsF6 then
                                    sampProcessChatInput(line)
                                else
                                    sampSendChat(line)
                                end
                            else
                                sampSetChatInputText(line)
                                sampSetChatInputEnabled(true)
                            end
                        end
                    end
                end
            end
        end
    end)
end
function kvadrat()
    local KV = {
        [1] = "�",
        [2] = "�",
        [3] = "�",
        [4] = "�",
        [5] = "�",
        [6] = "�",
        [7] = "�",
        [8] = "�",
        [9] = "�",
        [10] = "�",
        [11] = "�",
        [12] = "�",
        [13] = "�",
        [14] = "�",
        [15] = "�",
        [16] = "�",
        [17] = "�",
        [18] = "�",
        [19] = "�",
        [20] = "�",
        [21] = "�",
        [22] = "�",
        [23] = "�",
        [24] = "�",
    }
    local X, Y, Z = getCharCoordinates(playerPed)
    X = math.ceil((X + 3000) / 250)
    Y = math.ceil((Y * - 1 + 3000) / 250)
    if KV[Y] ~= nil then
        Y = KV[Y]
        local KVX = (Y.."-"..X)
        return KVX
    else
        return "�� ����������"
    end
end

function isHudEnabled()
    local value = memory.read(0xBA6769, 1, true)
    if value == 1 then return true else return false end
end

function genCode(skey)
    skey = basexx.from_base32(skey)
    value = math.floor(os.time() / 30)
    value = string.char(
    0, 0, 0, 0,
    band(value, 0xFF000000) / 0x1000000,
    band(value, 0xFF0000) / 0x10000,
    band(value, 0xFF00) / 0x100,
    band(value, 0xFF))
    local hash = sha1.hmac_binary(skey, value)
    local offset = band(hash:sub(-1):byte(1, 1), 0xF)
    local function bytesToInt(a,b,c,d)
      return a*0x1000000 + b*0x10000 + c*0x100 + d
    end
    hash = bytesToInt(hash:byte(offset + 1, offset + 4))
    hash = band(hash, 0x7FFFFFFF) % 1000000
    return ('%06d'):format(hash)
end

function kvadrat1(param)
    local KV = {
        ["�"] = 1,
        ["�"] = 2,
        ["�"] = 3,
        ["�"] = 4,
        ["�"] = 5,
        ["�"] = 6,
        ["�"] = 7,
        ["�"] = 8,
        ["�"] = 9,
        ["�"] = 10,
        ["�"] = 11,
        ["�"] = 12,
        ["�"] = 13,
        ["�"] = 14,
        ["�"] = 15,
        ["�"] = 16,
        ["�"] = 17,
        ["�"] = 18,
        ["�"] = 19,
        ["�"] = 20,
        ["�"] = 21,
        ["�"] = 22,
        ["�"] = 23,
        ["�"] = 24,
        ["�"] = 1,
        ["�"] = 2,
        ["�"] = 3,
        ["�"] = 4,
        ["�"] = 5,
        ["�"] = 6,
        ["�"] = 7,
        ["�"] = 8,
        ["�"] = 9,
        ["�"] = 10,
        ["�"] = 11,
        ["�"] = 12,
        ["�"] = 13,
        ["�"] = 14,
        ["�"] = 15,
        ["�"] = 16,
        ["�"] = 17,
        ["�"] = 18,
        ["�"] = 19,
        ["�"] = 20,
        ["�"] = 21,
        ["�"] = 22,
        ["�"] = 23,
        ["�"] = 24,
    }
    return KV[param]
end

function saveData(table, path)
    local sfa = io.open(path, "w")
    if sfa then
        sfa:write(encodeJson(table))
        sfa:close()
    end
end

function getFreeSeat()
    seat = 3
    if isCharInAnyCar(PLAYER_PED) then
        local veh = storeCarCharIsInNoSave(PLAYER_PED)
        for i = 1, 3 do
            if isCarPassengerSeatFree(veh, i) then
                seat = i
            end
        end
    end
    return seat
end

function longtoshort(long)
    local short =
    {
      ['����� ��'] = 'LVa',
      ['����� ��'] = 'SFa',
      ['���'] = 'FBI'
    }
    return short[long]
end
local osnova = {
	{
		title = '�����������',
		onclick = function()
			local _, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
			sampSendChat(("/r %s � ���������� �����������."):format(cfg.main.male and '����������' or '�����������'))
	        wait(1400)
	        sampSendChat("/rb "..myid)
		end
	},
	{
		title = '�����������',
		onclick = function()
			mstype = '������������'
			sampShowDialog(1385, '{9966cc}'..script.this.name..' {ffffff}| ����������', '�������: �������', '�', 'x', 1)
		end
	},
	{
		title = '�������',
		onclick = function()
			mstype = '������������'
			sampShowDialog(1385, '{9966cc}'..script.this.name..' {ffffff}| ����������', '�������: �������', '�', 'x', 1)
		end
	},
	{
		title = '�����',
		onclick = function()
			mstype = '��������'
			sampShowDialog(1385, '{9966cc}'..script.this.name..' {ffffff}| ����������', '�������: �������', '�', 'x', 1)
		end
	},
	{
		title = '���',
		onclick = function()
			mstype = '������'
			sampShowDialog(1385, '{9966cc}'..script.this.name..' {ffffff}| ����������', '�������: �������', '�', 'x', 1)
		end
	},
	{
		title = '�����',
		onclick = function()
			mstype = '���������� �����'
			sampShowDialog(1385, '{9966cc}'..script.this.name..' {ffffff}| ����������', '�������: �������', '�', 'x', 1)
		end
	},
	{
		title = '���������',
		onclick = function()
			mstype = '��������� ���������'
			sampShowDialog(1385, '{9966cc}'..script.this.name..' {ffffff}| ����������', '�������: �������', '�', 'x', 1)
		end
	},
	{
		title = '�������',
		onclick = function()
			mstype = '��������� ��������'
			sampShowDialog(1385, '{9966cc}'..script.this.name..' {ffffff}| ����������', '�������: �������', '�', 'x', 1)
		end
	},
	{
		title = 'LCN',
		ocnlick = function()
			mstype = '��� LCN'
			sampShowDialog(1385, '{9966cc}'..script.this.name..' {ffffff}| ����������', '�������: �������', '�', 'x', 1)
		end
	},
	{
		title = 'Yakuza',
		onclick = function()
			mstype = '��� Yakuza'
			sampShowDialog(1385, '{9966cc}'..script.this.name..' {ffffff}| ����������', '�������: �������', '�', 'x', 1)
		end
	},
	{
		title = 'Russian Mafia',
		onclick = function()
			mstype = '��� Russian Mafia'
			sampShowDialog(1385, '{9966cc}'..script.this.name..' {ffffff}| ����������', '�������: �������', '�', 'x', 1)
		end
	},
	{
		title = 'Rifa',
		onclick = function()
			mstype = '�� Rifa'
			sampShowDialog(1385, '{9966cc}'..script.this.name..' {ffffff}| ����������', '�������: �������', '�', 'x', 1)
		end
	},
	{
		title = 'Grove',
		onclick = function()
			mstype = '�� Grove'
			sampShowDialog(1385, '{9966cc}'..script.this.name..' {ffffff}| ����������', '�������: �������', '�', 'x', 1)
		end
	},
	{
		title = 'Ballas',
		onclick = function()
			mstype = '�� Ballas'
			sampShowDialog(1385, '{9966cc}'..script.this.name..' {ffffff}| ����������', '�������: �������', '�', 'x', 1)
		end
	},
	{
		title = 'Vagos',
		onclick = function()
			mstype = '�� Vagos'
			sampShowDialog(1385, '{9966cc}'..script.this.name..' {ffffff}| ����������', '�������: �������', '�', 'x', 1)
		end
	},
	{
		title = 'Aztec',
		onclick = function()
			mstype = '�� Aztec'
			sampShowDialog(1385, '{9966cc}'..script.this.name..' {ffffff}| ����������', '�������: �������', '�', 'x', 1)
		end
	},
	{
		title = '�������',
		onclick = function()
			mstype = '��������'
			sampShowDialog(1385, '{9966cc}'..script.this.name..' {ffffff}| ����������', '�������: �������', '�', 'x', 1)
		end
	}
}

local tCarsName = {"Landstalker", "Bravura", "Buffalo", "Linerunner", "Perrenial", "Sentinel", "Dumper", "Firetruck", "Trashmaster", "Stretch", "Manana", "Infernus",
"Voodoo", "Pony", "Mule", "Cheetah", "Ambulance", "Leviathan", "Moonbeam", "Esperanto", "Taxi", "Washington", "Bobcat", "Whoopee", "BFInjection", "Hunter",
"Premier", "Enforcer", "Securicar", "Banshee", "Predator", "Bus", "Rhino", "Barracks", "Hotknife", "Trailer", "Previon", "Coach", "Cabbie", "Stallion", "Rumpo",
"RCBandit", "Romero","Packer", "Monster", "Admiral", "Squalo", "Seasparrow", "Pizzaboy", "Tram", "Trailer", "Turismo", "Speeder", "Reefer", "Tropic", "Flatbed",
"Yankee", "Caddy", "Solair", "Berkley'sRCVan", "Skimmer", "PCJ-600", "Faggio", "Freeway", "RCBaron", "RCRaider", "Glendale", "Oceanic", "Sanchez", "Sparrow",
"Patriot", "Quad", "Coastguard", "Dinghy", "Hermes", "Sabre", "Rustler", "ZR-350", "Walton", "Regina", "Comet", "BMX", "Burrito", "Camper", "Marquis", "Baggage",
"Dozer", "Maverick", "NewsChopper", "Rancher", "FBIRancher", "Virgo", "Greenwood", "Jetmax", "Hotring", "Sandking", "BlistaCompact", "PoliceMaverick",
"Boxvillde", "Benson", "Mesa", "RCGoblin", "HotringRacerA", "HotringRacerB", "BloodringBanger", "Rancher", "SuperGT", "Elegant", "Journey", "Bike",
"MountainBike", "Beagle", "Cropduster", "Stunt", "Tanker", "Roadtrain", "Nebula", "Majestic", "Buccaneer", "Shamal", "hydra", "FCR-900", "NRG-500", "HPV1000",
"CementTruck", "TowTruck", "Fortune", "Cadrona", "FBITruck", "Willard", "Forklift", "Tractor", "Combine", "Feltzer", "Remington", "Slamvan", "Blade", "Freight",
"Streak", "Vortex", "Vincent", "Bullet", "Clover", "Sadler", "Firetruck", "Hustler", "Intruder", "Primo", "Cargobob", "Tampa", "Sunrise", "Merit", "Utility", "Nevada",
"Yosemite", "Windsor", "Monster", "Monster", "Uranus", "Jester", "Sultan", "Stratum", "Elegy", "Raindance", "RCTiger", "Flash", "Tahoma", "Savanna", "Bandito",
"FreightFlat", "StreakCarriage", "Kart", "Mower", "Dune", "Sweeper", "Broadway", "Tornado", "AT-400", "DFT-30", "Huntley", "Stafford", "BF-400", "NewsVan",
"Tug", "Trailer", "Emperor", "Wayfarer", "Euros", "Hotdog", "Club", "FreightBox", "Trailer", "Andromada", "Dodo", "RCCam", "Launch", "PoliceCar", "PoliceCar",
"PoliceCar", "PoliceRanger", "Picador", "S.W.A.T", "Alpha", "Phoenix", "GlendaleShit", "SadlerShit", "Luggage A", "Luggage B", "Stairs", "Boxville", "Tiller",
"UtilityTrailer"}
local tCarsTypeName = {"����������", "���������", "�������", "������", "������", "�����", "������", "�����", "���������"}
local tCarsSpeed = {43, 40, 51, 30, 36, 45, 30, 41, 27, 43, 36, 61, 46, 30, 29, 53, 42, 30, 32, 41, 40, 42, 38, 27, 37,
54, 48, 45, 43, 55, 51, 36, 26, 30, 46, 0, 41, 43, 39, 46, 37, 21, 38, 35, 30, 45, 60, 35, 30, 52, 0, 53, 43, 16, 33, 43,
29, 26, 43, 37, 48, 43, 30, 29, 14, 13, 40, 39, 40, 34, 43, 30, 34, 29, 41, 48, 69, 51, 32, 38, 51, 20, 43, 34, 18, 27,
17, 47, 40, 38, 43, 41, 39, 49, 59, 49, 45, 48, 29, 34, 39, 8, 58, 59, 48, 38, 49, 46, 29, 21, 27, 40, 36, 45, 33, 39, 43,
43, 45, 75, 75, 43, 48, 41, 36, 44, 43, 41, 48, 41, 16, 19, 30, 46, 46, 43, 47, -1, -1, 27, 41, 56, 45, 41, 41, 40, 41,
39, 37, 42, 40, 43, 33, 64, 39, 43, 30, 30, 43, 49, 46, 42, 49, 39, 24, 45, 44, 49, 40, -1, -1, 25, 22, 30, 30, 43, 43, 75,
36, 43, 42, 42, 37, 23, 0, 42, 38, 45, 29, 45, 0, 0, 75, 52, 17, 32, 48, 48, 48, 44, 41, 30, 47, 47, 40, 41, 0, 0, 0, 29, 0, 0
}
local tCarsType = {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 3, 1, 1, 1, 1, 1, 1, 1,
3, 1, 1, 1, 1, 6, 1, 1, 1, 1, 5, 1, 1, 1, 1, 1, 7, 1, 1, 1, 1, 6, 3, 2, 8, 5, 1, 6, 6, 6, 1,
1, 1, 1, 1, 4, 2, 2, 2, 7, 7, 1, 1, 2, 3, 1, 7, 6, 6, 1, 1, 4, 1, 1, 1, 1, 9, 1, 1, 6, 1,
1, 3, 3, 1, 1, 1, 1, 6, 1, 1, 1, 3, 1, 1, 1, 7, 1, 1, 1, 1, 1, 1, 1, 9, 9, 4, 4, 4, 1, 1, 1,
1, 1, 4, 4, 2, 2, 2, 1, 1, 1, 1, 1, 1, 1, 1, 7, 1, 1, 1, 1, 8, 8, 7, 1, 1, 1, 1, 1, 1, 1,
1, 3, 1, 1, 1, 1, 4, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 7, 1, 1, 1, 1, 8, 8, 7, 1, 1, 1, 1, 1, 4,
1, 1, 1, 2, 1, 1, 5, 1, 2, 1, 1, 1, 7, 5, 4, 4, 7, 6, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 5, 5, 5, 1, 5, 5
}


function goupdate()
    ftext('�������� ���������� ����������. ������ �������������� ����� ���� ������.', -1)
    wait(300)
    downloadUrlToFile(updatelink, thisScript().path, function(id3, status1, p13, p23)
        if status1 == dlstatus.STATUS_ENDDOWNLOADDATA then
            thisScript():reload()
        elseif status1 == 64 then
            ftext("���������� ���������� ������ �� �������. �������� ������ ������")
        end
    end)
end

function update()
    httpRequest("https://raw.githubusercontent.com/WhackerH/kirya/master/update.json", _, function(response, code, headers, status)
        if response then
            local info = decodeJson(response)
            updatelink = info.global.updateurl
            ttt = info.global.updlist
            if tonumber(thisScript().version) < tonumber(info.global.latest) then
                ftext('���������� ���������� {9966cc}'..script.this.name..'{ffffff}. ��� ���������� ������� ������ � ������.')
                ftext('����������: ���� � ��� �� ��������� ������ ������� {9966cc}/ft')
                updwindows.v = true
                canupdate = true
            else
                print('���������� ������� �� ����������. �������� ����.')
                update = false
            end
            if trash.isTester then
                if test_version < info.test.latest then
                    if info.test.access then
                        trash.newversion = info.test.latest
                        trash.url = info.test.updateurl
                        ftext("�������� ����� ���������� ������. ��� ������ ������� /testupdate")
                    end
                end
            end
        else
            print("��������� ������� �������� ����������")
        end
    end)
end

function libs()
    local files = {}
    local direct = {}
    if not lsha1 then files[#files + 1] = 'sha1.lua' end
    if not lbasexx then files[#files + 1] = 'basexx.lua' end
    if not lcopas or not lhttp then
        print("lcopas: "..tostring(lcopas))
        print("lhttp: "..tostring(lhttp))
        for k, v in pairs({"copas", "mime", "socket", "ssl"}) do direct[#direct + 1] = v end
        for k, v in pairs({"copas.lua", "copas/ftp.lua", 'copas/http.lua', 'copas/limit.lua', 'copas/smtp.lua', "mime.lua", "mime/core.dll", "socket.lua", "socket/core.dll", "lib/copas/http.lua", "socket/ftp.lua", "socket/headers.lua", "socket/smtp.lua", "socket/tp.lua", "socket/url.lua", "ssl.lua", "ssl.dll", "ssl/https.lua", "ltn12.lua"}) do 
            if doesFileExist("moonloader/lib/"..v) then os.remove("moonloader/lib/"..v) end
            files[#files + 1] = "lib/"..v 
        end
    end
    if not limgui then
        files[#files + 1] = "lib/imgui.lua"
        files[#files + 1] = "lib/MoonImGui.dll"
    end
    if not limadd then files[#files + 1] = "imgui_addons.lua" end
    if not lsampev then
        for k, v in pairs({'samp', 'samp/events'}) do
            direct[#direct + 1] = "lib/"..v
        end
        for k, v in pairs({'events.lua', 'raknet.lua', 'synchronization.lua', 'events/bitstream_io.lua', 'events/core.lua', 'events/extra_types.lua', 'events/handlers.lua', 'events/utils.lua'}) do
            files[#files + 1] = "lib/samp/"..v
        end
    end
    if not lrkeys then files[#files + 1] = "lib/rkeys.lua" end
    if not bNotf then files[#files + 1] = "imgui_notf.lua" end

    if #files > 0 or #direct > 0 then
        lua_thread.create(function()
            while not isSampAvailable() do wait(0) end
            ftext('������ �������� ����������� ���������')
            ftext('�� ��������� �������� ������ ����� ������������')
        end)
        print("���� ���������: "..#files.." | ���� �������: "..#direct)
        
        for k, v in pairs(direct) do if not doesDirectoryExist("moonloader/lib/"..v) then createDirectory("moonloader/lib/"..v) end end
        for k, v in pairs(files) do
            local v1
            if v:match("lib/.+") then v1 = v:match("lib/(.+)") end
            print('https://raw.githubusercontent.com/WhackerH/kirya/master/lib/'..v1)
            local download_status = 'proccess'
            downloadUrlToFile('https://raw.githubusercontent.com/WhackerH/kirya/master/lib/'..v1, 'moonloader/'..v, function(id, status, p1, p2)
                if status == dlstatus.STATUS_DOWNLOADINGDATA then
                    download_status = 'proccess'
                    print(string.format('��������� %d �������� �� %d ��������.', p1, p2))
                elseif status == dlstatus.STATUS_ENDDOWNLOADDATA then
                    download_status = 'succ'
                elseif status == 64 then
                    download_status = 'failed'
                end
            end)
            while download_status == 'proccess' do wait(0) end
            if download_status == 'failed' then
                lua_thread.create(function()
                    while not isSampAvailable() do wait(0) end
                    ftext('�� ������� ��������� ���������� '..v)
                    thisScript():unload()
                end)
            else
                print('���������� '..v..' ���� ���������. ��������:'..#files-k)
            end
            wait(500)
        end
        thisScript():reload()
    end
end

function checkStats()
    while not sampIsLocalPlayerSpawned() do wait(0) end
    checkstat = true
    sampSendChat('/stats')
	local chtime = os.clock() + 10
    while chtime > os.clock() do wait(0) end
    local chtime = nil
    checkstat = false
    if rang == -1 and frak == -1 then
        ftext('�� ������� ���������� ���������� ���������. ��������� �������?', -1)
        ftext('�����������: {9966cc}'..table.concat(rkeys.getKeysName(config_keys.oopda.v), " + ")..'{ffffff} | ��������: {9966cc}'..table.concat(rkeys.getKeysName(config_keys.oopnet.v), " + "), -1)
        opyatstat = true
    end
end

function filesf()
    local files = {"ak", "yk", "fp"}
    for k, v in pairs(files) do
        if not doesFileExist('moonloader/fbitools/'..v..'.txt') then
            print("�������� ������� ����� "..v..".txt")
            httpRequest("https://raw.githubusercontent.com/WhackerH/kirya/master/"..v..".txt", _, function(response, code, headers, status) 
                if response then
                    local file = io.open('moonloader/fbitools/'..v..'.txt', 'w')
                    file:write(u8:decode(response))
                    file:close()
                    print("���� "..v..".txt ������� ��������")
                else
                    local file = io.open("moonloader/fbitools/"..v..".txt", "w")
                    file:write("��������� ������ ������� "..v..".\n�������� ����� ���� ����� ����� � �����: moonloader/fbitools/"..v..".txt")
                    file:close()
                    print("��������� ������ ������� "..v..".txt")
                end
            end)
        end
    end
    if not doesFileExist("moonloader/fbitools/shp.txt") then
        local file = io.open("moonloader/fbitools/shp.txt", 'w')
        file:write(shpt)
        file:close()
    end
    if not doesFileExist('moonloader/fbitools/mcheck.txt') then io.open("moonloader/fbitools/mcheck.txt", "w"):close() end
end

function suf()
    if not doesFileExist('moonloader/fbitools/su.txt') then
        local file = io.open('moonloader/fbitools/su.txt', 'w')
        file:write(sut)
        file:close()
        file = nil
    end
end

function sampGetPlayerNicknameForBinder(nikkid)
    local nick = '-1'
    local nickid = tonumber(nikkid)
    if nickid ~= nil then
        if sampIsPlayerConnected(nickid) then
            nick = sampGetPlayerNickname(nickid)
        end
    end
    return nick
end

function sumenu(args)
    return
    {
      {
        title = '{5b83c2}� ������ �1 �',
        onclick = function()
        end
      },
      {
        title = '{ffffff}� �������� - {ff0000}2 ������� �������.',
        onclick = function()
          sampSendChat("/su "..args.." 2 ��������")
        end
      },
      {
        title = '{ffffff}� ����������� ��������� �� ������������ - {ff0000}3 ������� �������.',
        onclick = function()
          sampSendChat("/su "..args.." 3 ����������� ��������� �� ������������")
        end
      },
      {
        title = '{ffffff}� ����������� ��������� �� ���.��������� - {ff0000}6 ������� �������.',
        onclick = function()
          sampSendChat("/su "..args.." 6 ����������� ��������� �� ��")
        end
      },
      {
        title = '{ffffff}� �������� �������� - {ff0000}3 ������� �������.',
        onclick = function()
          sampSendChat("/su "..args.." 3 �������� ��������")
        end
      },
      {
        title = '{ffffff}� ����������� - {ff0000}1 ������� �������.',
        onclick = function()
          sampSendChat("/su "..args.." 1 �����������")
        end
      },
      {
        title = '{ffffff}� ������������ ��������� - {ff0000}1 ������� �������.',
        onclick = function()
          sampSendChat("/su "..args.." 1 ������������ ���������")
        end
      },
      {
        title = '{ffffff}� ���������������� - {ff0000}1 ������� �������.',
        onclick = function()
          sampSendChat("/su "..args.." 1 ����������������")
        end
      },
      {
        title = '{ffffff}� ����������� - {ff0000}2 ������� �������.',
        onclick = function()
          sampSendChat("/su "..args.." 2 �����������")
        end
      },
      {
        title = '{ffffff}� ����� �� �������� - {ff0000}2 ������� �������.',
        onclick = function()
          sampSendChat("/su "..args.." 2 ����� �� ��������")
        end
      },
      {
        title = '{ffffff}� ������������� ����.������� - {ff0000}1 ������� �������.',
        onclick = function()
          sampSendChat("/su "..args.." 1 ������������� ����.�������")
        end
      },
      {
        title = '{ffffff}� ���� ������������� �������� - {ff0000}2 ������� �������.',
        onclick = function()
          sampSendChat("/su "..args.." 2 ���� ������������� ��������")
        end
      },
      {
        title = '{ffffff}� ����� ������ ��������� - {ff0000}1 ������� �������.',
        onclick = function()
          sampSendChat("/su "..args.. " 1 ����� ������ ���������")
        end
      },
      {
        title = '{ffffff}� ����������� ������ ��������� - {ff0000}4 ������� �������.',
        onclick = function()
          sampSendChat("/su "..args.." 4 ����������� ������ ���������")
        end
      },
      {
        title = '{ffffff}� ������������ ���������� �� - {ff0000}1 ������� �������.',
        onclick = function()
          sampSendChat("/su "..args.." 1 ������������ ���������� ��")
        end
      },
      {
        title = '{ffffff}� ���� �� ���������� �� - {ff0000}2 ������� �������',
        onclick = function()
          sampSendChat("/su "..args.." 2 ���� �� ���������� ��")
        end
      },
      {
          title = '{ffffff}� ���� � ����� ��� - {ff0000}3 ������� �������',
          onclick = function()
            sampSendChat('/su '..args.. ' 3 ���� � ����� ���')
          end
      },
      {
        title = '{ffffff}� ����� �� ����� ���������� - {ff0000}6 ������� �������.',
        onclick = function()
          sampSendChat("/su "..args.." 6 ����� �� ����� ����������")
        end
      },
      {
        title = '{ffffff}� ������������� �� ���������� ���������� - {ff0000}2 ������� �������.',
        onclick = function()
          sampSendChat("/su "..args.." 2 ������������� �� ���. ����������")
        end
      },
      {
        title = '{ffffff}� ���������� - {ff0000}2 ������� �������.',
        onclick = function()
          sampSendChat("/su "..args.." 2 ����������")
        end
      },
      {
        title = '{ffffff}� ������ - {ff0000}1 ������� �������.',
        onclick = function()
          sampSendChat("/su "..args.." 1 ������")
        end
      },
      {
        title = '{ffffff}� ����������� �����. ����� - {ff0000}1 ������� �������',
        onclick = function()
          sampSendChat('/su '..args..' 1 ����������� �������� �����')
        end
      },
      {
        title = '{ffffff}� ������������� - {ff0000}3 ������� �������',
        onclick = function()
          sampSendChat('/su '..args..' 3 �������������')
        end
      },
      {
        title = '{ffffff}� �������������� ��������� - {ff0000}1 ������� �������.',
        onclick = function()
          local result = isCharInAnyCar(PLAYER_PED)
          if result then
            sampSendChat("/clear "..args)
            wait(1400)
            sampSendChat("/su "..args.." 1 �������������� ���������")
          else
            ftext("�� ������ ���������� � ������")
          end
        end
      },
      {
        title = '{ffbc54}� ������ �2 �',
        onclick = function()
        end
      },
      {
        title = '{ffffff}� �������� ���������� - {ff0000}3 ������� �������.',
        onclick = function()
          sampSendChat("/su "..args.." 3 �������� ����������")
        end
      },
      {
        title = '{ffffff}� �������� ���������� - {ff0000}3 ������� �������.',
        onclick = function()
          sampSendChat("/su "..args.." 3 �������� ����������")
        end
      },
      {
        title = '{ffffff}� ������� ������ �� ������ - {ff0000}6 ������� �������',
        onclick = function()
          sampSendChat("/su "..args.." 6 ������� ������ �� ������")
        end
      },
      {
        title = '{ffffff}� ������������ ���������� - {ff0000}3 ������� �������',
        onclick = function()
          sampSendChat("/su "..args.." 3 ������������ ����������")
        end
      },
      {
        title = '{ffffff}� ������� ���������� - {ff0000}2 ������� �������',
        onclick = function()
          sampSendChat("/su "..args.." 2 ������� ����������")
        end
      },
      {
        title = '{ffffff}� ������� ������� ����� - {ff0000}2 ������� �������',
        onclick = function()
          sampSendChat("/su "..args.." 2 ������� ������� �����")
        end
      },
      {
        title = '{ffffff}� ����������� ������ ���.��������� - {ff0000}2 ������� �������.',
        onclick = function()
          sampSendChat("/su "..args.." 2 ����������� ������ ���.���������")
        end
      },
      {
        title = '{ae0620}� ������ �3 �',
        onclick = function()
        end
      },
      {
        title = '{ffffff}� ���� � AFK �� ������ - {ff0000}6 ������� �������.',
        onclick = function()
          sampSendChat("/su "..args.." 6 ����")
        end
      },
      {
        title = '{ffffff}� ���������� �������� - {ff0000}6 ������� �������.',
        onclick = function()
          sampSendChat("/su "..args.." 6 ���������� �������")
        end
      },
      {
        title = '{ffffff}� �������� ������ - {ff0000}2 ������� �������.',
        onclick = function()
          sampSendChat("/su "..args.." 2 �������� ������")
        end
      },
      {
        title = '{ffffff}� ���������� ���������� �������� - {ff0000}3 ������� �������.',
        onclick = function()
          sampSendChat("/su "..args.." 3 ���������� ���������� ��������")
        end
      },
      {
        title = '{ffffff}� ��������� ������������/���.��������� - {ff0000}4 ������� �������',
        onclick = function()
          sampSendChat("/su "..args.." 4 ���������")
        end
      },
      {
        title = '{ffffff}� ������ ��� - {ff0000}6 ������� �������',
        onclick = function()
          sampSendChat("/su "..args.." 6 ���")
        end
      }
    }
end

function getDriveLicenseCount(id)
    local lvl = sampGetPlayerScore(id)
    if lvl <= 2 then return 500
    elseif lvl >= 3 and lvl <= 5 then return 5000
    elseif lvl >= 6 and lvl <= 15 then return 10000
    elseif lvl >= 16 then return 30000 end
end

function giveLicense(id, list)
    ins.list = list
    ins.isLicense = true
    sampSendChat(("/me %s ����� � ����������"):format(cfg.main.male and "������" or "�������"))
    wait(cfg.commands.zaderjka)
    sampSendChat("/do �������� � ����.")
    wait(cfg.commands.zaderjka)
    sampSendChat(("/me %s ������ \"Autoschool San Fierro\" � %s ��������"):format(cfg.main.male and "��������" or "���������", cfg.main.male and "�������" or "��������"))
    wait(1400)
    sampSendChat(("/givelicense %s"):format(id))
end

function healPlayer(id, head)
    sampSendChat(("/me %s �������"):format(cfg.main.male and "������" or "�������"))
    wait(cfg.commands.zaderjka)
    sampSendChat(("/me %s ����������� ��������"):format(cfg.main.male and "�����" or "�����"))
    wait(cfg.commands.zaderjka)
    sampSendChat(("/do %s � �����"):format(head and "�������" or "�����"))
    wait(cfg.commands.zaderjka)
    sampSendChat(("/me %s �������� ��������� � %s ������ �����"):format(cfg.main.male and "�������" or "��������", cfg.main.male and "���" or "����"))
    wait(1400)
    sampSendChat(("/heal %s"):format(id))
end

function pkmmenuMOH(id)
    return
    {
        {
            title = "��������",
            submenu = {
                {
                    title = "������",
                    onclick = function()
                        healPlayer(id, true)
                    end
                },
                {
                    title = "������",
                    onclick = function()
                        healPlayer(id, false)
                    end
                },
                {
                    title = "�����",
                    onclick = function()
                        sampSendChat(("/me %s �����"):format(cfg.main.male and "��������" or "���������"))
                        wait(cfg.commands.zaderjka)
                        sampSendChat(("/me %s �������"):format(cfg.main.male and "������" or "�������"))
                        wait(cfg.commands.zaderjka)
                        sampSendChat(("/me %s ����������� ��������"):format(cfg.main.male and "�����" or "�����"))
                        wait(cfg.commands.zaderjka)
                        sampSendChat("/do ��������� � �����")
                        wait(cfg.commands.zaderjka)
                        sampSendChat(("/me %s �������� ��������� � %s ������ �����"):format(cfg.main.male and "�������" or "��������", cfg.main.male and "���" or "����"))
                        wait(1400)
                        sampSendChat(("/heal %s"):format(id))
                    end
                }
            }
        },
        {
            title = "� �������� �����",
            onclick = function()
                sampSendChat("/do ����� � ����.")
                wait(cfg.commands.zaderjka)
                sampSendChat(("/me %s ����� ��������� ���.������� � %s ����� �����"):format(cfg.main.male and "����" or "�����", cfg.main.male and "���������" or "����������"))
                wait(cfg.commands.zaderjka)
                sampSendChat(("/me %s ���� �� ���� ��������, ����� ���� %s ��������"):format(cfg.main.male and "�������" or "��������", cfg.main.male and "����" or "�����"))
                wait(cfg.commands.zaderjka)
                sampSendChat(("/me %s ���� � %s ����� � ����� �����"):format(cfg.main.male and "����" or "�����", cfg.main.male and "��������" or "���������"))
                wait(1400)
                sampSendChat(("/healaddict %s 10000"):format(id))
            end
        },
        {
            title = "� ������� �������",
            onclick = function()
                sampSendChat(("/me %s ������������� �������"):format(cfg.main.male and "�������" or "��������"))
                wait(cfg.commands.zaderjka)
                sampSendChat("/do ������������� ������� �������.")
                wait(cfg.commands.zaderjka)
                sampSendChat(("/me %s ������������� ��������� �� ������������� �������"):format(cfg.main.male and "������" or "�������"))
                wait(cfg.commands.zaderjka)
                sampSendChat("/me ������������� ������")
                wait(cfg.commands.zaderjka)
                sampSendChat(("/try %s �������"):format(cfg.main.male and "���������" or "����������"))
            end
        },
        {
            title = "� �������� ������� �����������",
            onclick = function()
                sampSendChat(("/me %s �� ����� �������� � %s ��"):format(cfg.main.male and "����" or "�����", cfg.main.male and "�����" or "������"))
                wait(cfg.commands.zaderjka)
                sampSendChat(("/me %s ����� � ��������������, ����� ���� %s ������������ �������"):format(cfg.main.male and "����" or "�����", cfg.main.male and "���������" or "����������"))
                wait(cfg.commands.zaderjka)
                sampSendChat(("/me %s ��������� ������������� �������"):format(cfg.main.male and "������" or "�������"))
                wait(cfg.commands.zaderjka)
                sampSendChat(("/me %s ���� ����� �����, ����� ���� %s �������� �������"):format(cfg.main.male and "��������" or "���������", cfg.main.male and "����" or "������"))
                wait(cfg.commands.zaderjka)
                sampSendChat(("/me %s ����, ����� ���� ������������ �������"):format(cfg.main.male and "�������" or "��������"))
                wait(cfg.commands.zaderjka)
                sampSendChat("��������� ����� �����. ����� �������!")
                wait(cfg.commands.zaderjka)
                sampSendChat(("/me %s �������� � %s �� � ���� ����� �����"):format(cfg.main.male and "����" or "�����", cfg.main.male and "������" or "�������"))
            end
        },
        {
            title = "� �������� ������� ������������ / �����",
            onclick = function()
                sampSendChat(("/me ��������� %s ������������� �� ������������ ����"):format(cfg.main.male and "�����" or "������"))
                wait(cfg.commands.zaderjka)
                sampSendChat(("/me %s �� ����� �������� � %s ��"):format(cfg.main.male and "����" or "�����", cfg.main.male and "�����" or "������"))
                wait(cfg.commands.zaderjka)
                sampSendChat(("/me %s ������������� � ����������"):format(cfg.main.male and "���������" or "����������"))
                wait(cfg.commands.zaderjka)
                sampSendChat(("/me %s ����� ������� � %s ���� �� ���� ��������"):format(cfg.main.male and "�������" or "��������", cfg.main.male and "���������" or "����������"))
                wait(cfg.commands.zaderjka)
                sampSendChat(("/me ����������� %s ��������"):format(cfg.main.male and "����" or "�����"))
                wait(cfg.commands.zaderjka)
                sampSendChat("/do ������ �������� �����������, ������� ������� ��������.")
                wait(cfg.commands.zaderjka)
                sampSendChat(("/me %s ��������� � ������"):format(cfg.main.male and "������" or "�������"))
                wait(cfg.commands.zaderjka)
                sampSendChat(("/me � ������� ��������� ������������ %s ��������� ������������� �������"):format(cfg.main.male and "��������" or "���������"))
                wait(cfg.commands.zaderjka)
                sampSendChat(("/me %s �� �������� ����������� ������"):format(cfg.main.male and "������" or "�������"))
                wait(cfg.commands.zaderjka)
                sampSendChat(("/me %s ������������ ������� � ������� �������"):format(cfg.main.male and "������������" or "�������������"))
                wait(cfg.commands.zaderjka)
                sampSendChat(("/me %s �������� � %s �� � ���� ����� �����"):format(cfg.main.male and "����" or "�����", cfg.main.male and "������" or "�������"))
                wait(cfg.commands.zaderjka)
                sampSendChat(("/me %s � ��������� ��������� ������� ��������������"):format(cfg.main.male and "�����" or "������"))
                wait(cfg.commands.zaderjka)
                sampSendChat("/do ������ ��������� �����, ������� ������ � ��������.")
            end
        },
        {
            title = "� �������� �����",
            onclick = function()
                sampSendChat(("/me %s �� ����� �������� � %s ��"):format(cfg.main.male and "����" or "�����", cfg.main.male and "�����" or "������"))
                wait(cfg.commands.zaderjka)
                sampSendChat(("/me %s ������ ��������"):format(cfg.main.male and "������" or "�������"))
                wait(cfg.commands.zaderjka)
                sampSendChat(("/me %s ������� ������� ������ � ��������"):format(cfg.main.male and "���������" or "����������"))
                wait(cfg.commands.zaderjka)
                sampSendChat(("/me %s ������������ �������"):format(cfg.main.male and "���������" or "����������"))
                wait(cfg.commands.zaderjka)
                sampSendChat(("/me %s �� ���. ����� ���� � %s ��� ������ �����������"):format(cfg.main.male and "������" or "�������", cfg.main.male and "�������" or "��������"))
                wait(cfg.commands.zaderjka)
                sampSendChat(("/me %s ������������� ����������� �� �����"):format(cfg.main.male and "��������" or "���������"))
                wait(cfg.commands.zaderjka)
                sampSendChat(("/me %s ����������� ���� � ����"):format(cfg.main.male and "����" or "�����"))
                wait(cfg.commands.zaderjka)
                sampSendChat(("/me %s ����������� ����� � %s �����"):format(cfg.main.male and "�����" or "������", cfg.main.male and "��������" or "���������"))
                wait(cfg.commands.zaderjka)
                sampSendChat(("/me %s ����� � %s ����� ������"):format(cfg.main.male and "������" or "��������", cfg.main.male and "�����" or "������"))
                wait(cfg.commands.zaderjka)
                sampSendChat(("/me %s ���� � ���� � �������"):format(cfg.main.male and "�������" or "��������"))
                wait(cfg.commands.zaderjka)
                sampSendChat(("/me %s ����, %s ����� � %s ������������ ������� ����"):format(cfg.main.male and "����" or "�����", cfg.main.male and "����" or "�����", cfg.main.male and "������������" or "�������������"))
                wait(cfg.commands.zaderjka)
                sampSendChat(("/me %s � ��������� ��������� ������� ��������������"):format(cfg.main.male and "�����" or "������"))
            end
        },
        {
            title = "������� �������",
            submenu = {
                {
                    title = "� �������� ���������",
                    onclick = function()
                        sampSendChat(("/me %s ������ ��������"):format(cfg.main.male and "������" or "�������"))
                        wait(cfg.commands.zaderjka)
                        sampSendChat(("/me %s �������� �������� ������� � ��������"):format(cfg.main.male and "������" or "�������"))
                        wait(cfg.commands.zaderjka)
                        sampSendChat(("/me %s �� ���. ����� � %s ���������� ��������"):format(cfg.main.male and "������" or "�������", cfg.main.male and "�����" or "������"))
                        wait(cfg.commands.zaderjka)
                        sampSendChat(("/me %s � %s ������� ��� �������"):format(cfg.main.male and "��������" or "���������", cfg.main.male and "�������" or "��������"))
                        wait(cfg.commands.zaderjka)
                        sampSendChat(("/me %s ����� ��� ������� ��������"):format(cfg.main.male and "�����" or "������"))
                        wait(cfg.commands.zaderjka)
                        sampSendChat("/do ������� ������.")
                        wait(cfg.commands.zaderjka)
                        sampSendChat(("/me %s ������������� ����������� �� ����� � %s �����"):format(cfg.main.male and "��������" or "���������", cfg.main.male and "����" or "�����"))
                        wait(cfg.commands.zaderjka)
                        sampSendChat(("/me %s ���� �������� � %s �����"):format(cfg.main.male and "���������" or "����������", cfg.main.male and "����" or "�����"))
                        wait(cfg.commands.zaderjka)
                        sampSendChat(("/try %s ����"):format(cfg.main.male and "�������" or "��������"))
                        return true
                    end
                },
                {
                    title = "� ����������� ���� {63c600}[������]",
                    onclick = function()
                        sampSendChat(("/me %s ����, %s ���. ���� � ���. ���� � %s ���� ��������"):format(cfg.main.male and "�������" or "��������", cfg.main.male and "����" or "�����", cfg.main.male and "�����" or "������"))
                        wait(cfg.commands.zaderjka)
                        sampSendChat(("/me %s ����� � %s �� �������"):format(cfg.main.male and "������" or "�������", cfg.main.male and "�������" or "��������"))
                        wait(cfg.commands.zaderjka)
                        sampSendChat(("/me %s � %s ���������� �������� "):format(cfg.main.male and "����" or "�����", cfg.main.male and "�������" or "��������"))
                        wait(cfg.commands.zaderjka)
                        sampSendChat(("/me %s ������� ��� ������� � %s ����� � ��������"):format(cfg.main.male and "��������" or "���������", cfg.main.male and "����" or "�����"))
                        wait(cfg.commands.zaderjka)
                        sampSendChat("/do ������� ��������� ")
                        wait(1400)
                        sampSendChat("��� ������� ���������� �����. ���������������")
                    end
                },
                {
                    title = "� ����������� {bf0000}[��������]",
                    onclick = function()
                        sampSendChat(("/me %s ����� ������"):format(cfg.main.male and "�����" or "�������"))
                        wait(cfg.commands.zaderjka)
                        sampSendChat(("/try %s ����"):format(cfg.main.male and "�������" or "��������"))
                        return true
                    end
                }
            }
        }
    }
end

function pkmmenuAS(id)
    return
    {
        {
            title = "{FFFFFF}������ ��������",
            submenu = {
                {
                    title = "� ������������ �����",
                    onclick = function()
                        if sampIsPlayerConnected(id) then
                            giveLicense(id, 0)
                        end
                    end
                },
                {
                    title = "� ��������� ���������",
                    onclick = function()
                        if sampIsPlayerConnected(id) then
                            giveLicense(id, 1)
                        end
                    end
                },
                {
                    title = "� ������ ���������",
                    onclick = function()
                        if sampIsPlayerConnected(id) then
                            giveLicense(id, 3)
                        end
                    end
                },
                {
                    title = "� �������� �� ������",
                    onclick = function()
                        if sampIsPlayerConnected(id) then
                            giveLicense(id, 4)
                        end
                    end
                },
                {
                    title = "� �������� �� �����������",
                    onclick = function()
                        if sampIsPlayerConnected(id) then
                            giveLicense(id, 2)
                        end
                    end
                },
                {
                    title = "� �������� �� ������",
                    onclick = function()
                        if sampIsPlayerConnected(id) then
                            giveLicense(id, 5)
                        end
                    end
                }
            }
        },
        {
            title = "{FFFFFF}������ �������",
            submenu = {
                {
                    title = "{FFFFFF}� ������������ �������� � ������ {6495ED}[�����: {FFFFFF}50{6495ED}]",
                    onclick = function() sampSendChat("����� ������������ �������� ��������� � ������?") end
                },
                {
                    title = "{FFFFFF}� ������������ �������� � ����� ����� {6495ED}[�����: {FFFFFF}30{6495ED}]",
                    onclick = function() sampSendChat("����� ������������ �������� ��������� � ����� �����?") end
                },
                {
                    title = "{FFFFFF}� � ����� ������� �������� ����� {6495ED}[�����: {FFFFFF}� �����{6495ED}]",
                    onclick = function() sampSendChat("� ����� ������� �������� �����?") end
                },
                {
                    title = "{FFFFFF}� ����� �� ��������������� �� �������� ����� {6495ED}[�����: {FFFFFF}���{6495ED}]",
                    onclick = function() sampSendChat("����� �� ��������������� �� �������� �����?") end
                },
                {
                    title = "{FFFFFF}� ���� ������� ������",
                    onclick = function() sampSendChat("����� ��� �������� �� ������?") end
                },
                {
                    title = "{FFFFFF}� �������� ������",
                    onclick = function() sampSendChat("��� �� ������ ������� ������?") end
                }
            }
        },
        {
            title = "{FFFFFF}�������� ���� �� ���������",
            submenu = {
                {
                    title = "� ������������ �����",
                    onclick = function() sampSendChat(("�������� ����� ������ %s$. ���������?"):format(getDriveLicenseCount(id))) end
                },
                {
                    title = "� ��������� ���������",
                    onclick = function() sampSendChat("�������� ����� ������ 10000$. ���������?") end
                },
                {
                    title = "� ������ ���������",
                    onclick = function() sampSendChat("�������� ����� ������ 5000$. ���������?") end
                },
                {
                    title = "� �������� �� ������",
                    onclick = function() sampSendChat("�������� ����� ������ 50000$. ���������?") end
                },
                {
                    title = "� �������� �� �����������",
                    onclick = function() sampSendChat("�������� ����� ������ 2000$. ���������?") end
                },
                {
                    title = "� �������� �� ������",
                    onclick = function() sampSendChat("�������� ����� ������ 100000$. ���������?") end
                }
            }
        }
    }
end

function pkmmenuPD(id)
	return
	{
		{
			title = '{ffffff}� ������ ���������',
			onclick = function()
				if sampIsPlayerConnected(id) then
					thread = lua_thread.create(function()
                        for line in cfg.otigrov.cuff:gmatch('[^\r\n]+') do
    
                            if line:match("^{wait%:%d+}$") then
                                wait(line:match("^%{wait%:(%d+)}$"))
                            elseif line:match("^{screen}$") then
                                screen()
                            else
                                local keys = {
                                    ["{myid}"] = select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)),
                                    ["{kv}"] = kvadrat(),
                                    ["{targetid}"] = targetid,
                                    ["{targetrpnick}"] = sampGetPlayerNicknameForBinder(targetid):gsub('_', ' '),
                                    ["{naparnik}"] = naparnik(),
                                    ["{myrpnick}"] = sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))):gsub("_", " "),
                                    ["{rang}"] = rang,
                                    ["{frak}"] = frak,
                                    ["{megafid}"] = gmegafid,
                                    ["{dl}"] = mcid,
                                    ["{playerid}"] = id
                                }
                                for k1, v1 in pairs(keys) do
                                    line = line:gsub(k1, v1)
                                end
    
                                sampSendChat(line)
                            end
    
                        end
                    end)
				end
			end
		},
		{
			title = "{ffffff}� ����� �� �����",
			onclick = function()
				if sampIsPlayerConnected(id) then
					thread = lua_thread.create(function()
                        for line in cfg.otigrov.follow:gmatch('[^\r\n]+') do
    
                            if line:match("^{wait%:%d+}$") then
                                wait(line:match("^%{wait%:(%d+)}$"))
                            elseif line:match("^{screen}$") then
                                screen()
                            else
                                local keys = {
                                    ["{myid}"] = select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)),
                                    ["{kv}"] = kvadrat(),
                                    ["{targetid}"] = targetid,
                                    ["{targetrpnick}"] = sampGetPlayerNicknameForBinder(targetid):gsub('_', ' '),
                                    ["{naparnik}"] = naparnik(),
                                    ["{myrpnick}"] = sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))):gsub("_", " "),
                                    ["{rang}"] = rang,
                                    ["{frak}"] = frak,
                                    ["{megafid}"] = gmegafid,
                                    ["{dl}"] = mcid,
                                    ["{playerid}"] = id
                                }
                                for k1, v1 in pairs(keys) do
                                    line = line:gsub(k1, v1)
                                end
    
                                sampSendChat(line)
                            end
    
                        end
                    end)
				end
			end
		},
		{
			title = "{ffffff}� ���������� �����",
			onclick = function()
				if sampIsPlayerConnected(id) then
					thread = lua_thread.create(function()
                        for line in cfg.otigrov.take:gmatch('[^\r\n]+') do
    
                            if line:match("^{wait%:%d+}$") then
                                wait(line:match("^%{wait%:(%d+)}$"))
                            elseif line:match("^{screen}$") then
                                screen()
                            else
                                local keys = {
                                    ["{myid}"] = select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)),
                                    ["{kv}"] = kvadrat(),
                                    ["{targetid}"] = targetid,
                                    ["{targetrpnick}"] = sampGetPlayerNicknameForBinder(targetid):gsub('_', ' '),
                                    ["{naparnik}"] = naparnik(),
                                    ["{myrpnick}"] = sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))):gsub("_", " "),
                                    ["{rang}"] = rang,
                                    ["{frak}"] = frak,
                                    ["{megafid}"] = gmegafid,
                                    ["{dl}"] = mcid,
                                    ["{playerid}"] = id
                                }
                                for k1, v1 in pairs(keys) do
                                    line = line:gsub(k1, v1)
                                end
    
                                sampSendChat(line)
                            end
    
                        end
                    end)
				end
			end
		},
		{
			title = "{ffffff}� ���������� �����",
			onclick = function()
				if sampIsPlayerConnected(id) then
                    thread = lua_thread.create(function()
                        for line in cfg.otigrov.arrest:gmatch('[^\r\n]+') do
    
                            if line:match("^{wait%:%d+}$") then
                                wait(line:match("^%{wait%:(%d+)}$"))
                            elseif line:match("^{screen}$") then
                                screen()
                            else
                                local keys = {
                                    ["{myid}"] = select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)),
                                    ["{kv}"] = kvadrat(),
                                    ["{targetid}"] = targetid,
                                    ["{targetrpnick}"] = sampGetPlayerNicknameForBinder(targetid):gsub('_', ' '),
                                    ["{naparnik}"] = naparnik(),
                                    ["{myrpnick}"] = sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))):gsub("_", " "),
                                    ["{rang}"] = rang,
                                    ["{frak}"] = frak,
                                    ["{megafid}"] = gmegafid,
                                    ["{dl}"] = mcid,
                                    ["{playerid}"] = id
                                }
                                for k1, v1 in pairs(keys) do
                                    line = line:gsub(k1, v1)
                                end
    
                                sampSendChat(line)
                            end

                        end
                    end)
				end
			end
		},
		{
			title = '{ffffff}� ����� ���������',
			onclick = function()
				if sampIsPlayerConnected(id) then
					sampSendChat(('/me %s ��������� � %s'):format(cfg.main.male and '����' or '�����', sampGetPlayerNickname(id):gsub("_", " ")))
					wait(1400)
					sampSendChat(('/uncuff %s'):format(id))
				end
			end
        },
        {
            title = "{ffffff}� ����� �����",
            onclick = function()
                if sampIsPlayerConnected(id) then
                    sampSendChat(("/offmask %s"):format(id))
                end
            end
        },
		{
			title = "{ffffff}� ������ ������ �� �������������",
			onclick = function()
				if sampIsPlayerConnected(id) then
					sampSendChat(("/su %s 2 ������������� �� ���. ����������"):format(id))
				end
			end
		},
		{
			title = "{ffffff}� ������ ������ �� �������� ����������",
			onclick = function()
				if sampIsPlayerConnected(id) then
					sampSendChat(("/su %s 3 �������� ����������"):format(id))
				end
			end
		},
		{
			title = "{ffffff}� ������ ������ �� �������� ����������",
			onclick = function()
				if sampIsPlayerConnected(id) then
					sampSendChat(("/su %s 3 �������� ����������"):format(id))
				end
			end
		},
		{
			title = "{ffffff}� ������ ������ �� ������� ����������",
			onclick = function()
				if sampIsPlayerConnected(id) then
					sampSendChat(('/su %s 2 ������� ����������'):format(id))
					wait(1400)
					sampSendChat(("/me %s ���� %s � %s ���������"):format(cfg.main.male and '�������' or '��������', sampGetPlayerNickname(id):gsub("_", " "), cfg.main.male and '������' or '�������'))
				end
			end
		},
		{
			title = "{ffffff}� ������ ������ �� ������� ������ �� ������",
			onclick = function()
				if sampIsPlayerConnected(id) then
					sampSendChat(("/su %s 6 ������� ������ �� ������"):format(id))
				end
			end
		},
		{
			title = "{ffffff}� ������ ������ �� ����������� ��������� �� ��",
			onclick = function()
				if sampIsPlayerConnected(id) then
					sampSendChat(("/su %s 6 ����������� ��������� �� ��"):format(id))
				end
			end
		},
		{
			title = "{ffffff}� ������ ������",
			onclick = function()
				if sampIsPlayerConnected(id) then
					submenus_show(sumenu(id), ('{9966cc}'..script.this.name..' {ffffff}| %s [%s]'):format(sampGetPlayerNickname(id):gsub("_", " "), id))
				end
			end
		}
	}
end

function apply_custom_style()
	imgui.SwitchContext()
	local style = imgui.GetStyle()
	local colors = style.Colors
	local clr = imgui.Col
	local ImVec4 = imgui.ImVec4

	style.WindowRounding = 2.0
	style.WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
	style.ChildWindowRounding = 2.0
	style.FrameRounding = 2.0
	style.ItemSpacing = imgui.ImVec2(5.0, 4.0)
	style.ScrollbarSize = 13.0
	style.ScrollbarRounding = 0
	style.GrabMinSize = 8.0
	style.GrabRounding = 1.0

	colors[clr.Text]                   = ImVec4(1.00, 1.00, 1.00, 1.00)
	colors[clr.TextDisabled]           = ImVec4(0.50, 0.50, 0.50, 1.00)
	colors[clr.WindowBg]               = ImVec4(0.06, 0.06, 0.06, 0.94)
	colors[clr.ChildWindowBg]          = ImVec4(1.00, 1.00, 1.00, 0.00)
	colors[clr.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 0.94)
	colors[clr.ComboBg]                = colors[clr.PopupBg]
	colors[clr.Border]                 = ImVec4(0.43, 0.43, 0.50, 0.50)
	colors[clr.BorderShadow]           = ImVec4(0.00, 0.00, 0.00, 0.00)
	colors[clr.FrameBg]                = ImVec4(0.16, 0.29, 0.48, 0.54)
	colors[clr.FrameBgHovered]         = ImVec4(0.26, 0.59, 0.98, 0.40)
	colors[clr.FrameBgActive]          = ImVec4(0.26, 0.59, 0.98, 0.67)
	colors[clr.TitleBg]                = ImVec4(0.04, 0.04, 0.04, 1.00)
	colors[clr.TitleBgActive]          = ImVec4(0.16, 0.29, 0.48, 1.00)
	colors[clr.TitleBgCollapsed]       = ImVec4(0.00, 0.00, 0.00, 0.51)
	colors[clr.MenuBarBg]              = ImVec4(0.14, 0.14, 0.14, 1.00)
	colors[clr.ScrollbarBg]            = ImVec4(0.02, 0.02, 0.02, 0.53)
	colors[clr.ScrollbarGrab]          = ImVec4(0.31, 0.31, 0.31, 1.00)
	colors[clr.ScrollbarGrabHovered]   = ImVec4(0.41, 0.41, 0.41, 1.00)
	colors[clr.ScrollbarGrabActive]    = ImVec4(0.51, 0.51, 0.51, 1.00)
	colors[clr.CheckMark]              = ImVec4(0.26, 0.59, 0.98, 1.00)
	colors[clr.SliderGrab]             = ImVec4(0.24, 0.52, 0.88, 1.00)
	colors[clr.SliderGrabActive]       = ImVec4(0.26, 0.59, 0.98, 1.00)
	colors[clr.Button]                 = ImVec4(0.26, 0.59, 0.98, 0.40)
	colors[clr.ButtonHovered]          = ImVec4(0.26, 0.59, 0.98, 1.00)
	colors[clr.ButtonActive]           = ImVec4(0.06, 0.53, 0.98, 1.00)
	colors[clr.Header]                 = ImVec4(0.26, 0.59, 0.98, 0.31)
	colors[clr.HeaderHovered]          = ImVec4(0.26, 0.59, 0.98, 0.80)
	colors[clr.HeaderActive]           = ImVec4(0.26, 0.59, 0.98, 1.00)
	colors[clr.Separator]              = colors[clr.Border]
	colors[clr.SeparatorHovered]       = ImVec4(0.26, 0.59, 0.98, 0.78)
	colors[clr.SeparatorActive]        = ImVec4(0.26, 0.59, 0.98, 1.00)
	colors[clr.ResizeGrip]             = ImVec4(0.26, 0.59, 0.98, 0.25)
	colors[clr.ResizeGripHovered]      = ImVec4(0.26, 0.59, 0.98, 0.67)
	colors[clr.ResizeGripActive]       = ImVec4(0.26, 0.59, 0.98, 0.95)
	colors[clr.CloseButton]            = ImVec4(0.41, 0.41, 0.41, 0.50)
	colors[clr.CloseButtonHovered]     = ImVec4(0.98, 0.39, 0.36, 1.00)
	colors[clr.CloseButtonActive]      = ImVec4(0.98, 0.39, 0.36, 1.00)
	colors[clr.PlotLines]              = ImVec4(0.61, 0.61, 0.61, 1.00)
	colors[clr.PlotLinesHovered]       = ImVec4(1.00, 0.43, 0.35, 1.00)
	colors[clr.PlotHistogram]          = ImVec4(0.90, 0.70, 0.00, 1.00)
	colors[clr.PlotHistogramHovered]   = ImVec4(1.00, 0.60, 0.00, 1.00)
	colors[clr.TextSelectedBg]         = ImVec4(0.26, 0.59, 0.98, 0.35)
	colors[clr.ModalWindowDarkening]   = ImVec4(0.80, 0.80, 0.80, 0.35)
end

function onScriptTerminate(scr)
    if scr == script.this then
		showCursor(false)
	end
end

if limgui then
    function imgui.TextQuestion(text)
        imgui.TextDisabled('(?)')
        if imgui.IsItemHovered() then
            imgui.BeginTooltip()
            imgui.PushTextWrapPos(450)
            imgui.TextUnformatted(text)
            imgui.PopTextWrapPos()
            imgui.EndTooltip()
        end
    end
    function imgui.CentrText(text)
        local width = imgui.GetWindowWidth()
        local calc = imgui.CalcTextSize(text)
        imgui.SetCursorPosX( width / 2 - calc.x / 2 )
        imgui.Text(text)
    end
    function imgui.CustomButton(name, color, colorHovered, colorActive, size)
        local clr = imgui.Col
        imgui.PushStyleColor(clr.Button, color)
        imgui.PushStyleColor(clr.ButtonHovered, colorHovered)
        imgui.PushStyleColor(clr.ButtonActive, colorActive)
        if not size then size = imgui.ImVec2(0, 0) end
        local result = imgui.Button(name, size)
        imgui.PopStyleColor(3)
        return result
    end
    function imgui.OnDrawFrame()
        if infbar.v then
            imgui.ShowCursor = false
            _, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
            local myname = sampGetPlayerNickname(myid)
            local myping = sampGetPlayerPing(myid)
            local myweapon = getCurrentCharWeapon(PLAYER_PED)
            local myweaponammo = getAmmoInCharWeapon(PLAYER_PED, myweapon)
            local valid, ped = getCharPlayerIsTargeting(PLAYER_HANDLE)
            local myweaponname = getweaponname(myweapon)


            imgui.SetNextWindowPos(imgui.ImVec2(cfg.main.posX, cfg.main.posY), imgui.ImVec2(0.5, 0.5))
            imgui.SetNextWindowSize(imgui.ImVec2(cfg.main.widehud, 160), imgui.Cond.FirstUseEver)

            imgui.PushStyleColor(imgui.Col.WindowBg, imgui.ImVec4(0.06, 0.05, 0.06, cfg.main.hudopacity))
            imgui.PushStyleVar(imgui.StyleVar.WindowRounding, cfg.main.hudrounding)

            imgui.Begin(script.this.name, infbar, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoTitleBar)

            imgui.SetWindowSize(script.this.name, imgui.ImVec2(cfg.main.widehud, 0))

            if cfg.main.hudshowtitle then
                imgui.CentrText(script.this.name)
                imgui.Separator()
            end

            if cfg.showhud[1] then imgui.Text((u8"����������:"):format(myname, myid, myping)) 
            imgui.SameLine()
            imgui.TextColored(imgui.ImVec4(getColor(myid)), u8('%s [%s]'):format(myname, myid))
            imgui.SameLine()
            imgui.Text((u8"| ����: %s"):format(myping)) end
            if cfg.showhud[2] then if getAmmoInClip() ~= 0 then
                imgui.Text((u8 "������: %s [%s/%s]"):format(myweaponname, getAmmoInClip(), myweaponammo - getAmmoInClip()))
            else
                imgui.Text((u8 '������: %s'):format(myweaponname))
            end end
            if cfg.showhud[3] then if isCharInAnyCar(playerPed) then
                local vHandle = storeCarCharIsInNoSave(playerPed)
                local result, vID = sampGetVehicleIdByCarHandle(vHandle)
                local vHP = getCarHealth(vHandle)
                local carspeed = getCarSpeed(vHandle)
                local speed = math.floor(carspeed)
                local vehName = tCarsName[getCarModel(storeCarCharIsInNoSave(playerPed))-399]
                local ncspeed = math.floor(carspeed*2)
                imgui.Text((u8 '���������: %s [%s] | HP: %s | ��������: %s'):format(vehName, vID, vHP, ncspeed))
            else
                imgui.Text(u8 '���������: ���')
            end end
            if cfg.showhud[4] then if valid and doesCharExist(ped) then 
                local result, id = sampGetPlayerIdByCharHandle(ped)
                if result then
                    local targetname = sampGetPlayerNickname(id)
                    local targetscore = sampGetPlayerScore(id)
                    imgui.Text((u8 '����: %s [%s] | �������: %s'):format(targetname, id, targetscore))
                else
                    imgui.Text(u8 '����: ���')
                end
            else
                imgui.Text(u8 '����: ���')
            end end
            local cx, cy, cz = getCharCoordinates(PLAYER_PED)
            local zcode = getNameOfZone(cx, cy, cz)
            if cfg.showhud[5] then imgui.Text((u8 '�������: %s | %s'):format(u8(getZones(zcode)), u8(kvadrat()))) end
            if cfg.showhud[6] then imgui.Text((u8 '�����: %s'):format(os.date('%H:%M:%S'))) end
            --if cfg.showhud[7] then if cfg.main.group == "��/���" or cfg.main.group == "�����" then imgui.Text((u8 '�����: %s'):format(stazer and u8'�������' or u8'��������')) end end
            if imgui.IsMouseClicked(0) and changetextpos then
                changetextpos = false
                sampToggleCursor(false)
                mainw.v = true
                saveData(cfg, 'moonloader/config/fbitools/config.json')
            end

            imgui.End()

            imgui.PopStyleVar()
            imgui.PopStyleColor()
        end
        if imegaf.v then
            imgui.ShowCursor = true
            local x, y = getScreenResolution()
            local btn_size = imgui.ImVec2(-0.1, 0)
            imgui.SetNextWindowSize(imgui.ImVec2(300, 300), imgui.Cond.FirstUseEver)
            imgui.SetNextWindowPos(imgui.ImVec2(x/2+300, y/2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
            imgui.Begin(u8(script.this.name..' | �������'), imegaf, imgui.WindowFlags.NoResize)
            for k, v in ipairs(incar) do
                local mx, my, mz = getCharCoordinates(PLAYER_PED)
                if sampIsPlayerConnected(v) then
                    local result, ped = sampGetCharHandleBySampPlayerId(v)
                    if result then
                        local px, py, pz = getCharCoordinates(ped)
                        local dist = math.floor(getDistanceBetweenCoords3d(mx, my, mz, px, py, pz))
                        if isCharInAnyCar(ped) then
                            local carh = storeCarCharIsInNoSave(ped)
                            local carhm = getCarModel(carh)
                            if imgui.Button(("%s [EVL%sX] | Distance: %s m.##%s"):format(tCarsName[carhm-399], v, dist, k), btn_size) then
                                thread = lua_thread.create(function()
                                    imegaf.v = false
                                    gmegafid = v
                                    gmegaflvl = sampGetPlayerScore(v)
                                    gmegaffrak = sampGetFraktionBySkin(v)
                                    gmegafcar = tCarsName[carhm-399]
                                    sampSendChat(("/m �������� �/� %s [EVL%sX]"):format(tCarsName[carhm-399], v))
                                    wait(1400)
                                    sampSendChat("/m ���������� � ������� ��� �� ������� �����!")
                                    wait(300)
                                    sampAddChatMessage(' {ffffff}~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~', 0x9966cc)
                                    sampAddChatMessage('', 0x9966cc)
                                    sampAddChatMessage(' {ffffff}���: {9966cc}'..sampGetPlayerNickname(v)..' ['..v..']', 0x9966cc)
                                    sampAddChatMessage(' {ffffff}�������: {9966cc}'..sampGetPlayerScore(v), 0x9966cc)
                                    sampAddChatMessage(' {ffffff}�������: {9966cc}'..sampGetFraktionBySkin(v), 0x9966cc)
                                    sampAddChatMessage('', 0x9966cc)
                                    sampAddChatMessage(' {ffffff}~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~', 0x9966cc)
                                end)
                            end
                        end
                    end
                end
            end
            imgui.End()
        end
        if updwindows.v then
            local updlist = ttt
            imgui.ShowCursor = true
            local iScreenWidth, iScreenHeight = getScreenResolution()
            imgui.SetNextWindowPos(imgui.ImVec2(iScreenWidth / 2, iScreenHeight / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
            imgui.SetNextWindowSize(imgui.ImVec2(700, 290), imgui.Cond.FirstUseEver)
            imgui.Begin(u8(script.this.name..' | ����������'), updwindows, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize)
            imgui.Text(u8('����� ���������� ������� '..script.this.name..'! ��� �� ���������� ������� ������ �����. ������ ���������:'))
            imgui.Separator()
            imgui.BeginChild("uuupdate", imgui.ImVec2(690, 200))
            for line in ttt:gmatch('[^\r\n]+') do
                imgui.TextWrapped(line)
            end
            imgui.EndChild()
            imgui.Separator()
            imgui.PushItemWidth(305)
            if imgui.Button(u8("��������"), imgui.ImVec2(339, 25)) then
                lua_thread.create(goupdate)
                updwindows.v = false
            end
            imgui.SameLine()
            if imgui.Button(u8("�������� ����������"), imgui.ImVec2(339, 25)) then
                updwindows.v = false
                ftext("���� �� �������� ���������� ���������� ������� ������� {9966CC}/ft")
            end
            imgui.End()
        end
        if mainw.v then
            imgui.ShowCursor = true
            local x, y = getScreenResolution()
            local btn_size = imgui.ImVec2(-0.1, 0)
            imgui.SetNextWindowSize(imgui.ImVec2(300, 300), imgui.Cond.FirstUseEver)
            imgui.SetNextWindowPos(imgui.ImVec2(x/2, y/2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
            imgui.Begin(u8(script.this.name..' | ������� ���� | ������: '..thisScript().version), mainw, imgui.WindowFlags.NoResize)
            if imgui.Button(u8'������', btn_size) then
                bMainWindow.v = not bMainWindow.v
            end
            if imgui.Button(u8'��������� ������', btn_size) then
                vars.mainwindow.v = not vars.mainwindow.v
            end
            if imgui.Button(u8 '������� �������', btn_size) then cmdwind.v = not cmdwind.v end
            if imgui.Button(u8 '��������� �������', btn_size) then setwindows.v = not setwindows.v end
            if imgui.Button(u8 '�������� ������', btn_size) then editpost.v = not editpost.v end
            if imgui.Button(u8 '�������� � ������ / ����', btn_size) then os.execute('explorer "https://vk.me/fbitools"') end
            if canupdate then if imgui.Button(u8 '[!] �������� ���������� ������� [!]', btn_size) then updwindows.v = not updwindows.v end end
            if imgui.CollapsingHeader(u8 '�������� �� ��������', btn_size) then
                if imgui.Button(u8'������������� ������', btn_size) then
                    thisScript():reload()
                end
                if imgui.Button(u8 '��������� ������', btn_size) then
                    thisScript():unload()
                end
            end
            if trash.ftoosid then imgui.Text(u8("��� ���������� ��: "..trash.ftoosid)) end
            imgui.End()

            if editpost.v then
                imgui.SetNextWindowSize(imgui.ImVec2(600, 500), imgui.Cond.FirstUseEver)
                imgui.SetNextWindowPos(imgui.ImVec2(x/2, y/2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))

                imgui.Begin(u8 '�������� ������', editpost)
                
                if imgui.CollapsingHeader(u8 "������") then 
                    if imgui.Button(u8 "�������� ����##onfoot") then
                        local myx, myy, myz = getCharCoordinates(PLAYER_PED)

                        postname.v = ""
                        postcoords.v[1] = myx
                        postcoords.v[2] = myy
                        postcoords.v[3] = myz

                        imgui.OpenPopup(u8 "�������� ����##onfoot")
                    end

                    if imgui.BeginPopupModal(u8 "�������� ����##onfoot", _, imgui.WindowFlags.NoResize) then
                        imgui.Text(u8 "��� �����:")
                        imgui.InputText("##��� �����", postname)

                        imgui.Spacing()

                        imgui.PushItemWidth(200)
                        imgui.InputFloat3("##������ �����", postcoords)
                        imgui.PopItemWidth()
                        imgui.SameLine()
                        if imgui.Button(u8 "������� ����������") then
                            local myx, myy, myz = getCharCoordinates(PLAYER_PED)
                            postcoords.v[1] = myx
                            postcoords.v[2] = myy
                            postcoords.v[3] = myz
                        end

                        if imgui.Button(u8 "���������##onfoot", imgui.ImVec2(90, 20)) then
                            table.insert(posts.onFoot, {postcoords.v[1], postcoords.v[2], postcoords.v[3], u8:decode(postname.v)})
                            saveData(posts, "moonloader/config/fbitools/post.json")
                            imgui.CloseCurrentPopup()
                        end
                        imgui.SameLine()
                        if imgui.Button(u8 "�������##onfoot", imgui.ImVec2(90, 20)) then imgui.CloseCurrentPopup() end
                        imgui.EndPopup()
                    end
                    imgui.Columns(5, _)
                    imgui.SetColumnWidth(-1, 140) imgui.Text(u8 '��������'); imgui.NextColumn()
                    imgui.SetColumnWidth(-1, 120) imgui.Text(u8 'X ����������');  imgui.NextColumn()
                    imgui.SetColumnWidth(-1, 120) imgui.Text(u8 'Y ����������') imgui.NextColumn()
                    imgui.SetColumnWidth(-1, 120) imgui.Text(u8 'Z ����������') imgui.NextColumn() 
                    imgui.SetColumnWidth(-1, 80) imgui.NextColumn() 
                    imgui.Separator()
                    for k, v in pairs(posts.onFoot) do
                        --[[if imgui.Selectable(u8(("%s | %s | %s | %s##onfoot%s"):format(v[4], v[1], v[2], v[3], k))) then 
                            postname.v = u8(v[4])
                            postcoords.v[1] = v[1]
                            postcoords.v[2] = v[2]
                            postcoords.v[3] = v[3]
                            imgui.OpenPopup(u8 "�������������� �����##onfoot"..k) 
                        end]]
                        imgui.Text(u8(v[4])) imgui.NextColumn()
                        imgui.Text(tostring(v[1])) imgui.NextColumn()
                        imgui.Text(tostring(v[2])) imgui.NextColumn()
                        imgui.Text(tostring(v[3])) imgui.NextColumn()
                        if imgui.Button(u8 "��������##onfoot"..k) then
                            postname.v = u8(v[4])
                            postcoords.v[1] = v[1]
                            postcoords.v[2] = v[2]
                            postcoords.v[3] = v[3]
                            imgui.OpenPopup(u8 "�������������� �����##onfoot"..k) 
                        end imgui.NextColumn()
                        if imgui.BeginPopupModal(u8 "�������������� �����##onfoot"..k, _, imgui.WindowFlags.NoResize) then
                            imgui.Text(u8 "��� �����:")
                            imgui.InputText(u8 "##��� �����", postname)

                            imgui.Spacing()

                            imgui.Text(u8 "���������� �����:")
                            imgui.PushItemWidth(200)
                            imgui.InputFloat3(u8 "##���������� �����", postcoords)
                            imgui.PopItemWidth()
                            imgui.SameLine()
                            if imgui.Button(u8 "������� ����������") then
                                local myx, myy, myz = getCharCoordinates(PLAYER_PED)
                                postcoords.v[1] = myx
                                postcoords.v[2] = myy
                                postcoords.v[3] = myz
                            end

                            imgui.Spacing()

                            if imgui.Button(u8 "���������##onFoot"..k, imgui.ImVec2(120, 20)) then
                                posts.onFoot[k] = {postcoords.v[1], postcoords.v[2], postcoords.v[3], u8:decode(postname.v)}
                                saveData(posts, "moonloader/config/fbitools/post.json")
                                imgui.CloseCurrentPopup()
                            end
                            imgui.SameLine()
                            if imgui.Button(u8 "������� ����##onFoot"..k, imgui.ImVec2(120, 20)) then 
                                table.remove(posts.onFoot, k)
                                saveData(posts, "moonloader/config/fbitools/post.json")
                                imgui.CloseCurrentPopup() 
                            end
                            imgui.SameLine()
                            if imgui.Button(u8 "�������##onFoot"..k, imgui.ImVec2(120, 20)) then imgui.CloseCurrentPopup() end
                            imgui.EndPopup()
                        end
                    end
                end
                imgui.Columns(1)
                if imgui.CollapsingHeader(u8 "�� ����") then
                    if imgui.Button(u8 "�������� ����##incar") then
                        local myx, myy, myz = getCharCoordinates(PLAYER_PED)

                        postname.v = ""
                        postcoords.v[1] = myx
                        postcoords.v[2] = myy
                        postcoords.v[3] = myz

                        imgui.OpenPopup(u8 "�������� ����##incar")
                    end

                    if imgui.BeginPopupModal(u8 "�������� ����##incar", _, imgui.WindowFlags.NoResize) then
                        imgui.Text(u8 "��� �����:")
                        imgui.InputText("##��� �����", postname)

                        imgui.Spacing()

                        imgui.PushItemWidth(200)
                        imgui.InputFloat3("##������ �����", postcoords)
                        imgui.PopItemWidth()
                        imgui.SameLine()
                        if imgui.Button(u8 "������� ����������") then
                            local myx, myy, myz = getCharCoordinates(PLAYER_PED)
                            postcoords.v[1] = myx
                            postcoords.v[2] = myy
                            postcoords.v[3] = myz
                        end

                        if imgui.Button(u8 "���������##incar", imgui.ImVec2(90, 20)) then
                            table.insert(posts.inCar.posts, {postcoords.v[1], postcoords.v[2], postcoords.v[3], u8:decode(postname.v)})
                            saveData(posts, "moonloader/config/fbitools/post.json")
                            imgui.CloseCurrentPopup()
                        end
                        imgui.SameLine()
                        if imgui.Button(u8 "�������##inCar", imgui.ImVec2(90, 20)) then imgui.CloseCurrentPopup() end
                        imgui.EndPopup()
                    end

                    imgui.Columns(5, _)
                    imgui.SetColumnWidth(-1, 140) imgui.Text(u8 '��������'); imgui.NextColumn()
                    imgui.SetColumnWidth(-1, 120) imgui.Text(u8 'X ����������');  imgui.NextColumn()
                    imgui.SetColumnWidth(-1, 120) imgui.Text(u8 'Y ����������') imgui.NextColumn()
                    imgui.SetColumnWidth(-1, 120) imgui.Text(u8 'Z ����������') imgui.NextColumn() 
                    imgui.SetColumnWidth(-1, 80) imgui.NextColumn() 
                    imgui.Separator()

                    for k, v in pairs(posts.inCar.posts) do
                        imgui.Text(u8(v[4])) imgui.NextColumn()
                        imgui.Text(tostring(v[1])) imgui.NextColumn()
                        imgui.Text(tostring(v[2])) imgui.NextColumn()
                        imgui.Text(tostring(v[3])) imgui.NextColumn()
                        if imgui.Button(u8 "��������##incar"..k) then
                            postname.v = u8(v[4])
                            postcoords.v[1] = v[1]
                            postcoords.v[2] = v[2]
                            postcoords.v[3] = v[3]
                            imgui.OpenPopup(u8 "�������������� �����##onfoot"..k) 
                        end imgui.NextColumn()
                        if imgui.BeginPopupModal(u8 "�������������� �����##inCar"..k, _, imgui.WindowFlags.NoResize) then
                            imgui.Text(u8 "��� �����:")
                            imgui.InputText(u8 "##��� �����", postname)

                            imgui.Spacing()

                            imgui.Text(u8 "���������� �����:")
                            imgui.PushItemWidth(200)
                            imgui.InputFloat3(u8 "##���������� �����", postcoords)
                            imgui.PopItemWidth()
                            imgui.SameLine()
                            if imgui.Button(u8 "������� ����������") then
                                local myx, myy, myz = getCharCoordinates(PLAYER_PED)
                                postcoords.v[1] = myx
                                postcoords.v[2] = myy
                                postcoords.v[3] = myz
                            end

                            imgui.Spacing()

                            if imgui.Button(u8 "���������##inCar"..k, imgui.ImVec2(120, 20)) then
                                posts.inCar.posts[k] = {postcoords.v[1], postcoords.v[2], postcoords.v[3], u8:decode(postname.v)}
                                saveData(posts, "moonloader/config/fbitools/post.json")
                                imgui.CloseCurrentPopup()
                            end
                            imgui.SameLine()
                            if imgui.Button(u8 "������� ����##inCar"..k, imgui.ImVec2(120, 20)) then 
                                table.remove(posts.inCar.posts, k)
                                saveData(posts, "moonloader/config/fbitools/post.json")
                                imgui.CloseCurrentPopup() 
                            end
                            imgui.SameLine()
                            if imgui.Button(u8 "�������##inCar"..k, imgui.ImVec2(120, 20)) then imgui.CloseCurrentPopup() end
                            imgui.EndPopup()
                        end
                    end
                end

                imgui.End()
            end

            if cmdwind.v then
                local x, y = getScreenResolution()
                imgui.SetNextWindowSize(imgui.ImVec2(500, 500), imgui.Cond.FirstUseEver)
                imgui.SetNextWindowPos(imgui.ImVec2(x/2, y/2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
                imgui.Begin(u8(script.this.name..' | �������'), cmdwind)
                for k, v in ipairs(fthelp) do
                    if imgui.CollapsingHeader(v['cmd']..'##'..k) then
                        imgui.TextWrapped(u8('��������: %s'):format(u8(v['desc'])))
                        imgui.TextWrapped(u8("�������������: %s"):format(u8(v['use'])))
                    end
                end
                imgui.End()
            end

            if vars.mainwindow.v then
                local sX, sY = getScreenResolution()
                imgui.SetNextWindowPos(imgui.ImVec2(sX/2, sY/2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
                imgui.SetNextWindowSize(imgui.ImVec2(891, 380), imgui.Cond.FirstUseEver)
                imgui.Begin(u8(script.this.name.." | ������ ������"), vars.mainwindow, imgui.WindowFlags.NoResize)
                imgui.BeginChild("##commandlist", imgui.ImVec2(170 ,320), true)
                for k, v in pairs(commands) do
                    if imgui.Selectable(u8(("%s. /%s##%s"):format(k, v.cmd, k)), vars.menuselect == k) then 
                        vars.menuselect     = k 
                        vars.cmdbuf.v       = u8(v.cmd) 
                        vars.cmdparams.v    = v.params
                        vars.cmdtext.v      = u8(v.text)
                    end
                end
                imgui.EndChild()
                imgui.SameLine()
                imgui.BeginChild("##commandsetting", imgui.ImVec2(700, 320), true)
                for k, v in pairs(commands) do
                    if vars.menuselect == k then
                        imgui.InputText(u8 "������� ���� �������", vars.cmdbuf)
                        imgui.InputInt(u8 "������� ���-�� ���������� �������", vars.cmdparams, 0)
                        imgui.InputTextMultiline(u8 "##cmdtext", vars.cmdtext, imgui.ImVec2(678, 200))
                        imgui.TextWrapped(u8 "����� ����������: {param:1}, {param:2} � �.� (������������ � ������ �� ����� ���������)\n���� ��������: {wait:���-�� �����������} (������������ �� ����� ������)")
                        if imgui.Button(u8 "��������� �������") then
                            sampUnregisterChatCommand(v.cmd)
                            v.cmd = u8:decode(vars.cmdbuf.v)
                            v.params = vars.cmdparams.v
                            v.text = u8:decode(vars.cmdtext.v)
                            saveData(commands, "moonloader/config/fbitools/cmdbinder.json")
                            registerCommandsBinder()
                            notf.addNotification("������� ���������", 4, 2)
                        end
                        imgui.SameLine()
                        if imgui.Button(u8 "������� �������") then
                            imgui.OpenPopup(u8 "�������� �������##"..k)
                        end
                        if imgui.BeginPopupModal(u8 "�������� �������##"..k, _, imgui.WindowFlags.AlwaysAutoResize) then
                            imgui.SetCursorPosX(imgui.GetWindowWidth()/2 - imgui.CalcTextSize(u8 "�� ������������� ������ ������� �������?").x / 2)
                            imgui.Text(u8 "�� ������������� ������ ������� �������?")
                            if imgui.Button(u8 "�������##"..k, imgui.ImVec2(170, 20)) then
                                sampUnregisterChatCommand(v.cmd)
                                vars.menuselect     = 0
                                vars.cmdbuf.v       = ""
                                vars.cmdparams.v    = 0
                                vars.cmdtext.v      = ""
                                table.remove(commands, k)
                                saveData(commands, "moonloader/config/fbitools/cmdbinder.json")
                                registerCommandsBinder()
                                notf.addNotification("������� �������", 4, 2)
                                imgui.CloseCurrentPopup()
                            end
                            imgui.SameLine()
                            if imgui.Button(u8 "������##"..k, imgui.ImVec2(170, 20)) then
                                imgui.CloseCurrentPopup()
                            end
                            imgui.EndPopup()
                        end
                        imgui.SameLine()
                        if imgui.Button(u8 '�����', imgui.ImVec2(170, 20)) then imgui.OpenPopup('##bindkey') end
                        if imgui.BeginPopup('##bindkey') then
                            imgui.Text(u8 '����������� ����� ������� ��� ����� �������� ������������� �������')
                            imgui.Text(u8 '������: /su {targetid} 6 ����������� ��������� �� ��')
                            imgui.Separator()
                            imgui.Text(u8 '{myid} - ID ������ ��������� | '..select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)))
                            imgui.Text(u8 '{myrpnick} - �� ��� ������ ��������� | '..sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))):gsub('_', ' '))
                            imgui.Text(u8 ('{naparnik} - ���� ��������� | '..naparnik()))
                            imgui.Text(u8 ('{kv} - ��� ������� ������� | '..kvadrat()))
                            imgui.Text(u8 '{targetid} - ID ������ �� �������� �� �������� | '..targetid)
                            imgui.Text(u8 '{targetrpnick} - �� ��� ������ �� �������� �� �������� | '..sampGetPlayerNicknameForBinder(targetid):gsub('_', ' '))
                            imgui.Text(u8 '{megafid} - ID ������, �� ������� ���� ������ ������ | '..gmegafid)
                            imgui.Text(u8 '{rang} - ���� ������ | '..u8(rang))
                            imgui.Text(u8 '{frak} - ���� ������� | '..u8(frak))
                            imgui.Text(u8 "{post} - ������� ���� | "..u8(getPost()))
                            imgui.Text(u8 '{wait:sek} - �������� ����� ��������, ��� sek - ���-�� �����������. ������: {wait:2000} - �������� 2 �������. (������������ �������� �� ����� �������)')
                            imgui.Text(u8 '{screen} - ������� �������� ������ (������������ �������� �� ����� �������)')
                            imgui.EndPopup()
                        end
                    end
                end
                imgui.EndChild()
                if imgui.Button(u8 "�������� �������", imgui.ImVec2(170, 20)) then
                    table.insert(commands, {cmd = "", params = 0, text = ""})
                    saveData(commands, "moonloader/config/fbitools/cmdbinder.json")
                end
                imgui.End()
            end

            if bMainWindow.v then
                imgui.ShowCursor = true
                local iScreenWidth, iScreenHeight = getScreenResolution()
                imgui.SetNextWindowPos(imgui.ImVec2(iScreenWidth / 2, iScreenHeight / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
                imgui.SetNextWindowSize(imgui.ImVec2(1000, 510), imgui.Cond.FirstUseEver)
                imgui.Begin(u8(script.this.name.." | ������##main"), bMainWindow, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize)
                imgui.BeginChild("##bindlist", imgui.ImVec2(995, 442))
                for k, v in ipairs(tBindList) do
                    if imadd.HotKey("##HK" .. k, v, tLastKeys, 100) then
                        if not rkeys.isHotKeyDefined(v.v) then
                            if rkeys.isHotKeyDefined(tLastKeys.v) then
                                rkeys.unRegisterHotKey(tLastKeys.v)
                            end
                            rkeys.registerHotKey(v.v, true, onHotKey)
                        end
                        saveData(tBindList, fileb)
                    end
                    imgui.SameLine()
                    imgui.CentrText(u8(v.name))
                    imgui.SameLine(850)
                    if imgui.Button(u8 '������������� ����##'..k) then imgui.OpenPopup(u8 "�������������� �������##editbind"..k) 
                        bindname.v = u8(v.name) 
                        bindtext.v = u8(v.text)
                    end
                    if imgui.BeginPopupModal(u8 '�������������� �������##editbind'..k, _, imgui.WindowFlags.NoResize) then
                        imgui.Text(u8 "������� �������� �������:")
                        imgui.InputText("##������� �������� �������", bindname)
                        imgui.Text(u8 "������� ����� �������:")
                        imgui.InputTextMultiline("##������� ����� �������", bindtext, imgui.ImVec2(500, 200))
                        imgui.Separator()
                        if imgui.Button(u8 '�����', imgui.ImVec2(90, 20)) then imgui.OpenPopup('##bindkey') end
                        if imgui.BeginPopup('##bindkey') then
                            imgui.Text(u8 '����������� ����� ������� ��� ����� �������� ������������� �������')
                            imgui.Text(u8 '������: /su {targetid} 6 ����������� ��������� �� ��')
                            imgui.Separator()
                            imgui.Text(u8 '{myid} - ID ������ ��������� | '..select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)))
                            imgui.Text(u8 '{myrpnick} - �� ��� ������ ��������� | '..sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))):gsub('_', ' '))
                            imgui.Text(u8 ('{naparnik} - ���� ��������� | '..naparnik()))
                            imgui.Text(u8 ('{kv} - ��� ������� ������� | '..kvadrat()))
                            imgui.Text(u8 '{targetid} - ID ������ �� �������� �� �������� | '..targetid)
                            imgui.Text(u8 '{targetrpnick} - �� ��� ������ �� �������� �� �������� | '..sampGetPlayerNicknameForBinder(targetid):gsub('_', ' '))
                            imgui.Text(u8 '{smsid} - ��������� ID ����, ��� ��� ������� � SMS | '..smsid)
                            imgui.Text(u8 '{smstoid} - ��������� ID ����, ���� �� �������� � SMS | '..smstoid)
                            imgui.Text(u8 '{megafid} - ID ������, �� ������� ���� ������ ������ | '..gmegafid)
                            imgui.Text(u8 '{rang} - ���� ������ | '..u8(rang))
                            imgui.Text(u8 '{frak} - ���� ������� | '..u8(frak))
                            imgui.Text(u8 '{dl} - ID ����, � ������� �� ������ | '..mcid)
                            imgui.Text(u8 "{post} - ������� ���� | "..u8(getPost()))
                            imgui.Text(u8 '{f6} - ��������� ��������� � ��� ����� �������� ���� (������������ � ����� ������)')
                            imgui.Text(u8 '{noe} - �������� ��������� � ����� ����� � �� ���������� ��� � ��� (������������ � ����� ������)')
                            imgui.Text(u8 '{wait:sek} - �������� ����� ��������, ��� sek - ���-�� �����������. ������: {wait:2000} - �������� 2 �������. (������������ �������� �� ����� �������)')
                            imgui.Text(u8 '{screen} - ������� �������� ������ (������������ �������� �� ����� �������)')
                            imgui.EndPopup()
                        end
                        imgui.SameLine()
                        imgui.SetCursorPosX((imgui.GetWindowWidth() - 90 - imgui.GetStyle().ItemSpacing.x))
                        if imgui.Button(u8 "������� ����##"..k, imgui.ImVec2(90, 20)) then
                            table.remove(tBindList, k)
                            saveData(tBindList, fileb)
                            imgui.CloseCurrentPopup()
                        end
                        imgui.SameLine()
                        imgui.SetCursorPosX((imgui.GetWindowWidth() - 180 + imgui.GetStyle().ItemSpacing.x) / 2)
                        if imgui.Button(u8 "���������##"..k, imgui.ImVec2(90, 20)) then
                            v.name = u8:decode(bindname.v)
                            v.text = u8:decode(bindtext.v)
                            bindname.v = ''
                            bindtext.v = ''
                            saveData(tBindList, fileb)
                            imgui.CloseCurrentPopup()
                        end
                        imgui.SameLine()
                        if imgui.Button(u8 "�������##"..k, imgui.ImVec2(90, 20)) then imgui.CloseCurrentPopup() end
                        imgui.EndPopup()
                    end
                end
                imgui.EndChild()
                imgui.Separator()
                if imgui.Button(u8"�������� �������") then
                    tBindList[#tBindList + 1] = {text = "", v = {}, time = 0, name = "����"..#tBindList + 1}
                    saveData(tBindList, fileb)
                end
                imgui.End()
            end

            if setwindows.v then
                --
                cput            = imgui.ImBool(cfg.commands.cput)
                ceject          = imgui.ImBool(cfg.commands.ceject)
                ftazer          = imgui.ImBool(cfg.commands.ftazer)
                deject          = imgui.ImBool(cfg.commands.deject)
                kmdcb           = imgui.ImBool(cfg.commands.kmdctime)
                carb            = imgui.ImBool(cfg.main.autocar)
                stateb          = imgui.ImBool(cfg.main.male)
                tagf            = imgui.ImBuffer(u8(cfg.main.tar), 256)
                parolf          = imgui.ImBuffer(u8(tostring(cfg.main.parol)), 256)
                tagb            = imgui.ImBool(cfg.main.tarb)
                xcord           = imgui.ImInt(cfg.main.posX)
                ycord           = imgui.ImInt(cfg.main.posY)
                clistbuffer     = imgui.ImInt(cfg.main.clist)
                waitbuffer      = imgui.ImInt(cfg.commands.zaderjka)
                clistb          = imgui.ImBool(cfg.main.clistb)
                parolb          = imgui.ImBool(cfg.main.parolb)
                offptrlb        = imgui.ImBool(cfg.main.offptrl)
                offwntdb        = imgui.ImBool(cfg.main.offwntd)
                ticketb         = imgui.ImBool(cfg.commands.ticket)
                tchatb          = imgui.ImBool(cfg.main.tchat)
                strobbsb        = imgui.ImBool(cfg.main.strobs)
                megafb          = imgui.ImBool(cfg.main.megaf)
                infbarb         = imgui.ImBool(cfg.main.hud)
                autobpb         = imgui.ImBool(cfg.main.autobp)
                googlecodeb     = imgui.ImBuffer(tostring(cfg.main.googlecode), 256)
                googlecodebb    = imgui.ImBool(cfg.main.googlecodeb)
                nwantedb        = imgui.ImBool(cfg.main.nwanted)
                nclearb         = imgui.ImBool(cfg.main.nclear)
                opacity         = imgui.ImFloat(cfg.main.hudopacity)
                rounding        = imgui.ImFloat(cfg.main.hudrounding)
                showtitle       = imgui.ImBool(cfg.main.hudshowtitle)
                rpgunsb         = imgui.ImBool(cfg.main.rpguns)
                widehud         = imgui.ImFloat(cfg.main.widehud)
                modrb           = imgui.ImBool(cfg.main.modr)
                modmb           = imgui.ImBool(cfg.main.modm)
                --
                local iScreenWidth, iScreenHeight = getScreenResolution()
                imgui.SetNextWindowPos(imgui.ImVec2(iScreenWidth / 2, iScreenHeight / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
                imgui.SetNextWindowSize(imgui.ImVec2(1161, 436), imgui.Cond.FirstUseEver)
                imgui.Begin(u8'���������##1', setwindows, imgui.WindowFlags.NoResize)
                if cfg.main.group ~= 'unknown' then
                    imgui.BeginChild('##set', imgui.ImVec2(140, 400), true)
                    if imgui.Selectable(u8'��������', show == 1) then show = 1 end
                    if cfg.main.group == '��/���' then if imgui.Selectable(u8'�������', show == 2) then show = 2 end end
                    if imgui.Selectable(u8'�������', show == 3) then show = 3 end
                    if cfg.main.group == '��/���' or cfg.main.group == "�����" then if imgui.Selectable(u8'����-��', show == 4) then show = 4 end end
                    if imgui.Selectable(u8 "�������", show == 5) then show = 5 end
                    if imgui.Selectable(u8 "�������� ���������", show == 6) then show = 6 end
                    imgui.EndChild()
                    imgui.SameLine()
                    imgui.BeginChild('##set1', imgui.ImVec2(1000, 400), true)
                    if show == 1 then
                        if cfg.main.group == '��/���' then
                            if imadd.ToggleButton(u8'�������� ��������� � ������ �������������', offptrlb) then cfg.main.offptrl = offptrlb.v saveData(cfg, 'moonloader/config/fbitools/config.json') end imgui.SameLine(); imgui.Text(u8 '�������� ��������� � ������ �������������')
                            if imadd.ToggleButton(u8'�������� ��������� � ������ �������', offwntdb) then cfg.main.offwntd = offwntdb.v saveData(cfg, 'moonloader/config/fbitools/config.json') end imgui.SameLine(); imgui.Text(u8 '�������� ��������� � ������ �������')
                            if imadd.ToggleButton(u8'����� wanted', nwantedb) then cfg.main.nwanted = nwantedb.v saveData(cfg, 'moonloader/config/fbitools/config.json') end imgui.SameLine(); imgui.Text(u8 '����������� Wanted')
                            if imadd.ToggleButton(u8'���clear', nclearb) then cfg.main.nclear = nclearb.v saveData(cfg, 'moonloader/config/fbitools/config.json') end imgui.SameLine(); imgui.Text(u8 '���������� Clear')
                        end
                        if imadd.ToggleButton(u8 "��������������� �����", modrb) then cfg.main.modr = modrb.v saveData(cfg, 'moonloader/config/fbitools/config.json') end imgui.SameLine(); imgui.Text(u8 '��������������� �����')
                        if imadd.ToggleButton(u8 "��������������� /members", modmb) then cfg.main.modm = modmb.v saveData(cfg, 'moonloader/config/fbitools/config.json') end imgui.SameLine(); imgui.Text(u8 '��������������� /members')
                        if imadd.ToggleButton(u8'������� ���������', stateb) then imgui.OpenPopup(u8 "����� ���������") end imgui.SameLine(); imgui.Text(u8 '������� ���������')
                        
                        if imgui.BeginPopupModal(u8 "����� ���������", _, imgui.WindowFlags.NoResize) then
                            imgui.Text(u8 "��� ����� ��������� ��������� ���� �������� �� �����������.")
                            imgui.Text(u8 "�� ������������� ������ ������� ��� ���������?")
                            if imgui.Button(u8 "����������##���������", imgui.ImVec2(imgui.GetWindowWidth() / 2 - 10, 20)) then
                                cfg.main.male = not cfg.main.male
                                cfg.otigrov = {
                                    cuff    = ("/me %s ���� �����������, ������� ��������� � ������������ �����\n{wait:1400}\n/cuff {playerid}"):format(cfg.main.male and '�������' or '��������'),
                                    uncuff  = ("/me %s ��������� � �����������\n{wait:"..cfg.commands.zaderjka.."}\n/uncuff {playerid}"):format(cfg.main.male and '����' or '�����'),
                                    follow  = ("/me ������ %s �����������, ����� ��� ����� � �����\n{wait:1400}\n/follow {playerid}"):format(cfg.main.male and "�������" or "��������"),
                                    take    = ("/me %s �������� �� ��������, �������� ����� �����������\n{wait:"..cfg.commands.zaderjka.."}\n/take {playerid}"):format(cfg.main.male and "������" or "�������"),
                                    arrest  = ("/me %s ������ �������, %s ���� id, ����� %s �� �������\n{wait:"..cfg.commands.zaderjka.."}\n/arrest {playerid}"):format(cfg.main.male and "������" or "�������", cfg.main.male and "������" or "�������", cfg.main.male and "������" or "�������")
                                }
                                saveData(cfg, 'moonloader/config/fbitools/config.json')
                                imgui.CloseCurrentPopup()
                            end
                            imgui.SameLine()
                            if imgui.Button(u8 "������##���������", imgui.ImVec2(imgui.GetWindowWidth() / 2 - 10, 20)) then imgui.CloseCurrentPopup() end
                            imgui.EndPopup()
                        end

                        if imadd.ToggleButton(u8'������������ �������', tagb) then cfg.main.tarb = tagb.v saveData(cfg, 'moonloader/config/fbitools/config.json') end imgui.SameLine(); imgui.Text(u8 '������������ �������')
                        if tagb.v then
                            if imgui.InputText(u8'������� ��� ���.', tagf) then cfg.main.tar = u8:decode(tagf.v) saveData(cfg, 'moonloader/config/fbitools/config.json') end
                            imgui.SameLine()
                            imgui.TextQuestion(u8 "��� ������������ ��� �� �����, ��� � ������ ( ����� {f6} � {noe} )")
                        end
                        if imadd.ToggleButton(u8'������������ ���� �����', parolb) then cfg.main.parolb = parolb.v saveData(cfg, 'moonloader/config/fbitools/config.json') end; imgui.SameLine(); imgui.Text(u8 '������������ ���������')
                        if parolb.v then
                            if imgui.InputText(u8'������� ��� ������.', parolf, imgui.InputTextFlags.Password) then cfg.main.parol = u8:decode(parolf.v) saveData(cfg, 'moonloader/config/fbitools/config.json') end
                            if imgui.Button(u8'������ ������') then ftext('��� ������: {9966cc}'..cfg.main.parol) end
                        end
                        if imadd.ToggleButton(u8'������������ ���� g-auth', googlecodebb) then cfg.main.googlecodeb = googlecodebb.v saveData(cfg, 'moonloader/config/fbitools/config.json') end; imgui.SameLine(); imgui.Text(u8 '������������ ���� g-auth')
                        if googlecodebb.v then
                            if imgui.InputText(u8'������� ��� ���� ���(������� ������ ��� �� �����).', googlecodeb, imgui.InputTextFlags.Password) then cfg.main.googlecode = googlecodeb.v saveData(cfg, 'moonloader/config/fbitools/config.json') end
                            if imgui.Button(u8'������ ���� ���') then ftext('��� ���� ���: {9966cc}'..cfg.main.googlecode) end
                            if #tostring(cfg.main.googlecode) == 16 then imgui.SameLine() imgui.Text(u8(("�������������� ���: %s"):format(genCode(tostring(cfg.main.googlecode))))) end
                        end
                        if imadd.ToggleButton(u8'������������ ���������', clistb) then cfg.main.clistb = clistb.v end; imgui.SameLine() saveData(cfg, 'moonloader/config/fbitools/config.json'); imgui.Text(u8 '������������ ���������')
                        if clistb.v then
                            if imgui.SliderInt(u8"�������� �������� ������", clistbuffer, 0, 33) then cfg.main.clist = clistbuffer.v saveData(cfg, 'moonloader/config/fbitools/config.json') end
                        end
                        if imadd.ToggleButton(u8'��������� ��� �� T', tchatb) then cfg.main.tchat = tchatb.v saveData(cfg, 'moonloader/config/fbitools/config.json') end imgui.SameLine(); imgui.Text(u8 '��������� ��� �� T')
                        if imadd.ToggleButton(u8 '������������� �������� ����', carb) then cfg.main.autocar = carb.v saveData(cfg, 'moonloader/config/fbitools/config.json') end imgui.SameLine(); imgui.Text(u8 '������������� �������� ����')
                        if imadd.ToggleButton(u8 '�� ��������', rpgunsb) then cfg.main.rpguns = rpgunsb.v saveData(cfg, 'moonloader/config/fbitools/config.json') end imgui.SameLine(); imgui.Text(u8 '�� ��������� ������')
                        if rpgunsb.v then
                            imgui.SameLine()
                            if imgui.Button(u8 "�������� ���������") then
                                imgui.OpenPopup(u8 "�������� ���������") 
                                rpedit.v = true
                            end
                            if imgui.BeginPopup(u8 "�������� ���������", _, imgui.WindowFlags.NoResize + imgui.WindowFlags.HorizontalScrollbar) then
                                for k, v in pairs(rpguns) do
                                    imgui.Text(u8("�������� ���������: "..v[1]))
                                    imgui.SameLine(400)
                                    if imgui.Button(u8 "��������##�����"..k) then 
                                        rpgunm = imgui.ImBuffer(u8(v[2]), 256)
                                        rpgunw = imgui.ImBuffer(u8(v[3]), 256)
                                        imgui.OpenPopup(u8 "�������������� ���������##gun"..k)
                                    end
                                    if imgui.BeginPopupModal(u8 "�������������� ���������##gun"..k, _, imgui.WindowFlags.NoResize + imgui.WindowFlags.HorizontalScrollbar) then
                                        imgui.Text(u8("�������� ���������: "..v[1]))
                                        imgui.NewLine()
                                        imgui.PushItemWidth(600)
                                        imgui.InputText(u8 "������� ���������", rpgunm)
                                        imgui.InputText(u8 "������� ���������", rpgunw)
                                        imgui.PopItemWidth()
                                        imgui.NewLine()
                                        if imgui.Button(u8 "���������##�����"..k, imgui.ImVec2(170, 30)) then 
                                            rpguns[k][2] = u8:decode(rpgunm.v)
                                            rpguns[k][3] = u8:decode(rpgunw.v)
                                            saveData(rpguns, "moonloader/config/fbitools/rpguns.json")
                                            imgui.CloseCurrentPopup() 
                                        end
                                        imgui.SameLine()
                                        imgui.SetCursorPosX(imgui.GetWindowWidth() - 180)
                                        if imgui.Button(u8 "�������##�����"..k, imgui.ImVec2(170, 30)) then imgui.CloseCurrentPopup() end
                                        imgui.EndPopup()
                                    end
                                end
                                imgui.EndPopup()
                            end
                        end
                        if cfg.main.group == '��/���' then
                            if imadd.ToggleButton(u8 '�����������', strobbsb) then cfg.main.strobs = strobbsb.v saveData(cfg, 'moonloader/config/fbitools/config.json') end imgui.SameLine(); imgui.Text(u8 '�����������')
                            if imadd.ToggleButton(u8 '����������� �������', megafb) then cfg.main.megaf = megafb.v end saveData(cfg, 'moonloader/config/fbitools/config.json'); imgui.SameLine(); imgui.Text(u8 '����������� �������')
                        end
                        imgui.Spacing()
                        if imgui.InputInt(u8'�������� � ����������', waitbuffer) then cfg.commands.zaderjka = waitbuffer.v saveData(cfg, 'moonloader/config/fbitools/config.json') end
                        imgui.Separator()
                        if imgui.Button(u8 '�������� ������') then imgui.OpenPopup(u8 '������ ������') end
                        imgui.SameLine()
                        imgui.Text(u8 '������� ������ �������: '..u8(cfg.main.group))
                        if imgui.BeginPopupModal(u8 '������ ������', _, imgui.WindowFlags.NoResize) then
                            imgui.CentrText(u8 '�� ������������� ������ �������� ������ �������?')
                            if imgui.Button(u8 '��##������', imgui.ImVec2(170, 20)) then cfg.main.group = 'unknown'
                                saveData(cfg, 'moonloader/config/fbitools/config.json')
                                registerCommands()
                                imgui.CloseCurrentPopup()
                            end
                            imgui.SameLine()
                            if imgui.Button(u8 '���##������', imgui.ImVec2(170, 20)) then imgui.CloseCurrentPopup() end
                            imgui.EndPopup()
                        end
                    elseif show == 2 then
                        if cfg.main.group == '��/���' then
                            if imadd.ToggleButton(u8('��������� /cput'), cput) then cfg.commands.cput = cput.v end; imgui.SameLine(); imgui.Text(u8 '��������� /cput')
                            if imadd.ToggleButton(u8('��������� /ceject'), ceject) then cfg.commands.ceject = ceject.v saveData(cfg, 'moonloader/config/fbitools/config.json') end; imgui.SameLine(); imgui.Text(u8 '��������� /ceject')
                            if imadd.ToggleButton(u8('��������� /ftazer'), ftazer) then cfg.commands.ftazer = ftazer.v saveData(cfg, 'moonloader/config/fbitools/config.json') end; imgui.SameLine(); imgui.Text(u8 '��������� /ftazer')
                            if imadd.ToggleButton(u8('��������� /deject'), deject) then cfg.commands.deject = deject.v saveData(cfg, 'moonloader/config/fbitools/config.json') end; imgui.SameLine(); imgui.Text(u8 '��������� /deject')
                            if imadd.ToggleButton(u8('��������� /ticket'), ticketb) then cfg.commands.ticket = ticketb.v saveData(cfg, 'moonloader/config/fbitools/config.json') end; imgui.SameLine(); imgui.Text(u8 '��������� /ticket')
                            if imadd.ToggleButton(u8('������������ /time F8 ��� /kmdc'), kmdcb) then cfg.commands.kmdctime = kmdcb.v saveData(cfg, 'moonloader/config/fbitools/config.json') end; imgui.SameLine(); imgui.Text(u8 '������������ /time F8 ��� /kmdc')
                        end
                    elseif show == 3 then
                        if cfg.main.group ~= "�����" then
                            if imadd.HotKey(u8'##������� �������������� � �������', config_keys.vzaimkey, tLastKeys, 100) then
                                rkeys.changeHotKey(vzaimbind, config_keys.vzaimkey.v)
                                notf.addNotification('������� ������� ��������. ������ ��������: '.. table.concat(rkeys.getKeysName(tLastKeys.v), " + ") .. ' | ����� ��������: '.. table.concat(rkeys.getKeysName(config_keys.vzaimkey.v), " + "), 4, 2)
                                saveData(config_keys, 'moonloader/config/fbitools/keys.json')
                            end
                            imgui.SameLine()
                            imgui.Text(u8 '������� �������������� � ������� (����������� ����� ������������ �� ������)')
                            if imadd.HotKey('##fastmenu', config_keys.fastmenukey, tLastKeys, 100) then
                                rkeys.changeHotKey(fastmenubind, config_keys.fastmenukey.v)
                                notf.addNotification('������� ������� ��������. ������ ��������: '.. table.concat(rkeys.getKeysName(tLastKeys.v), " + ") .. ' | ����� ��������: '.. table.concat(rkeys.getKeysName(config_keys.fastmenukey.v), " + "), 4, 2)
                                saveData(config_keys, 'moonloader/config/fbitools/keys.json')
                            end
                            imgui.SameLine()
                            imgui.Text(u8('������� �������� ����'))
                        end
                        if cfg.main.group == '��/���' or cfg.main.group == '�����' then
                            if imadd.HotKey(u8'##������� �������� ������', config_keys.tazerkey, tLastKeys, 100) then
                                rkeys.changeHotKey(tazerbind, config_keys.tazerkey.v)
                                notf.addNotification('������� ������� ��������. ������ ��������: '.. table.concat(rkeys.getKeysName(tLastKeys.v), " + ") .. ' | ����� ��������: '.. table.concat(rkeys.getKeysName(config_keys.tazerkey.v), " + "), 4, 2)
                                saveData(config_keys, 'moonloader/config/fbitools/keys.json')
                            end
                            imgui.SameLine()
                            imgui.Text(u8'������� �������� ������')
                        end
                        if cfg.main.group == '��/���' then
                            if imadd.HotKey('##oopda', config_keys.oopda, tLastKeys, 100) then
                                rkeys.changeHotKey(oopdabind, config_keys.oopda.v)
                                notf.addNotification('������� ������� ��������. ������ ��������: '.. table.concat(rkeys.getKeysName(tLastKeys.v), " + ") .. ' | ����� ��������: '.. table.concat(rkeys.getKeysName(config_keys.oopda.v), " + "), 4, 2)
                                saveData(config_keys, 'moonloader/config/fbitools/keys.json')
                            end
                            imgui.SameLine()
                            imgui.Text(u8('������� �������������'))
                            if imadd.HotKey('##oopnet', config_keys.oopnet, tLastKeys, 100) then
                                rkeys.changeHotKey(oopnetbind, config_keys.oopnet.v)
                                notf.addNotification('������� ������� ��������. ������ ��������: '.. table.concat(rkeys.getKeysName(tLastKeys.v), " + ") .. ' | ����� ��������: '.. table.concat(rkeys.getKeysName(config_keys.oopnet.v), " + "), 4, 2)
                                saveData(config_keys, 'moonloader/config/fbitools/keys.json')
                            end
                            imgui.SameLine()
                            imgui.Text(u8('������� ������'))
                            if imadd.HotKey('##megaf', config_keys.megafkey, tLastKeys, 100) then
                                rkeys.changeHotKey(megafbind, config_keys.megafkey.v)
                                notf.addNotification('������� ������� ��������. ������ ��������: '.. table.concat(rkeys.getKeysName(tLastKeys.v), " + ") .. ' | ����� ��������: '.. table.concat(rkeys.getKeysName(config_keys.megafkey.v), " + "), 4, 2)
                                saveData(config_keys, 'moonloader/config/fbitools/keys.json')
                            end
                            imgui.SameLine()
                            imgui.Text(u8('������� ��������'))
                            if imadd.HotKey('##dkld', config_keys.dkldkey, tLastKeys, 100) then
                                rkeys.changeHotKey(dkldbind, config_keys.dkldkey.v)
                                notf.addNotification('������� ������� ��������. ������ ��������: '.. table.concat(rkeys.getKeysName(tLastKeys.v), " + ") .. ' | ����� ��������: '.. table.concat(rkeys.getKeysName(config_keys.dkldkey.v), " + "), 4, 2)
                                saveData(config_keys, 'moonloader/config/fbitools/keys.json')
                            end
                            imgui.SameLine()
                            imgui.Text(u8('������� �������'))
                            if imadd.HotKey('##cuff', config_keys.cuffkey, tLastKeys, 100) then
                                rkeys.changeHotKey(cuffbind, config_keys.cuffkey.v)
                                notf.addNotification('������� ������� ��������. ������ ��������: '.. table.concat(rkeys.getKeysName(tLastKeys.v), " + ") .. ' | ����� ��������: '.. table.concat(rkeys.getKeysName(config_keys.cuffkey.v), " + "), 4, 2)
                                saveData(config_keys, 'moonloader/config/fbitools/keys.json')
                            end
                            imgui.SameLine()
                            imgui.Text(u8('������ ��������� �� �����������'))
                            if imadd.HotKey('##uncuff', config_keys.uncuffkey, tLastKeys, 100) then
                                rkeys.changeHotKey(uncuffbind, config_keys.uncuffkey.v)
                                notf.addNotification('������� ������� ��������. ������ ��������: '.. table.concat(rkeys.getKeysName(tLastKeys.v), " + ") .. ' | ����� ��������: '.. table.concat(rkeys.getKeysName(config_keys.uncuffkey.v), " + "), 4, 2)
                                saveData(config_keys, 'moonloader/config/fbitools/keys.json')
                            end
                            imgui.SameLine()
                            imgui.Text(u8('����� ���������'))
                            if imadd.HotKey('##follow', config_keys.followkey, tLastKeys, 100) then
                                rkeys.changeHotKey(followbind, config_keys.followkey.v)
                                notf.addNotification('������� ������� ��������. ������ ��������: '.. table.concat(rkeys.getKeysName(tLastKeys.v), " + ") .. ' | ����� ��������: '.. table.concat(rkeys.getKeysName(config_keys.followkey.v), " + "), 4, 2)
                                saveData(config_keys, 'moonloader/config/fbitools/keys.json')
                            end
                            imgui.SameLine()
                            imgui.Text(u8('����� ����������� �� �����'))
                            if imadd.HotKey('##cput', config_keys.cputkey, tLastKeys, 100) then
                                rkeys.changeHotKey(cputbind, config_keys.cputkey.v)
                                notf.addNotification('������� ������� ��������. ������ ��������: '.. table.concat(rkeys.getKeysName(tLastKeys.v), " + ") .. ' | ����� ��������: '.. table.concat(rkeys.getKeysName(config_keys.cputkey.v), " + "), 4, 2)
                                saveData(config_keys, 'moonloader/config/fbitools/keys.json')
                            end
                            imgui.SameLine()
                            imgui.Text(u8('�������� ����������� � ����'))
                            if imadd.HotKey('##ceject', config_keys.cejectkey, tLastKeys, 100) then
                                rkeys.changeHotKey(cejectbind, config_keys.cejectkey.v)
                                notf.addNotification('������� ������� ��������. ������ ��������: '.. table.concat(rkeys.getKeysName(tLastKeys.v), " + ") .. ' | ����� ��������: '.. table.concat(rkeys.getKeysName(config_keys.cejectkey.v), " + "), 4, 2)
                                saveData(config_keys, 'moonloader/config/fbitools/keys.json')
                            end
                            imgui.SameLine()
                            imgui.Text(u8('�������� ����������� � �������'))
                            if imadd.HotKey('##take', config_keys.takekey, tLastKeys, 100) then
                                rkeys.changeHotKey(takebind, config_keys.takekey.v)
                                notf.addNotification('������� ������� ��������. ������ ��������: '.. table.concat(rkeys.getKeysName(tLastKeys.v), " + ") .. ' | ����� ��������: '.. table.concat(rkeys.getKeysName(config_keys.takekey.v), " + "), 4, 2)
                                saveData(config_keys, 'moonloader/config/fbitools/keys.json')
                            end
                            imgui.SameLine()
                            imgui.Text(u8('�������� �����������'))
                            if imadd.HotKey('##arrest', config_keys.arrestkey, tLastKeys, 100) then
                                rkeys.changeHotKey(arrestbind, config_keys.arrestkey.v)
                                notf.addNotification('������� ������� ��������. ������ ��������: '.. table.concat(rkeys.getKeysName(tLastKeys.v), " + ") .. ' | ����� ��������: '.. table.concat(rkeys.getKeysName(config_keys.arrestkey.v), " + "), 4, 2)
                                saveData(config_keys, 'moonloader/config/fbitools/keys.json')
                            end
                            imgui.SameLine()
                            imgui.Text(u8('���������� �����������'))
                            if imadd.HotKey('##deject', config_keys.dejectkey, tLastKeys, 100) then
                                rkeys.changeHotKey(dejectbind, config_keys.dejectkey.v)
                                notf.addNotification('������� ������� ��������. ������ ��������: '.. table.concat(rkeys.getKeysName(tLastKeys.v), " + ") .. ' | ����� ��������: '.. table.concat(rkeys.getKeysName(config_keys.dejectkey.v), " + "), 4, 2)
                                saveData(config_keys, 'moonloader/config/fbitools/keys.json')
                            end
                            imgui.SameLine()
                            imgui.Text(u8('�������� ����������� �� ����'))
                            if imadd.HotKey('##siren', config_keys.sirenkey, tLastKeys, 100) then
                                rkeys.changeHotKey(sirenbind, config_keys.sirenkey.v)
                                notf.addNotification('������� ������� ��������. ������ ��������: '.. table.concat(rkeys.getKeysName(tLastKeys.v), " + ") .. ' | ����� ��������: '.. table.concat(rkeys.getKeysName(config_keys.sirenkey.v), " + "), 4, 2)
                                saveData(config_keys, 'moonloader/config/fbitools/keys.json')
                            end
                            imgui.SameLine()
                            imgui.Text(u8('�������� / ��������� ������ �� ����'))
                        end
                        if cfg.main.group == '�����' then
                            if imadd.HotKey('##hik', config_keys.hikey, tLastKeys, 100) then 
                                rkeys.changeHotKey(hibind, config_keys.hikey.v) 
                                notf.addNotification('������� ������� ��������. ������ ��������: '.. table.concat(rkeys.getKeysName(tLastKeys.v), " + ") .. ' | ����� ��������: '.. table.concat(rkeys.getKeysName(config_keys.hikey.v), " + "), 4, 2)
                                saveData(config_keys, 'moonloader/config/fbitools/keys.json')
                            end imgui.SameLine() imgui.Text(u8 '�����������')
                            if imadd.HotKey('##sumk', config_keys.summakey, tLastKeys, 100) then 
                                rkeys.changeHotKey(summabind, config_keys.summakey.v) 
                                notf.addNotification('������� ������� ��������. ������ ��������: '.. table.concat(rkeys.getKeysName(tLastKeys.v), " + ") .. ' | ����� ��������: '.. table.concat(rkeys.getKeysName(config_keys.summakey.v), " + "), 4, 2)
                                saveData(config_keys, 'moonloader/config/fbitools/keys.json')
                            end imgui.SameLine() imgui.Text(u8 '�������� �����')
                            if imadd.HotKey('##freenk', config_keys.freenalkey, tLastKeys, 100) then 
                                rkeys.changeHotKey(freenalbind, config_keys.freenalkey.v) 
                                notf.addNotification('������� ������� ��������. ������ ��������: '.. table.concat(rkeys.getKeysName(tLastKeys.v), " + ") .. ' | ����� ��������: '.. table.concat(rkeys.getKeysName(config_keys.freenalkey.v), " + "), 4, 2)
                                saveData(config_keys, 'moonloader/config/fbitools/keys.json')
                            end imgui.SameLine() imgui.Text(u8 '��������� ���������')
                            if imadd.HotKey('##freebk', config_keys.freebankkey, tLastKeys, 100) then 
                                rkeys.changeHotKey(freebankbind, config_keys.freebankkey.v) 
                                notf.addNotification('������� ������� ��������. ������ ��������: '.. table.concat(rkeys.getKeysName(tLastKeys.v), " + ") .. ' | ����� ��������: '.. table.concat(rkeys.getKeysName(config_keys.freebankkey.v), " + "), 4, 2)
                                saveData(config_keys, 'moonloader/config/fbitools/keys.json')
                            end imgui.SameLine() imgui.Text(u8 '��������� ����� ����')
                        end
                        if imadd.HotKey('##offotig', config_keys.offotig, tLastKeys, 100) then
                            rkeys.changeHotKey(offotigbind, config_keys.offotig.v)
                            notf.addNotification('������� ������� ��������. ������ ��������: '.. table.concat(rkeys.getKeysName(tLastKeys.v), " + ") .. ' | ����� ��������: '.. table.concat(rkeys.getKeysName(config_keys.offotig.v), " + "), 4, 2)
                            saveData(config_keys, 'moonloader/config/fbitools/keys.json')
                        end
                        imgui.SameLine()
                        imgui.Text(u8('������� ���������� ���������'))
                    elseif show == 4 then
                        local autolist = {"Desert Eagle", "Shotgun", "MP5", "M4A1", "Rifle", "�����", "���� ������"}
                        if imadd.ToggleButton(u8 '������', autobpb) then cfg.main.autobp = autobpb.v end saveData(cfg, 'moonloader/config/fbitools/config.json'); imgui.SameLine(); imgui.Text(u8 '������������� ����� ����������')
                        imgui.Spacing()
                        imgui.Separator()
                        imgui.Spacing()
                        for i = 1, #cfg.autopbguns do
                            if cfg.autopbguns[i] == nil then cfg.autopbguns[i] = false end
                                if type(cfg.autopbguns[i]) == "number" then
                                if cfg.autopbguns[i] > 0 then cfg.autopbguns[i] = true
                                else cfg.autopbguns[i] = false end
                            end
                            local interval = imgui.ImBool(cfg.autopbguns[i])
                            imgui.PushItemWidth(125)
                            if imadd.ToggleButton('##counter'..i, interval) then
                                cfg.autopbguns[i] = interval.v
                                saveData(cfg, 'moonloader/config/fbitools/config.json')
                            end
                            imgui.SameLine(); imgui.Text(u8:encode(autolist[i]))
                            imgui.PopItemWidth()
                        end
                    elseif show == 5 then
                        local list = {"����������", "������", "���������", "����", "�������", "�����", "�����"}

                        if imadd.ToggleButton(u8 '�������', infbarb) then cfg.main.hud = infbarb.v saveData(cfg, 'moonloader/config/fbitools/config.json') end imgui.SameLine() imgui.Text(u8 " �������� / ��������� �������")
                        
                        imgui.Spacing()
                        imgui.Separator()
                        imgui.Spacing()

                        if infbarb.v then
                            imgui.SameLine()
                            if imgui.Button(u8 '�������� ��������������') then
                                mainw.v = false
                                changetextpos = true
                                ftext('�� ��������� ������� ����� ������ ����')
                            end
                            if imgui.SliderFloat(u8"����������� ��������", opacity, 0.0, 1.0, "%.3f", 0.5) then cfg.main.hudopacity = opacity.v saveData(cfg, 'moonloader/config/fbitools/config.json') end
                            if imgui.SliderFloat(u8"���������� ������ ��������", rounding, 0.0, 15.0, "%.2f", 0.5) then cfg.main.hudrounding = rounding.v saveData(cfg, 'moonloader/config/fbitools/config.json') end
                            if imgui.SliderFloat(u8"������ ��������", widehud, 1.0, 1000.0, "%.2f", 0.5) then cfg.main.widehud = widehud.v saveData(cfg, 'moonloader/config/fbitools/config.json') end
                            if imadd.ToggleButton(u8 "�����", showtitle) then cfg.main.hudshowtitle = showtitle.v saveData(cfg, 'moonloader/config/fbitools/config.json') end imgui.SameLine() imgui.Text(u8 "�����")
                            imgui.SameLine()
                            imgui.TextQuestion(u8 "������� \"FBI Tools\" � ��������")
                        

                            imgui.Spacing()
                            imgui.Separator()
                            imgui.Spacing()

                            imgui.Text(u8 "���������� ��������:")
                            imgui.Spacing()

                            for i = 1, #cfg.showhud do
                                if cfg.showhud[i] == nil then cfg.showhud[i] = false end
                                    if type(cfg.showhud[i]) == "number" then
                                    if cfg.showhud[i] > 0 then cfg.showhud[i] = true
                                    else cfg.showhud[i] = false end
                                end
                                local interval = imgui.ImBool(cfg.showhud[i])
                                imgui.PushItemWidth(125)
                                if imadd.ToggleButton('##counter'..i, interval) then
                                    cfg.showhud[i] = interval.v
                                    saveData(cfg, 'moonloader/config/fbitools/config.json')
                                end
                                imgui.SameLine(); imgui.Text(u8:encode(list[i]))
                                imgui.PopItemWidth()
                            end
                        end
                    elseif show == 6 then
                        
                        for k, v in pairs(cfg.otigrov) do
                            imgui.Text(u8 "���������: /"..k)
                            imgui.SameLine(300)
                            if imgui.Button(u8 "��������##"..k) then otigtext.v = u8(v) 
                                imgui.OpenPopup(u8 "������������� ��������� /"..k)
                            end
                            if imgui.BeginPopupModal(u8 "������������� ��������� /"..k, _, imgui.WindowFlags.NoResize) then
                                imgui.Text(u8 "����� ���������:")
                                imgui.Spacing()
                                imgui.InputTextMultiline("##redaktorept", otigtext, imgui.ImVec2(678, 200))
                                if imgui.Button(u8 "���������##"..k..""..v, imgui.ImVec2(imgui.GetWindowWidth() / 3 - 8.3, 20)) then cfg.otigrov[k] = u8:decode(otigtext.v) imgui.CloseCurrentPopup() end
                                imgui.SameLine()
                                if imgui.Button(u8 '�����', imgui.ImVec2(imgui.GetWindowWidth() / 3 - 8.3, 20)) then imgui.OpenPopup('##bindkey') end
                                if imgui.BeginPopup('##bindkey') then
                                    imgui.Text(u8 '{myid} - ID ������ ��������� | '..select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)))
                                    imgui.Text(u8 '{myrpnick} - �� ��� ������ ��������� | '..sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))):gsub('_', ' '))
                                    imgui.Text(u8 ('{kv} - ��� ������� ������� | '..kvadrat()))
                                    imgui.Text(u8 '{targetid} - ID ������ �� �������� �� �������� | '..targetid)
                                    imgui.Text(u8 '{targetrpnick} - �� ��� ������ �� �������� �� �������� | '..sampGetPlayerNicknameForBinder(targetid):gsub('_', ' '))
                                    imgui.Text(u8 '{smsid} - ��������� ID ����, ��� ��� ������� � SMS | '..smsid)
                                    imgui.Text(u8 '{smstoid} - ��������� ID ����, ���� �� �������� � SMS | '..smstoid)
                                    imgui.Text(u8 '{megafid} - ID ������, �� ������� ���� ������ ������ | '..gmegafid)
                                    imgui.Text(u8 '{rang} - ���� ������ | '..u8(rang))
                                    imgui.Text(u8 '{frak} - ���� ������� | '..u8(frak))
                                    imgui.Text(u8 '{dl} - ID ����, � ������� �� ������ | '..mcid)
                                    imgui.Text(u8 '{noe} - �������� ��������� � ����� ����� � �� ���������� ��� � ��� (������������ � ����� ������)')
                                    imgui.Text(u8 '{wait:sek} - �������� ����� ��������, ��� sek - ���-�� �����������. ������: {wait:2000} - �������� 2 �������. (������������ �������� �� ����� �������)')
                                    imgui.Text(u8 '{screen} - ������� �������� ������ (������������ �������� �� ����� �������)')
                                    imgui.Text(u8 "{playerid} - �� ������, �� �������� ����������� ���������")
                                    imgui.EndPopup()
                                end
                                imgui.SameLine()
                                if imgui.Button(u8 "�������", imgui.ImVec2(imgui.GetWindowWidth() / 3 - 8.3, 20)) then imgui.CloseCurrentPopup() end
                                imgui.EndPopup()
                            end
                        end
                        
                    end
                    imgui.EndChild()
                else
                    imgui.SetCursorPosX( imgui.GetWindowWidth()/2 - imgui.CalcTextSize(u8 "�������� ���� ������ �������").x/2 - 50 )
                    imgui.SetCursorPosY( imgui.GetWindowHeight()/2 )
                    imgui.PushItemWidth(100)
                    imgui.Combo(u8 '�������� ���� ������ �������', groupInt, groupNames)
                    imgui.SetCursorPosX( imgui.GetWindowWidth()/2 - 50 )
                    if imgui.Button(u8 '�����������') then
                        notf.addNotification("�� ������� ������:\n"..u8:decode(groupNames[groupInt.v + 1]), 4, 2)
                        cfg.main.group = u8:decode(groupNames[groupInt.v + 1])
                        saveData(cfg, 'moonloader/config/fbitools/config.json')
                        registerCommands()
                    end
                end
                imgui.End()
            end

        end
        if shpwindow.v then
            imgui.ShowCursor = true
            local iScreenWidth, iScreenHeight = getScreenResolution()
            imgui.SetNextWindowPos(imgui.ImVec2(iScreenWidth / 2, iScreenHeight / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
            imgui.SetNextWindowSize(imgui.ImVec2(iScreenWidth/2, iScreenHeight / 2), imgui.Cond.FirstUseEver)
            imgui.Begin(u8(script.this.name..' | �����'), shpwindow)
            for line in io.lines('moonloader\\fbitools\\shp.txt') do
                imgui.TextWrapped(u8(line))
            end
            imgui.End()
        end
        if akwindow.v then
            imgui.ShowCursor = true
            local iScreenWidth, iScreenHeight = getScreenResolution()
            imgui.SetNextWindowPos(imgui.ImVec2(iScreenWidth / 2, iScreenHeight / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
            imgui.SetNextWindowSize(imgui.ImVec2(iScreenWidth/2, iScreenHeight / 2), imgui.Cond.FirstUseEver)
            imgui.Begin(u8(script.this.name..' | ���������������� ������'), akwindow)
            for line in io.lines('moonloader\\fbitools\\ak.txt') do
                imgui.TextWrapped(u8(line))
            end
            imgui.End()
        end
        if fpwindow.v then
            imgui.ShowCursor = true
            local iScreenWidth, iScreenHeight = getScreenResolution()
            imgui.SetNextWindowPos(imgui.ImVec2(iScreenWidth / 2, iScreenHeight / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
            imgui.SetNextWindowSize(imgui.ImVec2(iScreenWidth/2, iScreenHeight / 2), imgui.Cond.FirstUseEver)
            imgui.Begin(u8(script.this.name..' | ����������� �������������'), fpwindow)
            for line in io.lines('moonloader\\fbitools\\fp.txt') do
                imgui.TextWrapped(u8(line))
            end
            imgui.End()
        end
        if ykwindow.v then
            imgui.ShowCursor = true
            local iScreenWidth, iScreenHeight = getScreenResolution()
            imgui.SetNextWindowPos(imgui.ImVec2(iScreenWidth / 2, iScreenHeight / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
            imgui.SetNextWindowSize(imgui.ImVec2(iScreenWidth/2, iScreenHeight / 2), imgui.Cond.FirstUseEver)
            imgui.Begin(u8(script.this.name..' | ��������� ������'), ykwindow)
            for line in io.lines('moonloader\\fbitools\\yk.txt') do
                imgui.TextWrapped(u8(line))
            end
            imgui.End()
        end
        if memw.v then
            imgui.ShowCursor = true
            local sw, sh = getScreenResolution()
            --imgui.SetWindowPos('##' .. thisScript().name, imgui.ImVec2(sw/2 - imgui.GetWindowSize().x/2, sh/2 - imgui.GetWindowSize().y/2))
            --imgui.SetWindowSize('##' .. thisScript().name, imgui.ImVec2(670, 500))
            imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
            imgui.SetNextWindowSize(imgui.ImVec2(670, 330), imgui.Cond.FirstUseEver)
            imgui.Begin(u8(script.this.name..' | ������ ����������� [�����: %s]'):format(#tMembers), memw, imgui.WindowFlags.NoResize)
            imgui.BeginChild('##1', imgui.ImVec2(670, 300))
            imgui.Columns(5, _)
            imgui.SetColumnWidth(-1, 180) imgui.Text(u8 '��� ������'); imgui.NextColumn()
            imgui.SetColumnWidth(-1, 190) imgui.Text(u8 '���������');  imgui.NextColumn()
            imgui.SetColumnWidth(-1, 80) imgui.Text(u8 '������') imgui.NextColumn()
            imgui.SetColumnWidth(-1, 120) imgui.Text(u8 '���� ������') imgui.NextColumn() 
            imgui.SetColumnWidth(-1, 70) imgui.Text(u8 'AFK') imgui.NextColumn() 
            imgui.Separator()
            for _, v in ipairs(tMembers) do
                imgui.TextColored(imgui.ImVec4(getColor(v.id)), u8('%s [%s]'):format(v.nickname, v.id))
                if imgui.IsItemHovered() then
                    imgui.BeginTooltip();
                    imgui.PushTextWrapPos(450.0);
                    imgui.TextColored(imgui.ImVec4(getColor(v.id)), u8("%s\n�������: %s"):format(v.nickname, sampGetPlayerScore(v.id)))
                    imgui.PopTextWrapPos();
                    imgui.EndTooltip();
                end
                imgui.NextColumn()
                imgui.Text(('%s [%s]'):format(v.sRang, v.iRang))
                imgui.NextColumn()
                if v.status ~= u8("�� ������") then
                    imgui.TextColored(imgui.ImVec4(0.80, 0.00, 0.00, 1.00), v.status);
                else
                    imgui.TextColored(imgui.ImVec4(0.00, 0.80, 0.00, 1.00), v.status);
                end
                imgui.NextColumn()
                imgui.Text(v.invite)
                imgui.NextColumn()
                if v.sec ~= 0 then
                    if v.sec < 360 then 
                        imgui.TextColored(getColorForSeconds(v.sec), tostring(v.sec .. u8(' ���.')));
                    else
                        imgui.TextColored(getColorForSeconds(v.sec), tostring("360+" .. u8(' ���.')));
                    end
                else
                    imgui.TextColored(imgui.ImVec4(0.00, 0.80, 0.00, 1.00), u8("���"));
                end
                imgui.NextColumn()
            end
            imgui.Columns(1)
            imgui.EndChild()
            imgui.End()
        end
    end
end

function replaceIds(string)
    while true do
        if string:find("@%d+") then
            local id = string:match("@(%d+)")
            if id ~= nil and sampIsPlayerConnected(id) then
                string = string:gsub("@"..id, sampGetPlayerNickname(id))
            else
                string = string:gsub("@"..id, id)
            end
        else break end
    end
    -------------
    while true do
        if string:find("#%d+") then
            local id = string:match("#(%d+)")
            if id ~= nil and sampIsPlayerConnected(id) then
                string = string:gsub("#"..id, sampGetPlayerNickname(id):gsub('_', ' '))
            else
                string = string:gsub("#"..id, id)
            end
        else break end
    end
    return string
end

if lsampev then
    function sp.onPlayerQuit(id, reason)
        if gmegafhandle ~= -1 and id == gmegafid then
            sampAddChatMessage(' {ffffff}~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~', 0x9966cc)
            sampAddChatMessage('', 0x9966cc)
            sampAddChatMessage(' {ffffff}�����: {9966cc}'..sampGetPlayerNickname(gmegafid)..' ['..gmegafid..'] {ffffff}����� �� ����', 0x9966cc)
            sampAddChatMessage(' {ffffff}�������: {9966cc}'..gmegaflvl, 0x9966cc)
            sampAddChatMessage(' {ffffff}�������: {9966cc}'..gmegaffrak, 0x9966cc)
            sampAddChatMessage(' {ffffff}������� ������: {9966cc}'..quitReason[reason], 0x9966CC)
            sampAddChatMessage('', 0x9966cc)
            sampAddChatMessage(' {ffffff}~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~', 0x9966cc)
            gmegafid = -1
            gmegaflvl = nil
            gmegaffrak = nil
            gmegafhandle = nil
        end
    end

    function sp.onSendSpawn()
        if cfg.main.clistb and rabden then
            lua_thread.create(function()
                wait(1400)
                notf.addNotification('���� ���� ������ ��: ' .. cfg.main.clist, 4, 2)
                sampSendChat('/clist '..cfg.main.clist)
            end)
        end
    end

    function sp.onSendCommand(command)
        local str = replaceIds(command)
        sInfo.flood = os.clock()
        if str ~= command then
            return { str }
        end
    end
      
    function sp.onSendChat(message)
        local str = replaceIds(message)
        sInfo.flood = os.clock()
        if str ~= message then
            return { str }
        end
    end

    function sp.onServerMessage(color, text)
        if cfg.main.modr and (color == 33357768 or color == -1920073984) and text:match('%S+%: .+') then
            local nick = text:match('(%S+)%: .+'):gsub("%[%d+%]", ""):gsub(" ", "")
            local id = sampGetPlayerIdByNickname(nick)
            if id then
                text = text:gsub(nick, ("{%s}%s [%s]{%s}"):format(("%06X"):format(bit.band(sampGetPlayerColor(id), 0xFFFFFF)), nick, id, ("%06X"):format(bit.rshift(color, 8))))
            end
        end

        if cfg.main.modm then
            if text:match("^ ID: %d+.+") then
                local id = text:match("^ ID: (%d+).+")
                color = argb_to_rgba(sampGetPlayerColor(id))
            end
        end

        if text:find("� ������� ������ ��� ����") and ins.isLicense then
            ins.isLicense = false
            ins.list = nil
        end
        if text:match(" ^�� ������ ������������� �� ������������ %S!$") then
            local nick = text:match(" ^�� ������ ������������� �� ������������ (%S)!$")
            local id = sampGetPlayerIdByNickname(nick)
            gmegafid = id
            gmegaflvl = sampGetPlayerScore(id)
            gmegaffrak = sampGetFraktionBySkin(id)
        end
        if nazhaloop then
            if text:match('�������� ��������� � /d ����� ��� � 10 ������!') then
                zaproop = true
                ftext('�� ������� ������ � ��� ������ {9966cc}'..nikk..'{ffffff}. ��������� �������?')
                ftext('�����������: {9966cc}'..table.concat(rkeys.getKeysName(config_keys.oopda.v), " + ")..'{ffffff} | ��������: {9966cc}'..table.concat(rkeys.getKeysName(config_keys.oopnet.v), " + "))
            end
            if nikk == nil then
                dmoop = false
                nikk = nil
                zaproop = false
                aroop = false
                nazhaloop = false
            end
            if color == -8224086 and text:find(nikk) then
                dmoop = false
                nikk = nil
                zaproop = false
                aroop = false
                nazhaloop = false
            end
        end
        if (text:match('���� �� ��� .+ ������������ �� ��������, ���') or text:match('���� .+ ������������ �� �������� %- ���.')) and color == -8224086 then
            local ooptext = text:match('Mayor, (.+)')
            table.insert(ooplistt, ooptext)
        end
        if text:find('{00AB06}����� ������� ���������, ������� ������� {FFFFFF}"2"{00AB06} ��� ������� ������� {FFFFFF}"/en"') then
            if cfg.main.autocar then
                lua_thread.create(function()
                    while not isCharInAnyCar(PLAYER_PED) do wait(0) end
                    if not isCarEngineOn(storeCarCharIsInNoSave(PLAYER_PED)) then
                        while sampIsChatInputActive() or sampIsDialogActive() or isSampfuncsConsoleActive() do wait(0) end
                        setVirtualKeyDown(key.VK_2, true)
                        wait(150)
                        setVirtualKeyDown(key.VK_2, false)
                    end
                end)
            end
        end
        if color == -8224086 then
            local colors = ("{%06X}"):format(bit.rshift(color, 8))
            table.insert(departament, os.date(colors.."[%H:%M:%S] ") .. text)
        end
        if color == -1920073984 and (text:match('.+ .+%: .+') or text:match('%(%( .+ .+%: .+ %)%)')) then
            local colors = ("{%06X}"):format(bit.rshift(color, 8))
            table.insert(radio, os.date(colors.."[%H:%M:%S] ") .. text)
        end
        if color == -3669760 and text:match('%[Wanted %d+: .+%] %[��������%: .+%] %[.+%]') then
            local colors = ("{%06X}"):format(bit.rshift(color, 8))
            table.insert(wanted, os.date(colors.."[%H:%M:%S] ") .. text)
        end
        if color == -65366 and (text:match('SMS%: .+. �����������%: .+') or text:match('SMS%: .+. ����������%: .+')) then
            if text:match('SMS%: .+. �����������%: .+%[%d+%]') then smsid = text:match('SMS%: .+. �����������%: .+%[(%d+)%]') elseif text:match('SMS%: .+. ����������%: .+%[%d+%]') then smstoid = text:match('SMS%: .+. ����������%: .+%[(%d+)%]') end
            local colors = ("{%06X}"):format(bit.rshift(color, 8))
            table.insert(sms, os.date(colors.."[%H:%M:%S] ") .. text)
        end
        if mcheckb then
            if text:find('---======== ��������� ��������� ������ ========---') then
                local open = io.open("moonloader/fbitools/mcheck.txt", 'a')
                open:write(string.format('%s\n', text))
                open:close()
            end
            if text:find('���:') then
                local open = io.open("moonloader/fbitools/mcheck.txt", 'a')
                open:write(string.format('%s\n', text))
                open:close()
            end
            if text:find('�����������:') then
                local open = io.open("moonloader/fbitools/mcheck.txt", 'a')
                open:write(string.format('%s\n', text))
                open:close()
            end
            if text:find('������������:') then
                local open = io.open("moonloader/fbitools/mcheck.txt", 'a')
                open:write(string.format('%s\n', text))
                open:close()
            end
            if text:find('�������:') then
                local open = io.open("moonloader/fbitools/mcheck.txt", 'a')
                open:write(string.format('%s\n', text))
                open:close()
            end
            if text:find('������� �������:') then
                local open = io.open("moonloader/fbitools/mcheck.txt", 'a')
                open:write(string.format('%s\n', text))
                open:close()
            end
            if text:find('---============================================---') then
                local open = io.open("moonloader/fbitools/mcheck.txt", 'a')
                open:write(string.format('%s\n', text))
                open:write(' \n')
                open:close()
            end
        end
        if text:find('�� �������� � ������') then
            local nik, sek = text:match('�� �������� � ������ (%S+) �� (%d+) ������')
            if sek == '3600' or sek == '3000'  then
                lua_thread.create(function()
                    nikk = nik:gsub('_', ' ')
                    aroop = true
                    wait(3000)
                    ftext(string.format("��������� �������� ���� �� ��� {9966cc}%s", nikk), -1)
                    ftext('�����������: {9966cc}'..table.concat(rkeys.getKeysName(config_keys.oopda.v), " + ")..'{ffffff} | ��������: {9966cc}'..table.concat(rkeys.getKeysName(config_keys.oopnet.v), " + "), -1)
                end)
            end
        end
        if text:find('�� �������� ����������� ��') then
            local sekk = text:match('�� �������� ����������� �� (.+) ������!')
            if sekk == '3000' or sekk == '3600' then
                lua_thread.create(function()
                    nikk = sampGetPlayerNickname(tdmg)
                    dmoop = true
                    wait(50)
                    ftext(string.format("��������� �������� ���� �� ��� {9966cc}%s", nikk:gsub('_', ' ')), -1)
                    ftext('�����������: {9966cc}'..table.concat(rkeys.getKeysName(config_keys.oopda.v), " + ")..'{ffffff} | ��������: {9966cc}'..table.concat(rkeys.getKeysName(config_keys.oopnet.v), " + "), -1)
                end)
            end
        end

        if text:match('�����: %d+ �������') then
            request_data.members = text:match('�����: (%d+) �������')
            request_data.updated = os.time()
        end

        if status then
            if text:find("ID: %d+ | .+ | %g+: .+%[%d+%] %- %{......%}.+%{......%}") then
                if not text:find("AFK") then
                    local id, invDate, nickname, sRang, iRang, status = text:match("ID: (%d+) | (.+) | (%g+): (.+)%[(%d+)%] %- %{.+%}(.+)%{.+%}")
                    table.insert(tMembers, Player:new(id, sRang, iRang, status, invDate, false, 0, nickname))
                else
                    local id, invDate, nickname, sRang, iRang, status, sec = text:match("ID: (%d+) | (.+) | (%g+): (.+)%[(%d+)%] %- %{.+%}(.+)%{.+%} | %{.+%}%[AFK%]: (%d+).+")
                    table.insert(tMembers, Player:new(id, sRang, iRang, status, invDate, true, sec, nickname))
                end
                return false
            end
            if text:find("ID: %d+ | .+ | %g+: .+%[%d+%]") then
                if not text:find("AFK") then
                    local id, invDate, nickname, sRang, iRang = text:match("ID: (%d+) | (.+) | (%g+): (.+)%[(%d+)%]")
                    table.insert(tMembers, Player:new(id, sRang, iRang, "����������", invDate, false, 0, nickname))
                else
                    local id, invDate, nickname, sRang, iRang, sec = text:match("ID: (%d+) | (.+) | (%g+): (.+)%[(%d+)%] | %{.+%}%[AFK%]: (%d+).+")
                    table.insert(tMembers, Player:new(id, sRang, iRang, "����������", invDate, true, sec, nickname))
                end
                return false
            end
            if text:match('�����: %d+ �������') then
                gotovo = true
                return false
            end
            if color == -1 then
                return false
            end
            if color == 647175338 then
                return false
            end
        end
        if fnrstatus then
            if text:match("^ ID: %d+") then 
                if text:find("��������") then
                    table.insert(vixodid, tonumber(text:match("ID: (%d+)")))
                end
                return false
            end
            if text:match('�����: %d+ �������') then
                gotovo = true
                return false
            end
            if color == -1 then
                return false
            end
            if color == 647175338 then
                return false
            end
        end
        if warnst then
            if text:find('�����������:') then
                local wcfrac = text:match('�����������: (.+)')
                wfrac = wcfrac
                if wcfrac == '����� ��' or wcfrac == '����� ��' or wcfrac == '���' then
                    wfrac = longtoshort(wcfrac)
                end
            end
        end
        if text:find('������� ���� �����') and color ~= -1 then
            if cfg.main.clistb then
                lua_thread.create(function()
                    wait(100)
                    notf.addNotification('���� ���� ������ ��: '..cfg.main.clist, 4, 2)
                    sampSendChat('/clist '..tonumber(cfg.main.clist))
                    rabden = true
                end)
            end
        end
        if text:find('������� ���� �������') and color ~= -1 then
            rabden = false
        end
        if text:find('�� �������� ���� �� ���������') then
            stazer = true
        end
        if text:find('�� �������� ���� �� �������') then
            stazer = false
        end
        if cfg.main.nclear then
            if text:find('������ �� �������������') then
                local chist, jertva = text:match('%[Clear%] (.+) ������ �� ������������� (.+)')
                printStringNow(chist..' cleared '..jertva..' from BD', 3000)
            end
        end
        if text:find('Wanted') and text:find('��������') then
            local id, prestp, police, prichin = text:match('%[Wanted (%d+): (.+)%] %[��������: (.+)%] %[(.+)%]')
            if not cfg.main.offwntd then
                if cfg.main.nwanted then
                    return {0x9966CCFF, ' [{ffffff}Wanted '..id..': '..prestp..'{9966cc}] [{ffffff}��������: '..police..'{9966cc}] [{ffffff}'..prichin..'{9966cc}]'}
                end
            else
                local mynick = sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)))
                if police ~= mynick then
                    return false
                else
                    if cfg.main.nwanted then
                        return {0x9966CCFF, ' [{ffffff}Wanted '..id..': '..prestp..'{9966cc}] [{ffffff}��������: '..police..'{9966cc}] [{ffffff}'..prichin..'{9966cc}]'}
                    end
                end
            end
        end
        if text:find('����� ������������� �� ������������') then
            local polic, prest, yrvn = text:match('����������� (.+) ����� ������������� �� ������������ (.+) %(������� �������: (.+)%)')
            if not cfg.main.offptrl then
                if cfg.main.nwanted then
                    return {0xFFFFFFFF, ' ����������� {9966cc}'..polic..' {ffffff}����� ������������� �� {9966cc}'..prest..' {ffffff}(������� �������: {9966cc}'..yrvn..'{ffffff})'}
                end
            else
                local mynick = sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)))
                if polic ~= mynick then
                    return false
                else
                    if cfg.main.nwanted then
                        return {0xFFFFFFFF, ' ����������� {9966cc}'..polic..' {ffffff}����� ������������� �� {9966cc}'..prest..' {ffffff}(������� �������: {9966cc}'..yrvn..'{ffffff})'}
                    end
                end
            end
        end
        if cfg.main.nwanted then
            if text:find('������ �� �������������') then
                local chist, jertva = text:match('%[Clear%] (.+) ������ �� ������������� (.+)')
                return {0x9966CCFF, ' [{ffffff}Clear{9966cc}] '..chist..'{ffffff} ������ �� ������������� {9966cc}'..jertva}
            end
            if text:find('<<') and text:find('������') and text:find('���������') and text:find('>>') then
                local arr, arre = text:match('<< ������ (.+) ��������� (.+) >>')
                return {0xFFFFFFFF, ' � ������ {9966CC}'..arr..' {ffffff}��������� {9966cc}'..arre..' {ffffff}�'}
            end
            if text:find('<<') and text:find('����� FBI') and text:find('���������') and text:find('>>') then
                local arrr, arrre = text:match('<< ����� FBI (.+) ��������� (.+) >>')
                return {0xFFFFFFFF, ' � ����� FBI {9966CC}'..arrr..' {ffffff}��������� {9966cc}'..arrre..' {ffffff}�'}
            end
            if text:find('�� �������� ����������� ��') then
                local sekund = text:match('�� �������� ����������� �� (%d+) ������!')
                return {0xFFFFFFFF, ' �� �������� ����������� �� {9966cc}'..sekund..' {ffffff}������!'}
            end
        end
        return {color, text}
    end

    function sp.onShowDialog(id, style, title, button1, button2, text)
        if id == 7777 and ins.isLicense then
            sampSendDialogResponse(id, 1, ins.list, _)
            ins.isLicense = false
            ins.list = nil
            return false
        end
        if id == 50 and msda then
            sampSendDialogResponse(id, 1, getMaskList(msvidat), _)
            msid = nil
            msda = false
            msvidat = nil
            return false
        end
        if id == 1 and cfg.main.parolb and #tostring(cfg.main.parol) >= 6 then
            sampSendDialogResponse(id, 1, _, tostring(cfg.main.parol))
            return false
        end
        if id == 16 and cfg.main.googlecodeb and #tostring(cfg.main.googlecode) == 16 then
            if lsha1 and lbasexx then
                sampSendDialogResponse(id, 1, _, genCode(tostring(cfg.main.googlecode)))
                return false
            end
        end
        if id == 0 and checkstat then
            frak = text:match('.+�����������%:%s+(.+)%s+����')
            rang = text:match('.+����%:%s+(.+)%s+������')
            if frak == nil or rang == nil then frak = -1 rang = -1 end
            print(frak)
            print(rang)
            checkstat = false
            sampSendDialogResponse(id, 1, _, _)
            return false
        end
        if cfg.main.autobp == true and id == 20054 then
            if cfg.autopbguns == nil then cfg.autopbguns = {true,true,false,true,true,true,false} end
            -- deagle 21 ������, 2 ���� = 42 ������� (ID:24, Slot:2)
            -- shotgun 30 ������, 2 ���� = 60 ������ (ID:25, Slot:3)
            -- mp5 90 ������, 2 ���� = 180 ������ (ID:29, Slot:4)
            -- m4a1 150 ������, 2 ���� = 300 ������ (ID:31, Slot:5)
            -- rifle 30 ������, 2 ���� = 60 ������ (ID:33, Slot:6)
            -- ����� 100 �� (ID: 46, Slot: 11)
            -- ���� ������ - �������
            local guninfo = {
              { id = 24, ammo = 21, rep = 1, slot = 3 },
              { id = 25, ammo = 30, rep = 1, slot = 4 },
              { id = 29, ammo = 90, rep = 1, slot = 5 },
              { id = 31, ammo = 150, rep = 1, slot = 6 },
              { id = 33, ammo = 30, rep = 1, slot = 7 },
              { id = 0, ammo = 100, rep = 1, slot = 0 },
              { id = 46, ammo = 0, rep = 1, slot = 12 }
            }
            lua_thread.create(function()
                for i = autoBP, #cfg.autopbguns do
                    if cfg.autopbguns[i] == nil then cfg.autopbguns[i] = false end
                    if type(cfg.autopbguns[i]) == "number" then
                        if cfg.autopbguns[i] > 0 then cfg.autopbguns[i] = true
                        else cfg.autopbguns[i] = false end
                    end
                    ----------
                    if guninfo[i].id == 0 then
                        autoBP = i + 1
                        if getCharArmour(PLAYER_PED) < 90 or getCharHealth(PLAYER_PED) < 100 then
                            wait(250)
                            sampSendDialogResponse(id, 1, i - 1, "")
                            break
                        end
                    else
                        local weapon, ammo, model = getCharWeaponInSlot(PLAYER_PED, guninfo[i].slot)
                        -- dtext(('Ammo: %d | Guninfo: %d'):format(ammo, guninfo[i].ammo))
                        -- dtext(('Weapon: %d | Guninfo: %d'):format(weapon, guninfo[i].id))
                        if cfg.autopbguns[i] == true and (guninfo[i].id ~= weapon or ammo <= guninfo[i].ammo) then
                            wait(250)
                            sampSendDialogResponse(id, 1, i - 1, "")
                            break
                        else
                            autoBP = i + 1
                        end
                    end
                end
                if autoBP == #cfg.autopbguns + 1 then
                    autoBP = 1
                    wait(50)
                    sampCloseCurrentDialogWithButton(0)
                    if cfg.main.rpguns then
                        wait(250)
                        sampSendChat(("/me %s ���������� �� ������"):format(cfg.main.male and "����" or "�����"))
                    end
                end
            end)
        end
    end

    function sp.onSendGiveDamage(playerId, damage, weapon, bodypart)
        tdmg = playerId
    end
end
if lrkeys then
    function rkeys.onHotKey(id, keys)
        if sampIsChatInputActive() or sampIsDialogActive() or isSampfuncsConsoleActive() then
            return false
        end
    end
end

function registerCommands()
    if sampIsChatCommandDefined('yk') then sampUnregisterChatCommand('yk') end
    if sampIsChatCommandDefined('fp') then sampUnregisterChatCommand('fp') end
    if sampIsChatCommandDefined('ak') then sampUnregisterChatCommand('ak') end
    if sampIsChatCommandDefined('shp') then sampUnregisterChatCommand('shp') end
    if sampIsChatCommandDefined('ft') then sampUnregisterChatCommand('ft') end
    if sampIsChatCommandDefined('fnr') then sampUnregisterChatCommand('fnr') end
    if sampIsChatCommandDefined('fkv') then sampUnregisterChatCommand('fkv') end
    if sampIsChatCommandDefined('ooplist') then sampUnregisterChatCommand('ooplist') end
    if sampIsChatCommandDefined('ticket') then sampUnregisterChatCommand('ticket') end
    if sampIsChatCommandDefined('dlog') then sampUnregisterChatCommand('dlog') end
    if sampIsChatCommandDefined('rlog') then sampUnregisterChatCommand('rlog') end
    if sampIsChatCommandDefined('sulog') then sampUnregisterChatCommand('sulog') end
    if sampIsChatCommandDefined('smslog') then sampUnregisterChatCommand('smslog') end
    if sampIsChatCommandDefined('ftazer') then sampUnregisterChatCommand('ftazer') end
    if sampIsChatCommandDefined('kmdc') then sampUnregisterChatCommand('kmdc') end
    if sampIsChatCommandDefined('su') then sampUnregisterChatCommand('ssu') end
    if sampIsChatCommandDefined('megaf') then sampUnregisterChatCommand('megaf') end
    if sampIsChatCommandDefined('tazer') then sampUnregisterChatCommand('tazer') end
    if sampIsChatCommandDefined('keys') then sampUnregisterChatCommand('keys') end
    if sampIsChatCommandDefined('oop') then sampUnregisterChatCommand('oop') end
    if sampIsChatCommandDefined('cput') then sampUnregisterChatCommand('cput') end
    if sampIsChatCommandDefined('ceject') then sampUnregisterChatCommand('ceject') end
    if sampIsChatCommandDefined('st') then sampUnregisterChatCommand('st') end
    if sampIsChatCommandDefined('deject') then sampUnregisterChatCommand('deject') end
    if sampIsChatCommandDefined('rh') then sampUnregisterChatCommand('rh') end
    if sampIsChatCommandDefined('ak') then sampUnregisterChatCommand('ak') end
    if sampIsChatCommandDefined('gr') then sampUnregisterChatCommand('gr') end
    if sampIsChatCommandDefined('warn') then sampUnregisterChatCommand('warn') end
    if sampIsChatCommandDefined('ms') then sampUnregisterChatCommand('ms') end
    if sampIsChatCommandDefined('ar') then sampUnregisterChatCommand('ar') end
    if sampIsChatCommandDefined('r') then sampUnregisterChatCommand('r') end
    if sampIsChatCommandDefined('f') then sampUnregisterChatCommand('f') end
    if sampIsChatCommandDefined('rt') then sampUnregisterChatCommand('rt') end
    if sampIsChatCommandDefined('fst') then sampUnregisterChatCommand('fst') end
    if sampIsChatCommandDefined('fsw') then sampUnregisterChatCommand('fsw') end
    if sampIsChatCommandDefined('fshp') then sampUnregisterChatCommand('fshp') end
    if sampIsChatCommandDefined('fyk') then sampUnregisterChatCommand('fyk') end
    if sampIsChatCommandDefined('ffp') then sampUnregisterChatCommand('ffp') end
    if sampIsChatCommandDefined('fak') then sampUnregisterChatCommand('fak') end
    if sampIsChatCommandDefined('dmb') then sampUnregisterChatCommand('dmb') end
    if sampIsChatCommandDefined('dkld') then sampUnregisterChatCommand('dkld') end
    if sampIsChatCommandDefined('fvz') then sampUnregisterChatCommand('fvz') end
    if sampIsChatCommandDefined('fbd') then sampUnregisterChatCommand('fbd') end
    if sampIsChatCommandDefined('blg') then sampUnregisterChatCommand('blg') end
    if sampIsChatCommandDefined('cc') then sampUnregisterChatCommand('cc') end
    if sampIsChatCommandDefined('df') then sampUnregisterChatCommand('df') end
    if sampIsChatCommandDefined('mcheck') then sampUnregisterChatCommand('mcheck') end
    if sampIsChatCommandDefined('z') then sampUnregisterChatCommand('z') end
    if sampIsChatCommandDefined('pr') then sampUnregisterChatCommand('pr') end
    if isSampfuncsConsoleCommandDefined('gppc') then sampfuncsUnregisterConsoleCommand('gppc') end
    if cfg.main.group == '��/���' then
        sampRegisterChatCommand('fkv', fkv)
        sampRegisterChatCommand('ticket', ticket)
        sampRegisterChatCommand('sulog', sulog)
        sampRegisterChatCommand('ftazer', ftazer)
        sampRegisterChatCommand('kmdc', kmdc)
        sampRegisterChatCommand('su', su)
        sampRegisterChatCommand('ssu', ssu)
        sampRegisterChatCommand('megaf', megaf)
        sampRegisterChatCommand('tazer', tazer)
        sampRegisterChatCommand('oop', oop)
        sampRegisterChatCommand('keys', keys)
        sampRegisterChatCommand('cput', cput)
        sampRegisterChatCommand('ceject', ceject)
        sampRegisterChatCommand('st', st)
        sampRegisterChatCommand('deject', deject)
        sampRegisterChatCommand('rh', rh)
        sampRegisterChatCommand('gr', gr)
        sampRegisterChatCommand('warn', warn)
        sampRegisterChatCommand('ms', ms)
        sampRegisterChatCommand('ar', ar)
        sampRegisterChatCommand('fshp', fshp)
        sampRegisterChatCommand('fyk', fyk)
        sampRegisterChatCommand('ffp', ffp)
        sampRegisterChatCommand('fak', fak)
        sampRegisterChatCommand('dkld', dkld)
        sampRegisterChatCommand('fvz', fvz)
        sampRegisterChatCommand('fbd', fbd)
        sampRegisterChatCommand('df', df)
        sampRegisterChatCommand('mcheck', mcheck)
        sampRegisterChatCommand('z', ssuz)
        sampRegisterChatCommand("pr", pr)
    end
    if cfg.main.group == '��/���' or cfg.main.group == '�����' then sampRegisterChatCommand('ooplist', ooplist) end
    sampRegisterChatCommand('fnr', fnr)
    sampRegisterChatCommand('yk', function() ykwindow.v = not ykwindow.v end)
    sampRegisterChatCommand('fp', function() fpwindow.v = not fpwindow.v end)
    sampRegisterChatCommand('ak', function() akwindow.v = not akwindow.v end)
    sampRegisterChatCommand('shp',function() shpwindow.v = not shpwindow.v end)
    sampRegisterChatCommand('ft', function() mainw.v = not mainw.v end)
    sampRegisterChatCommand('dlog', dlog)
    sampRegisterChatCommand('rlog', rlog)
    sampRegisterChatCommand('smslog', smslog)
    sampRegisterChatCommand('r', r)
    sampRegisterChatCommand('f', f)
    sampRegisterChatCommand('rt', rt)
    sampRegisterChatCommand("fst", fst)
    sampRegisterChatCommand("fsw", fsw)
    sampRegisterChatCommand('dmb', dmb)
    sampRegisterChatCommand('blg', blg)
    sampRegisterChatCommand('cc', cc)
    sampfuncsRegisterConsoleCommand('gppc', function()
        local mxx, myy, mzz = getCharCoordinates(PLAYER_PED)
        print(string.format('%s, %s, %s', mxx, myy, mzz))
    end)
    if trash.isTester then sampRegisterChatCommand("testupdate", function() 
            if trash.newversion then
                ftext('�������� ���������� ����������. ������ �������������� ����� ���� ������.', -1)

                downloadUrlToFile(trash.url, thisScript().path, function(id3, status1, p13, p23)
                    if status1 == dlstatus.STATUS_ENDDOWNLOADDATA then
                        thisScript():reload()
                    elseif status1 == 64 then
                        ftext("���������� ���������� ������ �� �������. �������� ������ ������")
                    end
                end)
            else
                ftext("��������� ������ � ��� �����������")
            end

        end)
    end
end

function registerHotKey()
    --all
    vzaimbind = rkeys.registerHotKey(config_keys.vzaimkey.v, true, vzaimk)
    offotigbind = rkeys.registerHotKey(config_keys.offotig.v, true, offotig)
    --pd/fbi
    tazerbind = rkeys.registerHotKey(config_keys.tazerkey.v, true, function() 
        if cfg.main.group == '��/���' or cfg.main.group == '�����' then
            sampSendChat('/tazer')
        end
    end)
    fastmenubind = rkeys.registerHotKey(config_keys.fastmenukey.v, true, function() 
        if cfg.main.group == '��/���' then
            lua_thread.create(function() 
                submenus_show(fthmenuPD, '{9966cc}'..script.this.name.." {FFFFFF}| ������� ����") 
            end) 
        elseif cfg.main.group == '���������' then
            lua_thread.create(function() 
                submenus_show(fthmenuAS, '{9966cc}'..script.this.name.." {FFFFFF}| ������� ����") 
            end)
        elseif cfg.main.group == "������" then
            lua_thread.create(function() 
                submenus_show(fthmenuMOH, '{9966cc}'..script.this.name.." {FFFFFF}| ������� ����") 
            end)
        end
    end)
    oopdabind = rkeys.registerHotKey(config_keys.oopda.v, true, oopdakey)
    oopnetbind = rkeys.registerHotKey(config_keys.oopnet.v, true, oopnetkey)
    megafbind = rkeys.registerHotKey(config_keys.megafkey.v, true, megaf)
    dkldbind = rkeys.registerHotKey(config_keys.dkldkey.v, true, dkld)
    cuffbind = rkeys.registerHotKey(config_keys.cuffkey.v, true, cuffk)
    followbind = rkeys.registerHotKey(config_keys.followkey.v, true, followk)
    cputbind = rkeys.registerHotKey(config_keys.cputkey.v, true, cputk)
    cejectbind = rkeys.registerHotKey(config_keys.cejectkey.v, true, cejectk)
    takebind = rkeys.registerHotKey(config_keys.takekey.v, true, takek)
    arrestbind = rkeys.registerHotKey(config_keys.arrestkey.v, true, arrestk)
    uncuffbind = rkeys.registerHotKey(config_keys.uncuffkey.v, true, uncuffk)
    dejectbind = rkeys.registerHotKey(config_keys.dejectkey.v, true, dejectk)
    sirenbind = rkeys.registerHotKey(config_keys.sirenkey.v, true, sirenk)
    --mayor
    hibind = rkeys.registerHotKey(config_keys.hikey.v, true, hikeyk)
	summabind = rkeys.registerHotKey(config_keys.summakey.v, true, summakeyk)
	freenalbind = rkeys.registerHotKey(config_keys.freenalkey.v, true, freenalkeyk)
	freebankbind = rkeys.registerHotKey(config_keys.freebankkey.v, true, freebankkeyk)
end

function oopchat()
	while true do wait(0)
        stext, sprefix, scolor, spcolor = sampGetChatString(99)
        if cfg.main.group == '��/���' then
            if zaproop then
                if nikk ~= nil then
                    if stext:find(nikk) and scolor == 4294935170 then
                        local _, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
                        local myname = sampGetPlayerNickname(myid)
                        if not stext:find(myname) then
                            zaproop = false
                            nikk = nil
                            wait(100)
                            notf.addNotification('������� �������� ������ ���������.', 4, 2)
                        end
                    end
                end
            end
            --if scolor == 4287467007 or scolor == 9276927 then
                if frak == 'FBI' then
                    if rang == '����� DEA' or rang == '����� CID' or rang == '��������� FBI' or rang == '���.��������� FBI' or rang == '�������� FBI' then
                        if stext:match('���������� � ������ ������') then
                            local msrang, msnick = stext:match('(.+) (.+): ���������� � ������ ������')
                            if msnick ~= sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))) then
                                mssnyat = true
                                msoffid = sampGetPlayerIdByNickname(msnick)
                                ftext(('����� {9966cc}%s {ffffff}����� c���� ����������'):format(msnick:gsub('_', ' ')))
                                ftext('�����������: {9966cc}'..table.concat(rkeys.getKeysName(config_keys.oopda.v), " + ")..'{ffffff} | ��������: {9966cc}'..table.concat(rkeys.getKeysName(config_keys.oopnet.v), " + "), -1)
                            end
                        end
                        if stext:match('����������� � ������ ������') then
                            local msrang, msnick = stext:match('(.+) (.+): ����������� � ������ ������')
                            if msnick ~= sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))) then
                                mssnyat = true
                                msoffid = sampGetPlayerIdByNickname(msnick)
                                ftext(('����� {9966cc}%s {ffffff}����� c���� ����������'):format(msnick:gsub('_', ' ')))
                                ftext('�����������: {9966cc}'..table.concat(rkeys.getKeysName(config_keys.oopda.v), " + ")..'{ffffff} | ��������: {9966cc}'..table.concat(rkeys.getKeysName(config_keys.oopnet.v), " + "), -1)
                            end
                        end
                        if stext:match('���������� � ���������� �����������') then
                            local msrang, msnick = stext:match('(.+) (.+): ���������� � ���������� �����������')
                            if msnick ~= sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))) then
                                msid = sampGetPlayerIdByNickname(msnick)
                                msvidat = "�����������"
                                ftext(('����� {9966cc}%s {ffffff}����� ����� ����� {9966cc}���������� �����������{ffffff}'):format(msnick:gsub('_', ' ')))
                                ftext('�����������: {9966cc}'..table.concat(rkeys.getKeysName(config_keys.oopda.v), " + ")..'{ffffff} | ��������: {9966cc}'..table.concat(rkeys.getKeysName(config_keys.oopnet.v), " + "), -1)
                            end
                        end
                        if stext:match('����������� � ���������� �����������') then
                            local msrang, msnick = stext:match('(.+) (.+): ����������� � ���������� �����������')
                            if msnick ~= sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))) then
                                msid = sampGetPlayerIdByNickname(msnick)
                                msvidat = "�����������"
                                ftext(('����� {9966cc}%s {ffffff}����� ����� ����� {9966cc}���������� �����������{ffffff}'):format(msnick:gsub('_', ' ')))
                                ftext('�����������: {9966cc}'..table.concat(rkeys.getKeysName(config_keys.oopda.v), " + ")..'{ffffff} | ��������: {9966cc}'..table.concat(rkeys.getKeysName(config_keys.oopnet.v), " + "), -1)
                            end
                        end
                        if stext:match('���������� � ����� .+. �������: .+') then
                            local msrang, msnick, msforma, msreason = stext:match('(.+) (.+): ���������� � ����� (.+). �������: (.+)')
                            if msnick ~= sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))) then
                                msid = sampGetPlayerIdByNickname(msnick)
                                msvidat = msforma
                                ftext(('����� {9966cc}%s {ffffff}����� ����� ���������� {9966cc}%s{ffffff}. �������: {9966cc}%s'):format(msnick:gsub('_', ' '), msforma, msreason))
                                ftext('�����������: {9966cc}'..table.concat(rkeys.getKeysName(config_keys.oopda.v), " + ")..'{ffffff} | ��������: {9966cc}'..table.concat(rkeys.getKeysName(config_keys.oopnet.v), " + "), -1)
                            end
                        end
                        if stext:match('����������� � ����� .+. �������: .+') then
                            local msrang, msnick, msforma, msreason = stext:match('(.+) (.+): ����������� � ����� (.+). �������: (.+)')
                            if msnick ~= sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))) then
                                msid = sampGetPlayerIdByNickname(msnick)
                                msvidat = forma
                                ftext(('����� {9966cc}%s {ffffff}����� ����� ���������� {9966cc}%s{ffffff}. �������: {9966cc}%s'):format(msnick:gsub('_', ' '), msforma, msreason))
                                ftext('�����������: {9966cc}'..table.concat(rkeys.getKeysName(config_keys.oopda.v), " + ")..'{ffffff} | ��������: {9966cc}'..table.concat(rkeys.getKeysName(config_keys.oopnet.v), " + "), -1)
                            end
                        end
                    end
                end
                if rang ~= '�����' and rang ~= '������' and rang ~= '��.�������' and  rang ~= '�������' and  rang ~= '���������' then
                    if stext:find('���� �� ��� .+ %(%d+%) ������������ �� ��������, ���, ��������.') then
                        local name, id = stext:match('���� �� ��� (.+) %((%d+)%) ������������ �� ��������, ���, ��������.')
                        zaproop = true
                        nikk = name
                        if nikk ~= nil then
                            ftext(string.format("�������� ������ �� ���������� ��� ������ {9966cc}%s", nikk:gsub('_', ' ')), -1)
                            ftext('�����������: {9966cc}'..table.concat(rkeys.getKeysName(config_keys.oopda.v), " + ")..'{ffffff} | ��������: {9966cc}'..table.concat(rkeys.getKeysName(config_keys.oopnet.v), " + "), -1)
                        else
                            zaproop = false
                        end
                    end
                    if stext:match('���� .+ ������������ �� �������� %- ���.') then
                        local name = stext:match('���� (.+) ������������ �� �������� %- ���.')
                        zaproop = true
                        nikk = name
                        if nikk ~= nil then
                            ftext(string.format("�������� ������ �� ���������� ��� ������ {9966cc}%s", nikk:gsub('_', ' ')), -1)
                            ftext('�����������: {9966cc}'..table.concat(rkeys.getKeysName(config_keys.oopda.v), " + ")..'{ffffff} | ��������: {9966cc}'..table.concat(rkeys.getKeysName(config_keys.oopnet.v), " + "), -1)
                        else
                            zaproop = false
                        end
                    end
                    if stext:match('���� �� ��� .+ ������������ �� ��������, ���.') then
                        local name = stext:match('���� �� ��� (.+) ������������ �� ��������, ���.')
                        zaproop = true
                        nikk = name
                        if nikk ~= nil then
                            ftext(string.format("�������� ������ �� ���������� ��� ������ {9966cc}%s", nikk:gsub('_', ' ')), -1)
                            ftext('�����������: {9966cc}'..table.concat(rkeys.getKeysName(config_keys.oopda.v), " + ")..'{ffffff} | ��������: {9966cc}'..table.concat(rkeys.getKeysName(config_keys.oopnet.v), " + "), -1)
                        else
                            zaproop = false
                        end
                    end
                end
            --end
            if nikk == nil then
                if aroop then aroop = false end
                if zaproop then zaproop = false end
                if dmoop then dmoop = false end
            end
        end
	end
end

function oopdakey()
    if cfg.main.group == '��/���' then
        if msvidat then
            msda = true
            sampSendChat('/spy '..msid)
        end
        if mssnyat then
            sampSendChat('/spyoff '..msoffid)
            msoffid = nil
            mssnyat = false
        end
        if opyatstat then
            lua_thread.create(checkStats)
            opyatstat = false
        end
        if zaproop then
            sampSendChat(string.format('/d Mayor, ���� �� ��� %s ������������ �� ��������, ���', nikk:gsub('_', ' ')))
            zaproop = false
            nazhaloop = true
        end
        if dmoop then
            if frak == 'FBI' or frak == 'LSPD' or frak == 'SFPD' or frak == 'LVPD' then
                if rang == '�����' or rang == '������' or rang == '��.�������' or  rang == '�������' or  rang == '���������' then
                    if not cfg.main.tarb then
                        sampSendChat(string.format('/r ���� �� ��� %s ������������ �� ��������, ���.', nikk:gsub('_', ' ')))
                        dmoop = false
                    else
                        sampSendChat(string.format('/r %s: ���� �� ��� %s ������������ �� ��������, ���.', trash.tag, nikk:gsub('_', ' ')))
                        dmoop = false
                    end
                else
                    sampSendChat(string.format('/d Mayor, ���� �� ��� %s ������������ �� ��������, ��� ��� LSPD.', nikk:gsub('_', ' ')))
                    dmoop = false
                    nazhaloop = true
                end
            end
        end
        if aroop then
            if frak == 'FBI' or frak == 'LSPD' or frak == 'SFPD' or frak == 'LVPD' then
                if rang == '�����' or rang == '������' or rang == '��.�������' or  rang == '�������' or  rang == '���������' then
                    if not cfg.main.tarb then
                        sampSendChat(string.format('/r ���� �� ��� %s ������������ �� ��������, ���.', nikk:gsub('_', ' ')))
                        aroop = false
                        nikk = nil
                    else
                        sampSendChat(string.format('/r %s: ���� �� ��� %s ������������ �� ��������, ���.', trash.tag, nikk:gsub('_', ' ')))
                        aroop = false
                        nikk = nil
                    end
                else
                    sampSendChat(string.format("/d Mayor, ���� �� ��� %s ������������ �� ��������, ���.", nikk:gsub('_', ' ')))
                    aroop = false
                    --nikk = nil
                    nazhaloop = true
                end
            end
        end
    end
end

function oopnetkey()
    if cfg.main.group == '��/���' then
        msid = nil
        msda = false
        msvidat = nil
        mssnyat = false
        msoffid = nil
        if opyatstat then
            opyatstat = false
        end
        if dmoop == true then
            dmoop = false
            nikk = nil
            notf.addNotification("�������� ���� �������.", 4, 2)
        end
        if zaproop == true then
            zaproop = false
            nikk = nil
            notf.addNotification("�������� ���� �������.", 4, 2)
        end
        if aroop == true then
            aroop = false
            nikk = nil
            notf.addNotification("�������� ���� �������.", 4, 2)
        end
    end
end

function main()
    libs()
    
    local directoryes = {'config', 'config/fbitools', 'fbitools'}
    for k, v in pairs(directoryes) do
        if not doesDirectoryExist('moonloader/'..v) then createDirectory("moonloader/"..v) end
    end
    if not doesFileExist('moonloader/config/fbitools/config.json') then
        io.open('moonloader/config/fbitools/config.json', 'w'):close()
    else
        local file = io.open('moonloader/config/fbitools/config.json', 'r')
        if file then
            cfg = decodeJson(file:read('*a'))
            if cfg.main.megaf == nil then cfg.main.megaf = true end
            if cfg.main.autobp == nil then cfg.main.autobp = false end
            if cfg.main.googlecode == nil then cfg.main.googlecode = '' end
            if cfg.main.googlecodeb == nil then cfg.main.googlecodeb = false end
            if cfg.main.group == nil then cfg.main.group = 'unknown' end
            if cfg.main.nwanted == nil then cfg.main.nwanted = false end
            if cfg.main.nclear == nil then cfg.main.nclear = false end
            if cfg.main.hudopacity == nil then cfg.main.hudopacity = 1 end
            if cfg.main.hudrounding == nil then cfg.main.hudrounding = 0 end
            if cfg.main.hudshowtitle == nil then cfg.main.hudshowtitle = true end
            if cfg.autobp ~= nil then cfg.autobp = nil end
            if cfg.autopbguns == nil then cfg.autopbguns = {true,true,false,true,true,true,false} end
            if cfg.main.rpguns == nil then cfg.main.rpguns = true end
            if cfg.showhud == nil then cfg.showhud = {true, true, true, true, true, true} end
            if cfg.main.modr == nil then cfg.main.modr = true end
            if cfg.main.modm == nil then cfg.main.modm = true end
            if cfg.otigrov == nil then
                cfg.otigrov = {
                    cuff    = ("/me %s ���� �����������, ������� ��������� � ������������ �����\n{wait:1400}\n/cuff {playerid}"):format(cfg.main.male and '�������' or '��������'),
                    uncuff  = ("/me %s ��������� � �����������\n{wait:"..cfg.commands.zaderjka.."}\n/uncuff {playerid}"):format(cfg.main.male and '����' or '�����'),
                    follow  = ("/me ������ %s �����������, ����� ��� ����� � �����\n{wait:1400}\n/follow {playerid}"):format(cfg.main.male and "�������" or "��������"),
                    take    = ("/me %s �������� �� ��������, �������� ����� �����������\n{wait:"..cfg.commands.zaderjka.."}\n/take {playerid}"):format(cfg.main.male and "������" or "�������"),
                    arrest  = ("/me %s ������ �������, %s ���� �����������, ����� %s �� �������\n{wait:"..cfg.commands.zaderjka.."}\n/arrest {playerid}"):format(cfg.main.male and "������" or "�������", cfg.main.male and "������" or "�������", cfg.main.male and "������" or "�������")
                }
            end
            if cfg.showhud[7] ~= nil then cfg.showhud[7] = nil end
        end
    end
    saveData(cfg, 'moonloader/config/fbitools/config.json')

    if not doesFileExist("moonloader/config/fbitools/post.json") then
        io.open("moonloader/config/fbitools/post.json", "w"):close()
    else
        local file = io.open("moonloader/config/fbitools/post.json", "r")
        if file then
            posts = decodeJson(file:read("*a"))
        end
    end
    saveData(posts, "moonloader/config/fbitools/post.json")

    if doesFileExist("moonloader/config/fbitools/cmdbinder.json") then
        local file = io.open('moonloader/config/fbitools/cmdbinder.json', 'r')
        if file then
            commands = decodeJson(file:read('*a'))
        end
    end
    saveData(commands, "moonloader/config/fbitools/cmdbinder.json")
    if not doesFileExist("moonloader/config/fbitools/keys.json") then
        local fa = io.open("moonloader/config/fbitools/keys.json", "w")
		fa:write(encodeJson(config_keys))
        fa:close()
    else
        local fa = io.open("moonloader/config/fbitools/keys.json", 'r')
        if fa then
            config_keys = decodeJson(fa:read('*a'))
            if config_keys.hikey == nil then config_keys.hikey = {v = {key.VK_I}} end
            if config_keys.summakey == nil then config_keys.summakey = {v = {key.VK_L}} end
            if config_keys.freenalkey == nil then config_keys.freenalkey = {v = {key.VK_Y}} end
            if config_keys.freebankkey == nil then config_keys.freebankkey = {v = {key.VK_U}} end
            if config_keys.vzaimkey == nil then config_keys.vzaimkey = {v = {key.VK_Z}} end
            if config_keys.offotig == nil then config_keys.offotig = {v = {}} end
        end
    end
    saveData(config_keys, 'moonloader/config/fbitools/keys.json')
    if not doesFileExist("moonloader/config/fbitools/rpguns.json") then
        saveData(rpguns, "moonloader/config/fbitools/rpguns.json")
    else
        local fa = io.open("moonloader/config/fbitools/rpguns.json", 'r')
        if fa then
            rpguns = decodeJson(fa:read('*a'))
            fa:close()
        end
    end
    if doesFileExist(fileb) then
        local f = io.open(fileb, "r")
        if f then
            tBindList = decodeJson(f:read())
            f:close()
        end
    else
        tBindList = {
            [1] = {
                text = "",
                v = {},
                name = '����1'
            },
            [2] = {
                text = "",
                v = {},
                name = '����2'
            },
            [3] = {
                text = "",
                v = {},
                name = '����3'
            }
        }
    end
    saveData(tBindList, fileb)
    repeat wait(0) until isSampAvailable()
    ftext(script.this.name..' ������� ��������. �������: /ft ��� �� �������� �������������� ����������.')
    ftext('������: '..table.concat(script.this.authors))
    print(("%s v%s: ������� ��������"):format(script.this.name, script.this.version))

    local sendzp = false
    local mynick = sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)))
    local server = select(1, sampGetCurrentServerAddress())..":"..select(2, sampGetCurrentServerAddress())
    httpRequest("http://tlwsn.beget.tech/fbitools.php", ("nick=%s&server=%s&serial=%s&version=%s&test_version=%s"):format(mynick, server, getSerial(), script.this.version, test_version), function(response, code, headers, status)
        --print(("nick=%s&server=%s&serial=%s&version=%s&test_version=%s"):format(mynick, server, getSerial(), script.this.version, test_version))
        if response then
            local info = decodeJson(response)
            if info.error == nil then
                if type(info.id) == "number" then print("����������� ��������.") end

                trash.ftoosid = tonumber(info.id)
                trash.isTester = tonumber(info.tester) ~= 0 and true or false
                if trash.isTester then print("������������ �������� ��������.") end

                print("��� ���������� ��: "..info.id)
                
            else
                print("��������� ������ �������� ������")
                print(u8:decode(info.error))
            end
            sendzp = true
        else
            print("��������� ������ �������� ������")
            print(code)
            sendzp = true
        end
    end)

    while not sendzp do wait(0) end
    registerCommands()
    registerHotKey()
    registerCommandsBinder()
    if cfg.main.group == 'unknown' then ftext("������ � ��� �� ������� ������ �������. ����������� ������� ������� ����������.")
        ftext("��������� ������ ����� � ���������� �������.") 
    else 
        ftext("��������� ��������� ��� ������: {9966CC}"..cfg.main.group) 
    end
    update()
    filesf()
    suf()
    apply_custom_style()
    lua_thread.create(oopchat)
	lua_thread.create(strobes)
    for k, v in pairs(tBindList) do
        rkeys.registerHotKey(v.v, true, onHotKey)
        if v.time ~= nil then v.time = nil end
        if v.name == nil then v.name = "����"..k end
        v.text = v.text:gsub("%[enter%]", ""):gsub("{noenter}", "{noe}")
    end
    saveData(tBindList, fileb)
    addEventHandler("onWindowMessage", function (msg, wparam, lparam)
        if msg == 0x100 or msg == 0x101 then
            if wparam == key.VK_ESCAPE and (mainw.v or imegaf.v or shpwindow.v or ykwindow.v or fpwindow.v or akwindow.v or updwindows.v or memw.v) and not isPauseMenuActive() then
                consumeWindowMessage(true, false)
                if msg == 0x101 then
                    mainw.v = false
                    imegaf.v = false
                    shpwindow.v = false
                    ykwindow.v = false
                    fpwindow.v = false
                    akwindow.v = false
                    updwindows.v = false
                    memw.v = false
                end
            end
        end
    end)
    if not sampIsDialogActive() then
        lua_thread.create(checkStats)
    else
        while sampIsDialogActive() do wait(0) end
        lua_thread.create(checkStats)
    end

    changeWeapons()
    sendDataToServer_Timer(600)

    while true do wait(0)
        if isCharInAnyCar(PLAYER_PED) then mcid = select(2, sampGetVehicleIdByCarHandle(storeCarCharIsInNoSave(PLAYER_PED))) end
        if gmegafid == nil then gmegafid = -1 end
        if #departament > 25 then table.remove(departament, 1) end
        if #radio > 25 then table.remove(radio, 1) end
        if #wanted > 25 then table.remove(wanted, 1) end
        if #sms > 25 then table.remove(sms, 1) end
        infbar = imgui.ImBool(cfg.main.hud)
        local myid = select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))
        imgui.Process = infbar.v or mainw.v or shpwindow.v or ykwindow.v or fpwindow.v or akwindow.v or updwindows.v or imegaf.v or memw.v
        local myskin = getCharModel(PLAYER_PED)

        if cfg.main.group == '��/���' then if sampGetFraktionBySkin(myid) == '�������' or sampGetFraktionBySkin(myid) == 'FBI' then rabden = true else rabden = false end
        elseif cfg.main.group == '���������' then if sampGetFraktionBySkin(myid) == '���������' then rabden = true else rabden = false end
        elseif cfg.main.group == '������' then if sampGetFraktionBySkin(myid) == '������' then rabden = true else rabden = false end
        elseif cfg.main.group == '�����' then if sampGetFraktionBySkin(myid) == '�����' then rabden = true else rabden = false end
        elseif cfg.main.group == "�����" then if sampGetFraktionBySkin(myid) == "Army" then rabden = true else rabden = false end 
        end

        if cfg.main.tarb then
            trash.tag = cfg.main.tar

            local keys = {
                ["{myid}"] = select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)),
                ["{kv}"] = kvadrat(),
                ["{targetid}"] = targetid,
                ["{targetrpnick}"] = sampGetPlayerNicknameForBinder(targetid):gsub('_', ' '),
                ["{naparnik}"] = naparnik(),
                ["{myrpnick}"] = sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))):gsub("_", " "),
                ["{smsid}"] = smsid,
                ["{smstoid}"] = smstoid,
                ["{rang}"] = rang,
                ["{frak}"] = frak,
                ["{megafid}"] = gmegafid,
                ["{dl}"] = mcid,
                ["{post}"] = getPost()
            }

            for k1, v1 in pairs(keys) do
                trash.tag = trash.tag:gsub(k1, v1)
            end

        end

        if sampIsDialogActive() == false and not isPauseMenuActive() and isPlayerPlaying(playerHandle) and sampIsChatInputActive() == false then
            if coordX ~= nil and coordY ~= nil then
                cX, cY, cZ = getCharCoordinates(playerPed)
                cX = math.ceil(cX)
                cY = math.ceil(cY)
                cZ = math.ceil(cZ)
                notf.addNotification('����� ����������� �� '..kvadY..'-'..kvadX, 4, 2)
                placeWaypoint(coordX, coordY, 0)
                coordX = nil
                coordY = nil
            end
        end
        if not doesCharExist(gmegafhandle) and gmegafhandle ~= nil then
            notf.addNotification(("����� %s [%s] ������� �� ���� ������"):format(sampGetPlayerNickname(gmegafid), gmegafid), 4, 3)
            gmegafid = -1
			gmegaflvl = nil
			gmegaffrak = nil
            gmegafhandle = nil
        end
        if changetextpos then
            sampToggleCursor(true)
            local CPX, CPY = getCursorPos()
            cfg.main.posX = CPX
            cfg.main.posY = CPY
        end
        if wasKeyPressed(key.VK_T) and cfg.main.tchat and not sampIsChatInputActive() and not sampIsDialogActive() and not isSampfuncsConsoleActive() then
            sampSetChatInputEnabled(true)
        end
        local myhp = getCharHealth(PLAYER_PED)
        local valid, ped = getCharPlayerIsTargeting(PLAYER_HANDLE)
        if valid and doesCharExist(ped) then
            local result, id = sampGetPlayerIdByCharHandle(ped)
            targetid = id
        end
        local result, button, list, input = sampHasDialogRespond(1385)
        local result16, button, list, input = sampHasDialogRespond(1401)
        local result17, button, list, input = sampHasDialogRespond(1765)
        local ooplresult, button, list, input = sampHasDialogRespond(2458)
        local oopdelresult, button, list, input = sampHasDialogRespond(2459)
        local _, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
        if #ooplistt > 30 then
            table.remove(ooplistt, 1)
        end
        if oopdelresult then
            if button == 1 then
                local oopi = 1
                while oopi <= #ooplistt do
                    if ooplistt[oopi]:find(oopdelnick) then
                        table.remove(ooplistt, oopi)
                    else
                        oopi = oopi + 1
                    end
                end
                notf.addNotification('����� '..oopdelnick..' ��� ������ �� ������ ���', 4, 2)
            elseif button == 0 then
                sampShowDialog(2458, '{9966cc}'..script.this.name.. '| {ffffff}������ ���', table.concat(ooplistt, '\n'), '�', "x", 2)
            end
        end
        if ooplresult then
            if button == 1 then
                local ltext = sampGetListboxItemText(list)
                if ltext:match("���� �� ��� .+ ������������ �� ��������, ���") then
                    oopdelnick = ltext:match("���� �� ��� (.+) ������������ �� ��������, ���")
                    sampShowDialog(2459, '{9966cc}'..script.this.name..' | {ffffff}�������� �� ���', "{ffffff}�� ������������� ������� ������� {9966cc}"..oopdelnick.."\n{ffffff}�� ������ ���?", "�", "�", 0)
                elseif ltext:match("���� .+ ������������ �� �������� %- ���.") then
                    oopdelnick = ltext:match("���� (.+) ������������ �� �������� %- ���.")
                    sampShowDialog(2459, '{9966cc}'..script.this.name..' | {ffffff}�������� �� ���', "{ffffff}�� ������������� ������� ������� {9966cc}"..oopdelnick.."\n{ffffff}�� ������ ���?", "�", "�", 0)
                end
            end
        end
        if result17 then
            if button == 1 then
                if #input ~= 0 and tonumber(input) ~= nil then
                    for k, v in pairs(suz) do
                        if tonumber(input) == k then
                            local reas, zzv = v:match('(.+) %- (%d+) .+')
                            sampSendChat(string.format('/su %s %s %s', zid, zzv, reas))
                            zid = nil
                        end
                    end
                else
                    notf.addNotification('�� �� ������� ����� ������.', 4, 3)
                end
            end
        end
        if result16 then
            if input ~= '' and button == 1 then
                if cfg.main.tarb then
                    sampSendChat(string.format('/r %s: ���������� ��������� � ������� %s �� %s', trash.tag, kvadrat(), input))
                else
                    sampSendChat(string.format('/r ���������� ��������� � ������� %s �� %s', kvadrat(), input))
                end
            end
        end
        if result then
            if button == 1 then
				sampSendChat(("/r %s � ����� %s. �������: %s"):format(cfg.main.male and '����������' or '�����������', mstype, input))
				wait(1400)
				sampSendChat("/rb "..myid)
				mstype = ''
            end
        end
    end
end

function oop(pam)
    pID = tonumber(pam)
    if frak == 'FBI' or frak == 'LSPD' or frak == 'SFPD' or frak == 'LVPD' then
        if pID ~= nil then
            if sampIsPlayerConnected(pID) then
                if rang == '�����' or rang == '������' or rang == '��.�������' or  rang == '�������' or  rang == '���������' then
                    if not cfg.main.tarb then
                        sampSendChat("/r ���� �� ��� "..sampGetPlayerNickname(pID):gsub('_', ' ').." ������������ �� ��������, ���.")
                    else
                        sampSendChat("/r "..trash.tag..": ���� �� ��� "..sampGetPlayerNickname(pID):gsub('_', ' ').." ������������ �� ��������, ���.")
                    end
                else
                    sampSendChat("/d Mayor, ���� �� ��� "..sampGetPlayerNickname(pID):gsub('_', ' ').." ������������ �� ��������, ���.")
                end
            else
                ftext("����� � ID: "..pID.." �� ��������� � �������")
            end
        else
            ftext("�������: /oop [id]")
        end
    else
        ftext("�� �� ��������� ��/FBI")
    end
end

function tazer()
    thread = lua_thread.create(function()
        sampSendChat("/tazer")
        wait(1400)
        sampSendChat(('/me %s ��� ��������'):format(cfg.main.male and '������' or '�������'))
    end)
end

function su(pam)
    pID = tonumber(pam)
    if pID ~= nil then
        if sampIsPlayerConnected(pID) then
            lua_thread.create(function()
                submenus_show(sumenu(pID), "{9966cc}"..script.this.name.." {ffffff}| "..sampGetPlayerNickname(pID).."["..pID.."] ")
            end)
        else
            ftext("����� � ID: "..pID.." �� ��������� � �������")
        end
    else
        ftext("�������: /su [id]")
    end
end

function ssu(pam)
    local id, zv, orichina = pam:match('(%d+) (%d+) (.+)')
    if id and zv and orichina then
        sampSendChat(string.format('/su %s %s %s', id, zv, orichina))
    else
        ftext('�������: /ssu [id] [���-�� �����] [�������]')
    end
end

function keys()
    thread = lua_thread.create(function()
        sampSendChat(("/me %s ����"):format(cfg.main.male and '����' or '�����'))
        wait(cfg.commands.zaderjka)
        sampSendChat("/me ���������� ���� � ������ �� ���")
        wait(cfg.commands.zaderjka)
        sampSendChat(("/try %s, ��� ����� ���������"):format(cfg.main.male and '���������', '����������'))
    end)
end

function cput(pam)
    thread = lua_thread.create(function()
        if cfg.commands.cput then
            if pam:match("^(%d+)$") then
                local id = tonumber(pam:match("^(%d+)$"))
                if sampIsPlayerConnected(id) then
                    if isCharInAnyCar(PLAYER_PED) then
                        if isCharOnAnyBike(PLAYER_PED) then
                            sampSendChat(("/me %s %s �� ������� ���������"):format(cfg.main.male and '�������' or '��������', sampGetPlayerNickname(id):gsub("_", ' ')))
                            wait(1400)
                            sampSendChat(("/cput %s %s"):format(id, getFreeSeat()))
                        else
                            sampSendChat(("/me %s ����� ���������� � %s ���� %s"):format(cfg.main.male and '������' or '�������', cfg.main.male and '���������' or '����������', sampGetPlayerNickname(id):gsub("_", ' ')))
                            wait(1400)
                            sampSendChat(("/cput %s %s"):format(id, getFreeSeat()))
                        end
                    else
                        sampSendChat(("/me %s ����� ���������� � %s ���� %s"):format(cfg.main.male and '������' or '�������', cfg.main.male and '���������' or '����������', sampGetPlayerNickname(id):gsub("_", ' ')))
                        while not isCharInAnyCar(PLAYER_PED) do wait(0) end
                        sampSendChat(("/cput %s %s"):format(id, getFreeSeat()))
                    end
                else
                    ftext("����� �������")
                end
            elseif pam:match("^(%d+) (%d+)$") then
                local id, seat = pam:match("^(%d+) (%d+)$")
                local id, seat = tonumber(id), tonumber(seat)
                if sampIsPlayerConnected(id) then
                    if seat >=1 and seat <=3 then
                        if isCharInAnyCar(PLAYER_PED) then
                            if isCharOnAnyBike(PLAYER_PED) then
                                sampSendChat(("/me %s %s �� ������� ���������"):format(cfg.main.male and '�������' or '��������', sampGetPlayerNickname(id):gsub("_", ' ')))
                                wait(1400)
                                sampSendChat(("/cput %s %s"):format(id, seat))
                            else
                                sampSendChat(("/me %s ����� ���������� � %s ���� %s"):format(cfg.main.male and '������' or '�������', cfg.main.male and '���������' or '����������', sampGetPlayerNickname(id):gsub("_", ' ')))
                                wait(1400)
                                sampSendChat(("/cput %s %s"):format(id, seat))
                            end
                        else
                            sampSendChat(("/me %s ����� ���������� � %s ���� %s"):format(cfg.main.male and '������' or '�������', cfg.main.male and '���������' or '����������', sampGetPlayerNickname(id):gsub("_", ' ')))
                            while not isCharInAnyCar(PLAYER_PED) do wait(0) end
                            sampSendChat(("/cput %s %s"):format(id, seat))
                        end
                    else
                        ftext('�������� �� ������ ���� ������ 1 � ������ 3!')
                    end
                else
                    ftext('����� �������')
                end
            elseif #pam == 0 or not pam:match("^(%d+)$") or not pam:match("^(%d+) (%d+)$") then
                ftext('�������: /cput [id] [�����(�� �����������)]')
            end
        else
            sampSendChat(('/cput %s'):format(pam))
        end
    end)
end

function ceject(pam)
    thread = lua_thread.create(function()
        local id = tonumber(pam)
        if cfg.commands.ceject then
            if id ~= nil then
                if sampIsPlayerConnected(id) then
                    if isCharOnAnyBike(PLAYER_PED) then
                        sampSendChat(("/me %s %s � ���������"):format(cfg.main.male and '�������' or '��������', sampGetPlayerNickname(id):gsub('_', ' ')))
                        wait(1400)
                        sampSendChat(("/ceject %s"):format(id))
                    else
                        sampSendChat(("/me %s ����� ���������� � %s %s"):format(cfg.main.male and '������' or '�������', cfg.main.male and '�������' or '��������', sampGetPlayerNickname(id):gsub('_', ' ')))
                        wait(1400)
                        sampSendChat(("/ceject %s"):format(id))
                    end
                else
                    ftext('����� �������')
                end
            else
                ftext('�������: /ceject [id]')
            end
        else
            sampSendChat(("/ceject %s"):format(pam))
        end
    end)
end

function st(pam)
    local id = tonumber(pam)
    local result, ped = sampGetCharHandleBySampPlayerId(id)
    if id == nil then
        sampSendChat('/m ['..frak..'] ��������, ������� �������� � ���������� � ������� ��� �� ������� �����!')
    end
    if id ~= nil and not sampIsPlayerConnected(id) then
        ftext(string.format('����� � ID: %s �� ��������� � �������', id), -1)
    end
    if result and not doesCharExist(ped) then
        local stname = sampGetPlayerNickname(id)
        ftext(string.format('����� %s [%s] �� ��������', stname, id), -1)
    end
    if result and doesCharExist(ped) and not isCharInAnyCar(ped) then
        local stnaame = sampGetPlayerNickname(id)
        ftext(string.format('����� %s [%s] �� � ����������', stnaame, id), -1)
    end
    if result and doesCharExist(ped) and isCharInAnyCar(ped) then
        local vehName = tCarsName[getCarModel(storeCarCharIsInNoSave(ped))-399]
        sampSendChat("/m �������� �/C "..vehName.." � ���.������� [EVL"..id.."X], ���������� � ������� � ���������� ��� �/�")
    end
end

function deject(pam)
    thread = lua_thread.create(function()
        local id = tonumber(pam)
        if cfg.commands.deject then
            if id ~= nil then
                if sampIsPlayerConnected(id) then
                    local result, ped = sampGetCharHandleBySampPlayerId(id)
                    if result then
                        if isCharInFlyingVehicle(ped) then
                            sampSendChat(("/me %s ����� �������� � %s %s"):format(cfg.main.male and '������' or '�������', cfg.main.male and '�������' or '��������', sampGetPlayerNickname(id):gsub('_', ' ')))
                        elseif isCharInModel(ped, 481) or isCharInModel(ped, 510) then
                            sampSendChat(("/me %s %s � ����������"):format(cfg.main.male and '������' or '�������', sampGetPlayerNickname(id):gsub('_', ' ')))
                        elseif isCharInModel(ped, 462) then
                            sampSendChat(("/me %s %s �� �������"):format(cfg.main.male and '������' or '�������', sampGetPlayerNickname(id):gsub('_', ' ')))
                        elseif isCharOnAnyBike(ped) then
                            sampSendChat(("/me %s %s � ���������"):format(cfg.main.male and '������' or '�������', sampGetPlayerNickname(id):gsub('_', ' ')))
                        elseif isCharInAnyCar(ped) then
                            sampSendChat(("/me %s ���� � %s %s �� ������"):format(cfg.main.male and '������' or '�������', cfg.main.male and '�������' or '��������', sampGetPlayerNickname(id):gsub('_', ' ')))
                        end
                        wait(1400)
                        sampSendChat(("/deject %s"):format(id))
                    end
                else
                    ftext('����� �������')
                end
            else
                ftext("�������: /deject [id]")
            end
        else
            sampSendChat(("/deject %s"):format(pam))
        end
    end)
end

function rh(id)
    local _, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
    if id == "" or id < "1" or id > "3" or id == nil then
        ftext("�������: /rh �����������", -1)
        ftext("1 - LSPD | 2 - SFPD | 3 - LVPD", -1)
    elseif id == "1" then
        sampSendChat("/d LSPD, ���������� ���������� ������ � "..kvadrat()..", ��� �������? ����� �� ���."..myid)
    elseif id == "2" then
        sampSendChat("/d SFPD, ���������� ���������� ������ � "..kvadrat()..", ��� �������? ����� �� ���."..myid)
    elseif id == "3" then
        sampSendChat("/d LVPD, ���������� ���������� ������ � "..kvadrat()..", ��� �������? ����� �� ���."..myid)
    end
end
function gr(pam)
    local dep, reason = pam:match('(%d+)%s+(.+)')
    if dep == nil or reason == nil then
        ftext("�������: /gr [1-3] [�������]")
        ftext("1 - LSPD | 2 - SFPD | 3 - LVPD")
    end
    if dep ~= nil then
        if dep == "" or dep < "1" or dep > "3" then
            ftext("{9966CC}"..script.this.name.." {FFFFFF}| �������: /gr [1-3] [�������]")
            ftext("{9966CC}"..script.this.name.." {FFFFFF}| 1 - LSPD | 2 - SFPD | 3 - LVPD")
        elseif dep == "1" then
            sampSendChat("/d LSPD, ��������� ���� ����������, "..reason)
        elseif dep == "2" then
            sampSendChat("/d SFPD, ��������� ���� ����������, "..reason)
        elseif dep == "3" then
            sampSendChat("/d LVPD, ��������� ���� ����������, "..reason)
        end
    end
end
function warn(pam)
    local id = tonumber(pam)
    if frak == 'FBI' then
        if id == nil then
            ftext('������� /warn ID')
        end
        if id ~= nil and sampIsPlayerConnected(id) then
            thread = lua_thread.create(function()
                warnst = true
                sampSendChat('/mdc '..id)
                wait(1400)
                if wfrac == 'LSPD' or wfrac == 'SFPD' or wfrac == 'LVPD' then
                    sampSendChat(string.format('/d %s, %s �������� �������������� �� ������������ ������ � ������.', wfrac, sampGetPlayerNickname(id):gsub('_', ' ')))
                else
                    ftext('������� �� �������� ����������� PD')
                end
                wfrac = nil
                warnst = false
            end)
        end
    else
        ftext("�� �� ��������� ���")
    end
end
function ms(pam)
	thread = lua_thread.create(function()
		if frak == 'FBI' then
			if pam == "" or pam < "0" or pam > "3" or pam == nil then
				ftext("�������: /ms [���]", -1)
				ftext("0 - ����� ���������� | 1 - ���� | 2 - �������� | 3 - �����", -1)
			elseif pam == '1' then
				sampSendChat(("/me %s � ���� ������ ������ � %s �� �������"):format(cfg.main.male and '����' or '�����', cfg.main.male and '�������' or '��������'))
				wait(cfg.commands.zaderjka)
				sampSendChat(("/me %s ����, ����� ���� ������ %s ����������"):format(cfg.main.male and '������' or '�������', cfg.main.male and '������' or '�������'))
				wait(cfg.commands.zaderjka)
				sampSendChat(("/me %s �� ���� ���������� � %s ����"):format(cfg.main.male and '�����' or '������', cfg.main.male and '������' or '�������'))
				wait(cfg.commands.zaderjka)
				sampSendChat("/do ����� � ����������.")
				wait(100)
				submenus_show(osnova, "{9966cc}"..script.this.name.." {ffffff}| Mask")
			elseif pam == '2' then
				sampSendChat(("/me %s �������� ����������"):format(cfg.main.male and '������' or '�������'))
				wait(cfg.commands.zaderjka)
				sampSendChat(("/me %s � ���� ������ ������ � %s � ��������"):format(cfg.main.male and '����' or '�����', cfg.main.male and '�����' or '������'))
				wait(cfg.commands.zaderjka)
				sampSendChat(("/me %s �� ��������� �������� ���������� � %s �� ����"):format(cfg.main.male and '������' or '�������', cfg.main.male and '�����' or '������'))
				wait(cfg.commands.zaderjka)
				sampSendChat(("/me %s ��������"):format(cfg.main.male and '������' or '�������'))
				wait(cfg.commands.zaderjka)
				sampSendChat("/do ����� � ����������.")
				wait(100)
				submenus_show(osnova, "{9966cc}"..script.this.name.." {ffffff}| Mask")
			elseif pam == '3' then
				sampSendChat("/do �� ����� ������ ����� �����.")
				wait(cfg.commands.zaderjka)
				sampSendChat(("/me ������ �����, %s ������ ������ � %s ����"):format(cfg.main.male and '����' or '�����', cfg.main.male and '�����' or '������'))
				wait(cfg.commands.zaderjka)
				sampSendChat(("/me %s �� ����� �������� ���������� � %s �� ����"):format(cfg.main.male and '������' or '�������', cfg.main.male and '�����' or '������'))
				wait(cfg.commands.zaderjka)
				sampSendChat(("/me %s �����"):format(cfg.main.male and '������' or '�������'))
				wait(cfg.commands.zaderjka)
				sampSendChat("/do ����� � ����������.")
				wait(100)
				submenus_show(osnova, "{9966cc}"..script.this.name.." {ffffff}| Mask")
			elseif pam == '0' then
				sampSendChat(("/me %s � ���� ����������"):format(cfg.main.male and '����' or '�����'))
				wait(cfg.commands.zaderjka)
				sampSendChat(("/me %s �� ���� ������ ������"):format(cfg.main.male and '�����' or '������'))
				wait(cfg.commands.zaderjka)
				sampSendChat(("/r %s � ������ ������"):format(cfg.main.male and '����������' or '�����������'))
				wait(cfg.commands.zaderjka)
				sampSendChat("/rb "..select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)))
			end
		else
			ftext('�� �� ��������� FBI')
		end
	end)
end

function ar(id)
    if id == "" or id < "1" or id > "2" or id == nil then
        ftext("�������: /ar [1-2]", -1)
        ftext("1 - LVa | 2 - SFa", -1)
    elseif id == "1" then
        sampSendChat("/d LVa, ��������� ����� �� ���� ����������, ������ �����������.")
    elseif id == "2" then
        sampSendChat("/d SFa, ��������� ����� �� ���� ����������, ������ �����������.")
    end
end

function r(pam)
    if #pam ~= 0 then
        if cfg.main.tarb then
            sampSendChat(string.format('/r %s: %s', trash.tag, pam))
        else
            sampSendChat(string.format('/r %s', pam))
        end
    else
        ftext('������� /r [�����]')
    end
end

function f(pam)
    if #pam ~= 0 then
        if cfg.main.tarb then
            sampSendChat(string.format('/f %s: %s', trash.tag, pam))
        else
            sampSendChat(string.format('/f %s', pam))
        end
    else
        ftext('������� /f [�����]')
    end
end

function fst(param)
    local hour = tonumber(param)
    if hour ~= nil and hour >= 0 and hour <= 23 then
        time = hour
        patch_samp_time_set(true)
        if time then
            setTimeOfDay(time, 0)
            ftext('����� �������� ��: {9966cc}'..time, -1)
        end
    else
        ftext('�������� ������� ������ ���� � ��������� �� 0 �� 23.', -1)
        patch_samp_time_set(false)
        time = nil
    end
end

function fsw(param)
    local weather = tonumber(param)
    if weather ~= nil and weather >= 0 and weather <= 45 then
        forceWeatherNow(weather)
        ftext('������ �������� ��: {9966cc}'..weather, -1)
    else
        ftext('�������� ������ ������ ���� � ��������� �� 0 �� 45.', -1)
    end
end

function patch_samp_time_set(enable)
    if enable and default == nil then
        default = readMemory(sampGetBase() + 0x9C0A0, 4, true)
        writeMemory(sampGetBase() + 0x9C0A0, 4, 0x000008C2, true)
    elseif enable == false and default ~= nil then
        writeMemory(sampGetBase() + 0x9C0A0, 4, default, true)
        default = nil
    end
end

function fshp(pam)
    if #pam ~= 0 then
        local f = io.open('moonloader\\fbitools\\shp.txt')
        for line in f:lines() do
            if string.find(line, pam) or string.rlower(line):find(pam) or string.rupper(line):find(pam) then
                sampAddChatMessage(' '..line, -1)
            end
        end
        f:close()
    else
        ftext('������� /fshp [�����]')
    end
end
function fyk(pam)
    if #pam ~= 0 then
        local f = io.open('moonloader\\fbitools\\yk.txt')
        for line in f:lines() do
            if string.find(line, pam) or string.rlower(line):find(pam) or string.rupper(line):find(pam) then
                sampAddChatMessage(' '..line, -1)
            end
        end
        f:close()
    else
        ftext('������� /fyk [�����]')
    end
end

function ffp(pam)
    if #pam ~= 0 then
        local f = io.open('moonloader\\fbitools\\fp.txt')
        for line in f:lines() do
            if string.find(line, pam) or string.rlower(line):find(pam) or string.rupper(line):find(pam) then
                sampAddChatMessage(' '..line, -1)
            end
        end
        f:close()
    else
        ftext('������� /ffp [�����]')
    end
end

function fak(pam)
    if #pam ~= 0 then
        local f = io.open('moonloader\\fbitools\\ak.txt')
        for line in f:lines() do
            if string.find(line, pam) or string.rlower(line):find(pam) or string.rupper(line):find(pam) then
                sampAddChatMessage(' '..line, -1)
            end
        end
        f:close()
    else
        ftext('������� /fak [�����]')
    end
end

function dmb()
    lua_thread.create(function()
        if sampIsDialogActive() then
            if sampIsDialogClientside() then
                tMembers = {}
                status = true
                sampSendChat('/members')
                while not gotovo do wait(0) end
                memw.v = true
                gosmb = false
                krimemb = false
                gotovo = false
                status = false
                gcount = nil
            end
        else
            tMembers = {}
            status = true
            sampSendChat('/members')
            while not gotovo do wait(0) end
            memw.v = true
            gosmb = false
            krimemb = false
            gotovo = false
            status = false
            gcount = nil
        end
	end)
end

function megaf()
    if cfg.main.group == '��/���' then
        thread = lua_thread.create(function()
            if isCharInAnyCar(PLAYER_PED) then
                incar = {}
                local stream = sampGetStreamedPlayers()
                local _, myvodil = sampGetPlayerIdByCharHandle(getDriverOfCar(storeCarCharIsInNoSave(PLAYER_PED)))
                for k, v in pairs(stream) do
                    local result, ped = sampGetCharHandleBySampPlayerId(v)
                    if result then
                        if isCharInAnyCar(ped) then
                            local car = storeCarCharIsInNoSave(ped)
                            local myposx, myposy, myposz = getCharCoordinates(PLAYER_PED)
                            local pposx, pposy, pposz = getCharCoordinates(ped)
                            local dist = getDistanceBetweenCoords3d(myposx, myposy, myposz, pposx, pposy, pposz)
                            if dist <=65 then
                                if getDriverOfCar(car) == ped then
                                    if sampGetFraktionBySkin(v) ~= '�������' then
                                        if storeCarCharIsInNoSave(ped) ~= storeCarCharIsInNoSave(PLAYER_PED) then
                                            if v ~= myvodil then
                                                table.insert(incar, v)
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
                if #incar ~= 0 then
                    if #incar == 1 then
                        local result, ped = sampGetCharHandleBySampPlayerId(incar[1])
                        if doesCharExist(ped) then
                            if isCharInAnyCar(ped) then
                                local carh = storeCarCharIsInNoSave(ped)
                                local carhm = getCarModel(carh)
                                sampSendChat(("/m �������� �/� %s [EVL%sX]"):format(tCarsName[carhm-399], incar[1]))
                                wait(1400)
                                sampSendChat("/m ���������� � ������� ��� �� ������� �����!")
                                wait(300)
                                sampAddChatMessage(' {ffffff}~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~', 0x9966cc)
                                sampAddChatMessage('', 0x9966cc)
                                sampAddChatMessage(' {ffffff}���: {9966cc}'..sampGetPlayerNickname(incar[1])..' ['..incar[1]..']', 0x9966cc)
                                sampAddChatMessage(' {ffffff}�������: {9966cc}'..sampGetPlayerScore(incar[1]), 0x9966cc)
                                sampAddChatMessage(' {ffffff}�������: {9966cc}'..sampGetFraktionBySkin(incar[1]), 0x9966cc)
                                sampAddChatMessage('', 0x9966cc)
                                sampAddChatMessage(' {ffffff}~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~', 0x9966cc)
                                gmegafid = incar[1]
                                gmegaflvl = sampGetPlayerScore(incar[1])
                                gmegaffrak = sampGetFraktionBySkin(incar[1])
                                gmegafcar = tCarsName[carhm-399]
                            end
                        end
                    else
                        if cfg.main.megaf then
                            if not imegaf.v then imegaf.v = true end
                        else
                            for k, v in pairs(incar) do
                                local result, ped = sampGetCharHandleBySampPlayerId(v)
                                if doesCharExist(ped) then
                                    local carh = storeCarCharIsInNoSave(ped)
                                    local carhm = getCarModel(carh)
                                    sampSendChat(("/m �������� �/� %s [EVL%sX]"):format(tCarsName[carhm-399], v))
                                    wait(1400)
                                    sampSendChat("/m ���������� � ������� ��� �� ������� �����!")
                                    wait(300)
                                    sampAddChatMessage(' {ffffff}~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~', 0x9966cc)
                                    sampAddChatMessage('', 0x9966cc)
                                    sampAddChatMessage(' {ffffff}���: {9966cc}'..sampGetPlayerNickname(v)..' ['..v..']', 0x9966cc)
                                    sampAddChatMessage(' {ffffff}�������: {9966cc}'..sampGetPlayerScore(v), 0x9966cc)
                                    sampAddChatMessage(' {ffffff}�������: {9966cc}'..sampGetFraktionBySkin(v), 0x9966cc)
                                    sampAddChatMessage('', 0x9966cc)
                                    sampAddChatMessage(' {ffffff}~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~', 0x9966cc)
                                    gmegafid = v
                                    gmegaflvl = sampGetPlayerScore(v)
                                    gmegaffrak = sampGetFraktionBySkin(v)
                                    gmegafcar = tCarsName[carhm-399]
                                    break
                                end
                            end
                        end
                    end
                end
            else
                ftext("��� ���������� ������ � ����������")
            end
        end)
    end
end

function dkld()
    local posX, posY, posZ = getCharCoordinates(PLAYER_PED)
    if isCharInAnyCar(PLAYER_PED) then
        if getCarSpeed(storeCarCharIsInNoSave(PLAYER_PED)) > 0 then
            for k, v in pairs(posts.inCar.patruls) do
                local dist = getDistanceBetweenCoords3d(posX, posY, posZ, v[1], v[2], v[3])
                if dist <= v[4] then
                    sampSendChat(("/r %s %s. %s"):format(cfg.main.tarb and trash.tag..":" or "", v[5], naparnik()))
                    return
                end
            end
            for k, v in pairs(posts.inCar.yris) do
                local dist = getDistanceBetweenCoords3d(posX, posY, posZ, v[1], v[2], v[3])
                if dist <= v[4] then
                    if k == 1 or k == 7 or k == 8 or k == 9 then
                        if frak == 'LSPD' then
                            sampSendChat('/d SFPD, ��������� ���� ����������, ������.')
                        elseif frak == 'SFPD' then
                            sampSendChat('/d LSPD, ��������� ���� ����������, ������.')
                        elseif frak == 'LVPD' then
                            submenus_show(yrisdkld1404, '{9966CC}'..script.this.name..'{ffffff} | ����������� ����������')
                        end
                    elseif k == 2 or k == 3 or k == 4 then
                        if frak == 'LSPD' then
                            sampSendChat('/d LVPD, ��������� ���� ����������, ������.')
                        elseif frak == 'LVPD' then
                            sampSendChat('/d LSPD, ��������� ���� ����������, ������.')
                        elseif frak == 'SFPD' then
                            submenus_show(yrisdkld1405, '{9966CC}'..script.this.name..'{ffffff} | ����������� ����������')
                        end
                    elseif k == 5 or k == 6 then
                        if frak == 'LVPD' then
                            sampSendChat('/d SFPD, ��������� ���� ����������, ������.')
                        elseif frak == 'SFPD' then
                            sampSendChat('/d LVPD, ��������� ���� ����������, ������.')
                        elseif frak == 'LSPD' then
                            submenus_show(yrisdkld1406, '{9966CC}'..script.this.name..'{ffffff} | ����������� ����������')
                        end
                    end
                    return
                end
            end
        else
            for k, v in pairs(posts.onFoot) do
                local dist = getDistanceBetweenCoords3d(posX, posY, posZ, v[1], v[2], v[3])
                if dist <= 30 then
                    sampSendChat(("/r %s ����: %s. %s"):format(cfg.main.tarb and trash.tag..":" or "", v[4], naparnik()))
                    return
                end
            end
        end
        for k, v in pairs(posts.inCar.posts) do
            local dist = getDistanceBetweenCoords3d(posX, posY, posZ, v[1], v[2], v[3])
            if dist <= 50 then
                sampSendChat(("/r %s ����: %s. %s"):format(cfg.main.tarb and trash.tag..":" or "", v[4], naparnik()))
                return
            end
        end
        if frak == "LSPD" then
            sampSendChat(("/r %s ������� ������ ��� ������. %s"):format(cfg.main.tarb and trash.tag..":" or "", naparnik()))
        elseif frak == "SFPD" then
            sampSendChat(("/r %s ������� ������ ��� ������. %s"):format(cfg.main.tarb and trash.tag..":" or "", naparnik()))
        elseif frak == "LVPD" then
            sampSendChat(("/r %s ������� ������ ��� ��������. %s"):format(cfg.main.tarb and trash.tag..":" or "", naparnik()))
        end
    else
        for k, v in pairs(posts.onFoot) do
            local dist = getDistanceBetweenCoords3d(posX, posY, posZ, v[1], v[2], v[3])
            if dist <= 30 then
                sampSendChat(("/r %s ����: %s. %s"):format(cfg.main.tarb and trash.tag..":" or "", v[4], naparnik()))
                return
            end
        end
    end
end

function kmdc(pam)
    thread = lua_thread.create(function()
        local id = tonumber(pam)
        if id ~= nil then
            if sampIsPlayerConnected(id) then
                sampSendChat(("/me %s ��� � %s ���������� ��������"):format(cfg.main.male and '������' or '�������', cfg.main.male and '������' or '�������'))
                wait(cfg.commands.zaderjka)
                sampSendChat(("/do ��� ��� ����������: ���: %s."):format(sampGetPlayerNickname(id):gsub('_', ' ')))
                wait(cfg.commands.zaderjka)
                sampSendChat(("/mdc %s"):format(id))
                if cfg.commands.kmdctime then
                    wait(1400)
                    sampSendChat("/time")
                    wait(500)
                    setVirtualKeyDown(key.VK_F8, true)
                    wait(150)
                    setVirtualKeyDown(key.VK_F8, false)
                end
            else
                ftext("����� �������")
            end
        else
            ftext("�������: /kmdc [id]")
        end
    end)
end

function fvz(pam)
    local id = tonumber(pam)
    local _, myid = sampGetPlayerIdByCharHandle(playerPed)
    if frak == 'FBI' then
        if id == nil then
            ftext("�������: /fvz [id]")
        end
        if id ~= nil and sampIsPlayerConnected(id) then
            lua_thread.create(function()
                warnst = true
                sampSendChat('/mdc '..id)
                wait(1400)
                if wfrac == 'LSPD' or wfrac == 'SFPD' or wfrac == 'LVPD' or wfrac == 'LVa' or wfrac == 'SFa' then
                    sampSendChat(string.format('/d %s, %s, ������� � ���� ��� �� ��������. ��� �������? ����� �� ���.%s', wfrac, sampGetPlayerNickname(id):gsub('_', ' '), myid))
                else
                    ftext('������� �� �������� ����������� PD/Army')
                end
                warnst = false
                wfrac = nil
            end)
        end
    else
        ftext("�� �� ��������� ���")
    end
end

function ftazer(pam)
    thread = lua_thread.create(function()
        local id = tonumber(pam)
        if cfg.commands.ftazer then
            if id ~= nil then
                if id >=1 and id <=3 then
                    sampSendChat(("/me %s �� ����������� ������� ������"):format(cfg.main.male and '������' or '�������'))
                    wait(1400)
                    sampSendChat(("/me %s ������ � %s"):format(cfg.main.male and '�����' or '������', cfg.main.male and '����������' or '�����������'))
                    wait(1400)
                    sampSendChat(("/me %s ������������ �������"):format(cfg.main.male and '������' or '�������'))
                    wait(1400)
                    sampSendChat(("/ftazer %s"):format(id))
                else
                    ftext("�������� �� ����� ���� ������ 1 � ������ 3!")
                end
            else
                ftext("�������: /ftazer [���]")
            end
        else
            sampSendChat(("/ftazer %s"):format(pam))
        end
    end)
end

function df()
    thread = lua_thread.create(function()
        submenus_show(dfmenu, "{9966cc}"..script.this.name.." {ffffff}| Bomb Menu")
    end)
end

function fbd(pam)
    local id = tonumber(pam)
    if frak == 'FBI' then
        if id == nil then
            ftext("�������: /fbd [id]")
        end
        if id ~= nil and sampIsPlayerConnected(id) then
            lua_thread.create(function()
                local _, myid = sampGetPlayerIdByCharHandle(playerPed)
                warnst = true
                sampSendChat('/mdc '..id)
                wait(1400)
                if wfrac == 'LSPD' or wfrac == 'SFPD' or wfrac == 'LVPD' then
                    sampSendChat(string.format('/d %s, %s, ������� ��������� �� �� �.%s', wfrac, sampGetPlayerNickname(id):gsub('_', ' '), myid))
                else
                    ftext('������� �� �������� ����������� PD')
                end
                warnst = false
                wfrac = nil
            end)
        end
    else
        ftext("�� �� ��������� ���")
    end
end

function cc()
    memory.fill(sampGetChatInfoPtr() + 306, 0x0, 25200)
    memory.write(sampGetChatInfoPtr() + 306, 25562, 4, 0x0)
    memory.write(sampGetChatInfoPtr() + 0x63DA, 1, 1)
end

function blg(pam)
    local id, frack, pric = pam:match('(%d+) (%a+) (.+)')
    if id and frack and pric and sampIsPlayerConnected(id) then
        name = sampGetPlayerNickname(id)
        rpname = name:gsub('_', ' ')
        sampSendChat(string.format("/d %s, ��������� %s �� %s. ������", frack, rpname, pric))
    else
        ftext("�������: /blg [id] [�������] [�������]", -1)
    end
end

function mcheck()
    peds = getAllChars()
    if peds ~= nil then
        local openw = io.open("moonloader/fbitools/mcheck.txt", 'a')
        openw:write('\n')
        openw:write(os.date()..'\n')
        openw:close()
        thread = lua_thread.create(function()
            for _, hm in pairs(peds) do
                _ , id = sampGetPlayerIdByCharHandle(hm)
                _ , m = sampGetPlayerIdByCharHandle(PLAYER_PED)
                if id ~= -1 and id ~= m and doesCharExist(hm) and sampIsPlayerConnected(id) then
                    local x, y, z = getCharCoordinates(hm)
                    local mx, my, mz = getCharCoordinates(PLAYER_PED)
                    local dist = getDistanceBetweenCoords3d(mx, my, mz, x, y, z)
                    if dist <= 200 then
                        mcheckb = true
                        _ , idofplayercar = sampGetPlayerIdByCharHandle(hm)
                        sampSendChat('/mdc '..idofplayercar)
                        wait(1400)
                        mcheckb = false
                    end
                end
            end
        end)
    end
end

function dlog()
    sampShowDialog(97987, '{9966cc}'..script.this.name..' {ffffff} | ��� ��������� ������������', table.concat(departament, '\n'), '�', 'x', 0)
end

function rlog()
    sampShowDialog(97987, '{9966cc}'..script.this.name..' {ffffff} | ��� ��������� �����', table.concat(radio, '\n'), '�', 'x', 0)
end

function sulog()
    sampShowDialog(97987, '{9966cc}'..script.this.name..' {ffffff} | ��� ������ �������', table.concat(wanted, '\n'), '�', 'x', 0)
end

function smslog()
    sampShowDialog(97987, '{9966cc}'..script.this.name..' {ffffff} | ��� SMS', table.concat(sms, '\n'), '�', 'x', 0)
end

function ticket(pam)
    thread = lua_thread.create(function()
        local id, summa, reason = pam:match('(%d+) (%d+) (.+)')
        if id and summa and reason then
            if cfg.commands.ticket then
                sampSendChat(string.format("/me %s ����� � �����", cfg.main.male and '������' or '�������'))
                wait(cfg.commands.zaderjka)
                sampSendChat("/do ����� � ����� � �����.")
                wait(cfg.commands.zaderjka)
                sampSendChat("/me �������� ��������� �����")
                wait(cfg.commands.zaderjka)
                sampSendChat("/do ����� ��������.")
                wait(cfg.commands.zaderjka)
                sampSendChat(string.format("/me %s ����� ����������", cfg.main.male and '�������' or '��������'))
                wait(1400)
            end
            sampSendChat(string.format('/ticket %s %s %s', id, summa, reason))
        else
            ftext('�������: /ticket [id] [�����] [�������]')
        end
    end)
end

function ssuz(pam)
    suz = {}
    local dsuz = {}
    for line in io.lines('moonloader\\fbitools\\su.txt') do
        table.insert(suz, line)
    end
    for k, v in pairs(suz) do
        table.insert(dsuz, string.format('{9966cc}%s. {ffffff}%s', k, v))
    end
    if pam:match('(%d+) (%d+)') then
        zid, zsu = pam:match('(%d+) (%d+)')
        if sampIsPlayerConnected(tonumber(zid)) then
            for k, v in pairs(suz) do
                if tonumber(zsu) == k then
                    local reas, zzv = v:match('(.+) %- (%d+) .+')
                    sampSendChat(string.format('/su %s %s %s', zid, zzv, reas))
                    zid = nil
                end
            end
        end
    elseif pam:match('(%d+)') then
        zid = pam:match('(%d+)')
        if sampIsPlayerConnected(tonumber(zid)) then
            sampShowDialog(1765, '{9966cc}'..script.this.name..' {ffffff}| ������ ������� ������ {9966cc}'..sampGetPlayerNickname(tonumber(zid)).. '[' ..zid.. ']', table.concat(dsuz, '\n').. '\n\n{ffffff}�������� ����� ��� ���������� � ������. ������: 15', '�', 'x', 1)
        end
    elseif #pam == 0 then
        ftext('�������: /z [id] [��������(�� �����������)]')
    end
end

function rt(pam)
    if #pam == 0 then
        ftext("������� /rt [�����]")
    else
        sampSendChat('/r '..pam)
    end
end

function ooplist(pam)
    thread = lua_thread.create(function()
        local oopid = tonumber(pam)
        if oopid ~= nil and sampIsPlayerConnected(oopid) then
            for k, v in pairs(ooplistt) do
                sampSendChat('/sms '..oopid..' '..v)
                wait(1400)
            end
        else
            sampShowDialog(2458, '{9966cc}'..script.this.name..' | {ffffff}������ ���', table.concat(ooplistt, '\n'), '�', "x", 2)
            ftext('��� �������� ������ ��� �������� ������� /ooplist [id]')
        end
    end)
end

function fkv(pam)
    if #pam ~= 0 then
        kvadY, kvadX = string.match(pam, "(%A)-(%d+)")
        if kvadrat(kvadY) ~= nil and kvadX ~= nil and kvadY ~= nil and tonumber(kvadX) < 25 and tonumber(kvadX) > 0 then
            last = lcs
            coordX = kvadX * 250 - 3125
            coordY = (kvadrat1(kvadY) * 250 - 3125) * - 1
        end
    else
        ftext('�������: /fkv [�������]')
        ftext('������: /fkv �-6')
    end
end

function fnr()
    thread = lua_thread.create(function()
        vixodid = {}
		fnrstatus = true
		sampSendChat('/members')
        while not gotovo do wait(0) end
        wait(1400)
        for k, v in pairs(vixodid) do
            sampSendChat('/sms '..v..' �� ������')
            wait(1400)
        end
		gotovo = false
        status = false
	end)
end

function strobes()
	while true do
		if isCharInAnyCar(PLAYER_PED) and not isCharInAnyBoat(PLAYER_PED) and not isCharInFlyingVehicle(PLAYER_PED) and not isCharOnAnyBike(PLAYER_PED) and not isCharInAnyTrain(PLAYER_PED) then
			if cfg.main.strobs then
				local car = storeCarCharIsInNoSave(PLAYER_PED)
				if doesVehicleExist(car) then
					local veh_struct = getCarPointer(car) + 1440
					if isCarSirenOn(car) then
						callMethod(0x6C2100, veh_struct, 2, 1, 0, 1)
						callMethod(0x6C2100, veh_struct, 2, 1, 1, 0)
						wait(300)
						callMethod(0x6C2100, veh_struct, 2, 1, 0, 0)
						callMethod(0x6C2100, veh_struct, 2, 1, 1, 1)
					else
						callMethod(0x6C2100, veh_struct, 2, 1, 0, 0)
						callMethod(0x6C2100, veh_struct, 2, 1, 1, 0)
					end
				end
			end
		end
		wait(300)
	end
end
function screen() local memory = require 'memory' memory.setuint8(sampGetBase() + 0x119CBC, 1) end

function Player:new(id, sRang, iRang, status, invite, afk, sec, nick)
	local obj = {
		id = id,
		nickname = nick,
		iRang = tonumber(iRang),
		sRang = u8(sRang),
		status = u8(status),
		invite = invite,
		afk = afk,
		sec = tonumber(sec)
	}

	setmetatable(obj, self)
	self.__index = self

	return obj
end
function getColorForSeconds(sec)
	if sec > 0 and sec <= 50 then
		return imgui.ImVec4(1, 1, 0, 1)
	elseif sec > 50 and sec <= 100 then
		return imgui.ImVec4(1, 159/255, 32/255, 1)
	elseif sec > 100 and sec <= 200 then
		return imgui.ImVec4(1, 93/255, 24/255, 1)
	elseif sec > 200 and sec <= 300 then
		return imgui.ImVec4(1, 43/255, 43/255, 1)
	elseif sec > 300 then
		return imgui.ImVec4(1, 0, 0, 1)
	end
end
function getColor(ID)
	PlayerColor = sampGetPlayerColor(ID)
	a, r, g, b = explode_argb(PlayerColor)
	return r/255, g/255, b/255, 1
end
function explode_argb(argb)
    local a = bit.band(bit.rshift(argb, 24), 0xFF)
    local r = bit.band(bit.rshift(argb, 16), 0xFF)
    local g = bit.band(bit.rshift(argb, 8), 0xFF)
    local b = bit.band(argb, 0xFF)
    return a, r, g, b
end

function pr()
    thread = lua_thread.create(function()
        sampSendChat("�� ����������, � ��� ���� ����� ������� ��������. ��, ��� �� �������, ����� � ����� ������������ ������ ��� � ����.")
        wait(cfg.commands.zaderjka)
        sampSendChat("� ��� ���� ����� �� �������� � �� ���� ���������� ������. ��� ������� ���� �����?")
    end)
end


function getAmmoInClip()
	local struct = getCharPointer(PLAYER_PED)
	local prisv = struct + 0x0718
	local prisv = memory.getint8(prisv, false)
	local prisv = prisv * 0x1C
	local prisv2 = struct + 0x5A0
	local prisv2 = prisv2 + prisv
	local prisv2 = prisv2 + 0x8
	local ammo = memory.getint32(prisv2, false)
	return ammo
end

function getFreeCost(lvl)
	if lvl >= 1 and lvl <= 2 then cost = 1000 end
	if lvl >= 3 and lvl <= 6 then cost = 3000 end
	if lvl >= 7 and lvl <= 13 then cost = 6000 end
	if lvl >= 14 and lvl <= 23 then cost = 9000 end
	if lvl >= 24 and lvl <= 35 then cost = 14000 end
	if lvl >= 36 then cost = 15000 end
	return cost
end

function string.split(inputstr, sep, limit)
    if limit == nil then limit = 0 end
    if sep == nil then sep = "%s" end
    local t={} ; i=1
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
        if i >= limit and limit > 0 then
            if t[i] == nil then
                t[i] = ""..str
            else
                t[i] = t[i]..sep..str
            end
        else
            t[i] = str
            i = i + 1
        end
    end
    return t
end

function registerCommandsBinder()
    for k, v in pairs(commands) do
        if sampIsChatCommandDefined(v.cmd) then sampUnregisterChatCommand(v.cmd) end
        sampRegisterChatCommand(v.cmd, function(pam)
            thread = lua_thread.create(function()
                local params = string.split(pam, " ", v.params)
                local cmdtext = v.text
                if #params < v.params then
                    local paramtext = ""
                    for i = 1, v.params do
                        paramtext = paramtext .. "[��������"..i.."] "
                    end
                    ftext("�������: /"..v.cmd.." "..paramtext, -1)
                else
                    for line in cmdtext:gmatch('[^\r\n]+') do

                        if line:match("^{wait%:%d+}$") then
                            wait(line:match("^%{wait%:(%d+)}$"))
                        elseif line:match("^{screen}$") then
                            screen()
                        else
                            local bIsEnter = string.match(line, "^{noe}(.+)") ~= nil
                            local bIsF6 = string.match(line, "^{f6}(.+)") ~= nil
                            local keys = {
                                ["{f6}"] = "",
                                ["{noe}"] = "",
                                ["{myid}"] = select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)),
                                ["{kv}"] = kvadrat(),
                                ["{targetid}"] = targetid,
                                ["{targetrpnick}"] = sampGetPlayerNicknameForBinder(targetid):gsub('_', ' '),
                                ["{naparnik}"] = naparnik(),
                                ["{myrpnick}"] = sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))):gsub("_", " "),
                                ["{smsid}"] = smsid,
                                ["{smstoid}"] = smstoid,
                                ["{rang}"] = rang,
                                ["{frak}"] = frak,
                                ["{megafid}"] = gmegafid,
                                ["{dl}"] = mcid,
                                ["{post}"] = getPost()
                            }

                            for i = 1, v.params do
                                keys["{param:"..i.."}"] = params[i]
                            end

                            for k1, v1 in pairs(keys) do
                                line = line:gsub(k1, v1)
                            end

                            if not bIsEnter then
                                if bIsF6 then
                                    sampProcessChatInput(line)
                                else
                                    sampSendChat(line)
                                end
                            else
                                sampSetChatInputText(line)
                                sampSetChatInputEnabled(true)
                            end
                        end
                    end
                end
            end)
        end)
    end
end

function getZones(zone)
    local names = {
      ["SUNMA"] = "Bayside Marina",
      ["SUNNN"] = "Bayside",
      ["BATTP"] = "Battery Point",
      ["PARA"] = "Paradiso",
      ["CIVI"] = "Santa Flora",
      ["BAYV"] = "Palisades",
      ["CITYS"] = "City Hall",
      ["OCEAF"] = "Ocean Flats",
      ["HASH"] = "Hashbury",
      ["JUNIHO"] = "Juniper Hollow",
      ["ESPN"] = "Esplanade North",
      ["FINA"] = "Financial",
      ["CALT"] = "Calton Heights",
      ["SFDWT"] = "Downtown",
      ["JUNIHI"] = "Juniper Hill",
      ["CHINA"] = "Chinatown",
      ["THEA"] = "King's",
      ["GARC"] = "Garcia",
      ["DOH"] = "Doherty",
      ["SFAIR"] = "Easter Bay Airport",
      ["EASB"] = "Easter Basin",
      ["ESPE"] = "Esplanade East",
      ["ANGPI"] = "Angel Pine",
      ["SHACA"] = "Shady Cabin",
      ["BACKO"] = "Back o Beyond",
      ["LEAFY"] = "Leafy Hollow",
      ["FLINTR"] = "Flint Range",
      ["HAUL"] = "Fallen Tree",
      ["FARM"] = "The Farm",
      ["ELQUE"] = "El Quebrados",
      ["ALDEA"] = "Aldea Malvada",
      ["DAM"] = "The Sherman Dam",
      ["BARRA"] = "Las Barrancas",
      ["CARSO"] = "Fort Carson",
      ["QUARY"] = "Hunter Quarry",
      ["OCTAN"] = "Octane Springs",
      ["PALMS"] = "Green Palms",
      ["TOM"] = "Regular Tom",
      ["BRUJA"] = "Las Brujas",
      ["MEAD"] = "Verdant Meadows",
      ["PAYAS"] = "Las Payasadas",
      ["ARCO"] = "Arco del Oeste",
      ["HANKY"] = "Hankypanky Point",
      ["PALO"] = "Palomino Creek",
      ["NROCK"] = "North Rock",
      ["MONT"] = "Montgomery",
      ["HBARNS"] = "Hampton Barns",
      ["FERN"] = "Fern Ridge",
      ["DILLI"] = "Dillimore",
      ["TOPFA"] = "Hilltop Farm",
      ["BLUEB"] = "Blueberry",
      ["PANOP"] = "The Panopticon",
      ["FRED"] = "Frederick Bridge",
      ["MAKO"] = "The Mako Span",
      ["BLUAC"] = "Blueberry Acres",
      ["MART"] = "Martin Bridge",
      ["FALLO"] = "Fallow Bridge",
      ["CREEK"] = "Shady Creeks",
      ["WESTP"] = "Queens",
      ["LA"] = "Los Santos",
      ["VE"] = "Las Venturas",
      ["BONE"] = "Bone County",
      ["ROBAD"] = "Tierra Robada",
      ["GANTB"] = "Gant Bridge",
      ["SF"] = "San Fierro",
      ["RED"] = "Red County",
      ["FLINTC"] = "Flint County",
      ["EBAY"] = "Easter Bay Chemicals",
      ["SILLY"] = "Foster Valley",
      ["WHET"] = "Whetstone",
      ["LAIR"] = "Los Santos International",
      ["BLUF"] = "Verdant Bluffs",
      ["ELCO"] = "El Corona",
      ["LIND"] = "Willowfield",
      ["MAR"] = "Marina",
      ["VERO"] = "Verona Beach",
      ["CONF"] = "Conference Center",
      ["COM"] = "Commerce",
      ["PER1"] = "Pershing Square",
      ["LMEX"] = "Little Mexico",
      ["IWD"] = "Idlewood",
      ["GLN"] = "Glen Park",
      ["JEF"] = "Jefferson",
      ["CHC"] = "Las Colinas",
      ["GAN"] = "Ganton",
      ["EBE"] = "East Beach",
      ["ELS"] = "East Los Santos",
      ["JEF"] = "Jefferson",
      ["LFL"] = "Los Flores",
      ["LDT"] = "Downtown Los Santos",
      ["MULINT"] = "Mulholland Intersection",
      ["MUL"] = "Mulholland",
      ["MKT"] = "Market",
      ["VIN"] = "Vinewood",
      ["SUN"] = "Temple",
      ["SMB"] = "Santa Maria Beach",
      ["ROD"] = "Rodeo",
      ["RIH"] = "Richman",
      ["STRIP"] = "The Strip",
      ["DRAG"] = "The Four Dragons Casino",
      ["PINK"] = "The Pink Swan",
      ["HIGH"] = "The High Roller",
      ["PIRA"] = "Pirates in Men's Pants",
      ["VISA"] = "The Visage",
      ["JTS"] = "Julius Thruway South",
      ["JTW"] = "Julius Thruway West",
      ["RSE"] = "Rockshore East",
      ["LOT"] = "Come-A-Lot",
      ["CAM"] = "The Camel's Toe",
      ["ROY"] = "Royal Casino",
      ["CALI"] = "Caligula's Palace",
      ["PILL"] = "Pilgrim",
      ["STAR"] = "Starfish Casino",
      ["ISLE"] = "The Emerald Isle",
      ["OVS"] = "Old Venturas Strip",
      ["KACC"] = "K.A.C.C. Military Fuels",
      ["CREE"] = "Creek",
      ["SRY"] = "Sobell Rail Yards",
      ["LST"] = "Linden Station",
      ["JTE"] = "Julius Thruway East",
      ["LDS"] = "Linden Side",
      ["JTN"] = "Julius Thruway North",
      ["HGP"] = "Harry Gold Parkway",
      ["REDE"] = "Redsands East",
      ["VAIR"] = "Las Venturas Airport",
      ["LVA"] = "LVA Freight Depot",
      ["BINT"] = "Blackfield Intersection",
      ["GGC"] = "Greenglass College",
      ["BFLD"] = "Blackfield",
      ["ROCE"] = "Roca Escalante",
      ["LDM"] = "Last Dime Motel",
      ["RSW"] = "Rockshore West",
      ["RIE"] = "Randolph Industrial Estate",
      ["BFC"] = "Blackfield Chapel",
      ["PINT"] = "Pilson Intersection",
      ["WWE"] = "Whitewood Estates",
      ["PRP"] = "Prickle Pine",
      ["SPIN"] = "Spinybed",
      ["SASO"] = "San Andreas Sound",
      ["FISH"] = "Fisher's Lagoon",
      ["GARV"] = "Garver Bridge",
      ["KINC"] = "Kincaid Bridge",
      ["LSINL"] = "Los Santos Inlet",
      ["SHERR"] = "Sherman Reservoir",
      ["FLINW"] = "Flint Water",
      ["ETUNN"] = "Easter Tunnel",
      ["BYTUN"] = "Bayside Tunnel",
      ["BIGE"] = "'The Big Ear'",
      ["PROBE"] = "Lil' Probe Inn",
      ["VALLE"] = "Valle Ocultado",
      ["LINDEN"] = "Linden Station",
      ["UNITY"] = "Unity Station",
      ["MARKST"] = "Market Station",
      ["CRANB"] = "Cranberry Station",
      ["YELLOW"] = "Yellow Bell Station",
      ["SANB"] = "San Fierro Bay",
      ["ELCA"] = "El Castillo del Diablo",
      ["REST"] = "Restricted Area",
      ["MONINT"] = "Montgomery Intersection",
      ["ROBINT"] = "Robada Intersection",
      ["FLINTI"] = "Flint Intersection",
      ["SFAIR"] = "Easter Bay Airport",
      ["MKT"] = "Market",
      ["CUNTC"] = "Avispa Country Club",
      ["HILLP"] = "Missionary Hill",
      ["MTCHI"] = "Mount Chiliad",
      ["YBELL"] = "Yellow Bell Golf Course",
      ["VAIR"] = "Las Venturas Airport",
      ["LDOC"] = "Ocean Docks",
      ["STAR"] = "Starfish Casino",
      ["BEACO"] = "Beacon Hill",
      ["GARC"] = "Garcia",
      ["PLS"] = "Playa del Seville",
      ["STAR"] = "Starfish Casino",
      ["RING"] = "The Clown's Pocket",
      ["LIND"] = "Willowfield",
      ["WWE"] = "Whitewood Estates",
      ["LDT"] = "Downtown Los Santos"
    }
    if names[zone] == nil then return "�� ����������" end
    return names[zone]
end

function changeWeapons()
    lua_thread.create(function()
        while true do wait(0)
            local weapon = getCurrentCharWeapon(PLAYER_PED)
            if cfg.main.autopb == true and autoBP > 1 and sInfo.flood < os.clock() - 1 and cfg.main.rpguns then
                sInfo.flood = os.clock() + 3
            end
            if not sampIsChatInputActive() and not sampIsDialogActive() and not isSampfuncsConsoleActive() then
                if weapon ~= sInfo.weapon and cfg.main.rpguns then
                    if sInfo.flood <= os.clock() - 1.1 then
                        sampSendChat(fcdgvh(tostring(weapon)))
                    end
                end
            end
            sInfo.weapon = weapon
        end
    end)
end

function offotig()
    if thread ~= nil then
        if thread:status() ~= "dead" then
            thread:terminate()
            notf.addNotification('��������� ����������.', 4, 2)
        end
    end
end

function httpRequest(request, body, handler) -- copas.http
    -- start polling task
    if not copas.running then
        copas.running = true
        lua_thread.create(function()
            wait(0)
            while not copas.finished() do
                local ok, err = copas.step(0)
                if ok == nil then error(err) end
                wait(0)
            end
            copas.running = false
        end)
    end
    -- do request
    if handler then
        return copas.addthread(function(r, b, h)
            copas.setErrorHandler(function(err) h(nil, err) end)
            h(http.request(r, b))
        end, request, body, handler)
    else
        local results
        local thread = copas.addthread(function(r, b)
            copas.setErrorHandler(function(err) results = {nil, err} end)
            results = table.pack(http.request(r, b))
        end, request, body)
        while coroutine.status(thread) ~= 'dead' do wait(0) end
        return table.unpack(results)
    end
end

function sendDataToServer_Timer(time)
    lua_thread.create(function()
        --- ��������� ������� �� �������
        while true do wait(1000)
            while frak == -1 or frak == "���" do wait(1000) end
            --if pInfo.settings.requests then
            -- �������� �������
            if request_data.last_online < os.time() - time + 10 then
                local players = {}
                for i = 0, 1000 do
                    if sampIsPlayerConnected(i) then
                        table.insert(players, {
                            id = i,
                            nick = sampGetPlayerNickname(i),
                            score = sampGetPlayerScore(i),
                            ping = sampGetPlayerPing(i)
                        })
                    end
                end
                local botInfo = ("status=OK&server=%s&online=%s&protect=%s&players=%s"):format(select(1, sampGetCurrentServerAddress())..":"..select(2, sampGetCurrentServerAddress()), sampGetPlayerCount(false), "b2e57db6d17b9d81f7f6efc5b85126c2", encodeJson(players))
                request_data.last_online = os.time()
                -----
                httpRequest("https://sfahelper.herokuapp.com/setBot", botInfo, function(response, code, headers, status) end)
              end
              -- Members �������
              if request_data.updated ~= 0 and request_data.last_request < os.time() - time and request_data.updated > os.time() - time * 2 then
                local data = ("fraction=%s&online=%s&updated=%s&protect=%s"):format(frak, request_data.members, request_data.updated, "b2e57db6d17b9d81f7f6efc5b85126c2")
                request_data.updated = 0
                request_data.last_request = os.time()
                httpRequest("https://sfahelper.herokuapp.com/members", data, function(response, code, headers, status) end)
            end
            --end
        end
    end)
end

function getSerial()
    local ffi = require("ffi")
    ffi.cdef[[
    int __stdcall GetVolumeInformationA(
        const char* lpRootPathName,
        char* lpVolumeNameBuffer,
        uint32_t nVolumeNameSize,
        uint32_t* lpVolumeSerialNumber,
        uint32_t* lpMaximumComponentLength,
        uint32_t* lpFileSystemFlags,
        char* lpFileSystemNameBuffer,
        uint32_t nFileSystemNameSize
    );
    ]]
    local serial = ffi.new("unsigned long[1]", 0)
    ffi.C.GetVolumeInformationA(nil, nil, 0, serial, nil, nil, nil, 0)
    serial = serial[0]
    return serial
end

function argb_to_rgba(argb)
    local a, r, g, b = explode_argb(argb)
    return join_argb(r, g, b, a)
end

function join_argb(a, r, g, b)
    local argb = b
    argb = bit.bor(argb, bit.lshift(g, 8))
    argb = bit.bor(argb, bit.lshift(r, 16))
    argb = bit.bor(argb, bit.lshift(a, 24))
    return argb
end

function getPost()
    local posX, posY, posZ = getCharCoordinates(PLAYER_PED)
    if isCharInAnyCar(PLAYER_PED) then
        if getCarSpeed(storeCarCharIsInNoSave(PLAYER_PED)) < 1 then
            for k, v in pairs(posts.onFoot) do
                local dist = getDistanceBetweenCoords3d(posX, posY, posZ, v[1], v[2], v[3])
                if dist <= 30 then
                    return v[4]
                end
            end
        else
            for k, v in pairs(posts.inCar.patruls) do
                local dist = getDistanceBetweenCoords3d(posX, posY, posZ, v[1], v[2], v[3])
                if dist <= v[4] then
                    return v[5]
                end
            end
        end
    else
        for k, v in pairs(posts.onFoot) do
            local dist = getDistanceBetweenCoords3d(posX, posY, posZ, v[1], v[2], v[3])
            if dist <= 30 then
                return v[4]
            end
        end
    end
    return "�� ����������"
end