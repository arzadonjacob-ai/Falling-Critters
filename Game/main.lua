

function love.load()
    grasshopperFace = love.graphics.newImage("grasshopper.png")
    backgroundImage = love.graphics.newImage("bg.png")
    powerupImage = love.graphics.newImage("powerup.png")

    -- Grasshopper size
    grasshopperScale = 0.1
    grasshopperWidth = grasshopperFace:getWidth() * grasshopperScale
    grasshopperHeight = grasshopperFace:getHeight() * grasshopperScale

    -- Power-up size
    powerupScale = 0.05
    powerupWidth = powerupImage:getWidth() * powerupScale
    powerupHeight = powerupImage:getHeight() * powerupScale

    -- Game settings
    grasshopperSpeed = 80
    slowSpeedMultiplier = 0.4
    slowDuration = 3
    slowTimer = 0

    -- Power-up settings
    powerupVisible = true
    powerupRespawnTimer = 0
    powerupRespawnDelay = math.random(4, 8)

    math.randomseed(os.time())
    math.random()
    math.random()
    math.random()

    -- Starting grasshopper positions
    startx = {}
    starty = {}

    for i = 1, 5 do
        startx[i] = math.random(
            0,
            love.graphics.getWidth() - grasshopperWidth
        )

        starty[i] = -math.random(
            grasshopperHeight,
            grasshopperHeight * 2
        )
    end

    -- Starting power-up position
    powerupX = math.random(
        0,
        love.graphics.getWidth() - powerupWidth
    )

    powerupY = math.random(
        0,
        love.graphics.getHeight() - powerupHeight
    )
end

-------------------------------------------------
-- PLACE POWER-UP AT A RANDOM POSITION
-------------------------------------------------
function respawnPowerup()
    powerupX = math.random(
        0,
        love.graphics.getWidth() - powerupWidth
    )

    powerupY = math.random(
        0,
        love.graphics.getHeight() - powerupHeight
    )

    powerupVisible = true
    powerupRespawnTimer = 0
    powerupRespawnDelay = math.random(4, 8)
end

-------------------------------------------------
-- MOUSE PRESS
-- 1 = left, 2 = right, 3 = middle wheel
-------------------------------------------------
function love.mousepressed(x, y, button, istouch)
    if button == 1 then

        -- Check whether the power-up was clicked
        if powerupVisible
        and x >= powerupX
        and x <= powerupX + powerupWidth
        and y >= powerupY
        and y <= powerupY + powerupHeight then

            powerupVisible = false
            slowTimer = slowDuration

            return
        end

        -- Check whether a grasshopper was clicked
        for i, v in ipairs(startx) do
            if x >= startx[i]
            and x <= startx[i] + grasshopperWidth
            and y >= starty[i]
            and y <= starty[i] + grasshopperHeight then

                -- Send grasshopper back above the screen
                starty[i] = -math.random(
                    grasshopperHeight,
                    grasshopperHeight * 2
                )

                break
            end
        end
    end
end

-------------------------------------------------
-- UPDATE
-------------------------------------------------
function love.update(dt)

    -- Update slow-motion timer
    if slowTimer > 0 then
        slowTimer = slowTimer - dt

        if slowTimer < 0 then
            slowTimer = 0
        end
    end

    -- Determine current grasshopper speed
    local currentSpeed = grasshopperSpeed

    if slowTimer > 0 then
        currentSpeed = grasshopperSpeed * slowSpeedMultiplier
    end

    -- Move grasshoppers and check for game over
    for i, v in ipairs(starty) do

        starty[i] = starty[i] + currentSpeed * dt

        if starty[i] + grasshopperHeight >= love.graphics.getHeight() then
            love.event.quit()
            return
        end
    end

    -- Handle power-up respawning
    if not powerupVisible then
        powerupRespawnTimer = powerupRespawnTimer + dt

        if powerupRespawnTimer >= powerupRespawnDelay then
            respawnPowerup()
        end
    end
end

-------------------------------------------------
-- DRAW
-------------------------------------------------
function love.draw()

    -- Draw background stretched to fill the window
    love.graphics.draw(
        backgroundImage,
        0, 0,
        0,
        love.graphics.getWidth() / backgroundImage:getWidth(),
        love.graphics.getHeight() / backgroundImage:getHeight()
    )

    -- Draw grasshoppers
    for i, v in ipairs(startx) do
        love.graphics.draw(
            grasshopperFace,
            startx[i],
            starty[i],
            0,
            grasshopperScale,
            grasshopperScale
        )
    end

    -- Draw power-up only when visible
    if powerupVisible then
        love.graphics.draw(
            powerupImage,
            powerupX,
            powerupY,
            0,
            powerupScale,
            powerupScale
        )
    end

    -- Show slow-motion status
    if slowTimer > 0 then
        love.graphics.setColor(0.4, 0.8, 1)
        love.graphics.print(
            "SLOW MOTION: " .. string.format("%.1f", slowTimer),
            10,
            10
        )
        love.graphics.setColor(1, 1, 1)
    end
end