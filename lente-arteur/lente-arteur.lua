--
-- Config
--

local isDebugMode = true
local cakeSlot = 1
local fireworkSlot = 16
local cycleType = "lane"
local cycleLength = {11}
local infiniteLaneOverflowThreshold = 50
local postCycleSleep = 5


--
-- Imports
--

local robotApi = require("robot")


--
-- Declarations
--

-- None


--
-- Tables
--

local cycles = {
  square = squareCycle ,
  lane = laneCycle,
  laneBF = laneBFCycle
}


--
-- Fonctions
--

function boot()
  logDebug("Start : boot")

  realign()
  
  logDebug("End : boot")
end

function realign()
  logDebug("Start : realign")
  logDebug("End : realign")
end

function cycle(cycleType,cycleLength)
  logDebug("Start : cycle")
  logDebug("cycleType: " .. cycleType)
  logDebug("cycleLength: " .. cycleLength[0])
  
  local cycleFct = cycles[cycleType]
  logDebug("cycleFct: " .. cycleFct)
  cycleFct(cycleLength) 

  logDebug("End : cycle")
end

function restock()
  logDebug("Start : restock")
  logDebug("End : restock")
end

function squareCycle(length)
  logDebug("Start : squareCycle")
  logDebug("End : squareCycle")
end

function laneBFCycle(length)
  logDebug("Start : laneBFCycle")
  
  local isBackAndForth = true
  laneCycle(length, isBackAndForth)
  
  logDebug("End : laneBFCycle")
end

function laneCycle(length, isBackAndForth)
  logDebug("Start : laneCycle")
  local cycleEnd = false
  local laneEnd = false
  local laneEndCpt = 0
  local isObstruct = false
  local typeDetect = ""
  local isCountBased = length[0] >= 0
  local stepCount = 0
  isBackAndForth = isBackAndForth or false
  
  while not cycleEnd do

    laneEnd = false
    
    while not laneEnd do
      -- Movement
      robotApi.forward()
      isObstruct, typeDetect = robotApi.detectDown()
      logDebug("Detected Down : " .. typeDetect)
      
      if typeDetect == "air" then
        placeCake()
      end
      
      -- Lane Status
      stepCount = stepCount + 1
      checkInfiniteLaneOverflow(step, infiniteLaneOverflowThreshold)
      
      laneEnd = isCountBased and stepCount > length[0]
      laneEnd = laneEnd or (not isCountBased and infiniteLaneEnd() )

    end
      
    -- Cycle Status
    cycleEnd = (isBackAndForth) and (laneEndCpt > 1) or (laneEndCpt > 0)
    
    -- End Actions
    stepCount = 0
    
  end
  
  logDebug("End : laneCycle")
end

function placeCake()
  robotApi.select(cakeSlot)
  robotApi.placeDown()
end

function infiniteLaneEnd()
  local isObstruct = robotApi.detect()
  return isObstruct;
end

function checkInfiniteLaneOverflow(step, threshold)
  threshold = threshold or 2000
  if step > threshold then
    print("Infinite Lane Overflow")
    robotApi.turnAround()
    launchFirework()
    os.exit(false)
  end
end

function launchFirework()
  robotApi.select(fireworkSlot)
  robotApi.useUp()
end

function logDebug(message)
  if isDebugMode then
    print(message)
  end
end


--
-- Program
--

boot()

while true do
  restock()
  cycle(cycleType,cycleLength)
  sleep(postCycleSleep)
end