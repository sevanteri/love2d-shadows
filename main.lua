local camera = require('libs.hump.camera')

local shadowMapShader = require('shadowMapShader')
local lightShader = require('lightShader')

local lightIndex = 1
local lights = {
    {
        x = 256,
        y = 256,
        size = 512,
        color = {255, 255, 255, 255}
    },
    {
        x = 400,
        y = 256,
        size = 256,
        color = {255, 0, 0, 200}
    }
}

local g = love.graphics

function love.load()
    love.window.setMode(512, 512)
    Wwidth, Wheight = love.window.getDimensions()
    Xcenter, Ycenter = Wwidth/2, Wheight/2
    g.setBackgroundColor(200, 200, 200)

    objectCanvas = g.newCanvas(Wwidth, Wheight)
    objectCanvas:renderTo(function()
        g.setColor(50, 50, 50, 255)
        g.rectangle('fill', Xcenter - 100, Ycenter - 100, 50, 50)
        g.rectangle('fill', Xcenter + 50, Ycenter + 50, 50, 50)
        g.rectangle('fill', Xcenter - 50, Ycenter + 50, 50, 50)
    end)

    -- setup lights
    for _, l in ipairs(lights) do
        l.cam = camera.new(l.x, l.y, Wwidth / l.size)
        l.occlusionCanvas = g.newCanvas(l.size, l.size, g.rgba8)
        l.shadowMapCanvas = g.newCanvas(l.size, 1, g.rgba8)
        l.shadowMapCanvas:setFilter('linear', 'linear')
        l.shadowMapCanvas:setWrap('repeat', 'repeat')
    end

end

function love.draw(dt)
    for i, l in ipairs(lights) do
        l.occlusionCanvas:clear()
        l.occlusionCanvas:renderTo(function()
            l.cam:draw(function()
                local xr = l.occlusionCanvas:getWidth() / objectCanvas:getWidth()
                local yr = l.occlusionCanvas:getHeight() / objectCanvas:getHeight()
                g.draw(
                    objectCanvas,
                    (1 - xr) * (l.x - l.size/2),
                    (1 - yr) * (l.y - l.size/2),
                    0,
                    xr,
                    yr
                )
            end)
        end)

        l.shadowMapCanvas:clear()
        l.shadowMapCanvas:renderTo(function()
            g.setShader(shadowMapShader)
            shadowMapShader:send('resolution', {l.size, l.size})
            g.draw(l.occlusionCanvas)
            g.setShader()
        end)
        g.setColor(255,255,255)
        g.draw(l.shadowMapCanvas, 0, 5 + i)

        g.setShader(lightShader)
        lightShader:send('resolution', {l.size, l.size})
        g.setColor(l.color)
        g.draw(
            l.shadowMapCanvas,
            l.x,
            l.y,
            0, --rot
            1,
            -l.size,
            l.size/2,
            0.5
        )
        g.setShader()

    end
    g.setColor(50,50,50)
    g.draw(objectCanvas)

    --lights[lightIndex].cam:draw(function() g.draw(objectCanvas) end)
end

isDown = love.keyboard.isDown
function love.update(dt)
    if isDown('1') then
        lightIndex = 1
    elseif isDown('2') then
        lightIndex = 2
    end

    if isDown('escape') then
        love.event.push('quit')
    end
end

function love.mousemoved(x, y, dx, dy)
    lights[lightIndex].x = x
    lights[lightIndex].y = y
    lights[lightIndex].cam:lookAt(x, y)
end
