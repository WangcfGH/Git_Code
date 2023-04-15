
--[[
package.cpath = package.cpath .. ';C:\\Program Files (x86)\\Lua\\5.1\\clibs\\?.dll;?.dll'
local socket = require "socket.core"
local curTime = socket.gettime()
print(curTime)

server_ip =
{
	-- "129.6.15.29",
	"132.163.4.101",
	"132.163.4.102",
	"132.163.4.103",
	"128.138.140.44",
	"192.43.244.18",
	"131.107.1.10",
	"66.243.43.21",
	"216.200.93.8",
	"208.184.49.9",
	"207.126.98.204",
	"207.200.81.113",
	"205.188.185.33"
}

function nstol(str)
    assert(str and #str == 4)
    local t = {str:byte(1,-1)}
    local n = 0
    for k = 1, #t do
        n= n*256 + t[k]
    end
    return n
end

-- get time from a ip address, use tcp protocl
function gettime(ip)
    print('connect ', ip)
    local tcp = socket.tcp()
    tcp:settimeout(10)
    tcp:connect(ip, 37)
    success, time = pcall(nstol, tcp:receive(4))
    tcp:close()
    return success and time or nil
end

function nettime()
    for _, ip in pairs(server_ip) do
        time = gettime(ip)
        if time then
            return time
        end
    end
end


local curTime = nettime()
print(curTime)


local timeNum = os.time()
print(timeNum)



local timeNum = os.time()
print(timeNum)
math.randomseed(timeNum)
local randIndex = math.random(77, 80)
print(randIndex)
--]]


local openTime = 9002200
local startHour = math.modf(openTime/1000000)
local startMinute = math.modf((openTime % 1000000) / 10000)
local endHour = math.modf((openTime % 10000) / 100)
local endMinute = openTime % 100
print("startHour:"..startHour.."  startMinute:"..startMinute.."  endHour:"..endHour.."  endMinute:"..endMinute)

local curTime = os.date("%Y%m%d%H%M%S", 1618394959)
print(curTime)
local curTimeStamp = curTime.time()
print(curTimeStamp)

