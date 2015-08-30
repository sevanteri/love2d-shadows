local light = require('light')

local lightIndex = 1
local pressing = false
local lights = {
    light(256, 256, 256, {255,255,255}),
    light(400, 300, 256, {255,0,0,150}),
    light(200, 256, 215, {0,0,255,200})
    --light(200, 256, 256, {0,255,0,200}),
    --light(200, 256, 256, {10,10,10,200}),
    --light(200, 256, 256, {0,255,255,200})
}

local g = love.graphics

function love.load()
    love.window.setMode(800, 600)
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

end

function love.draw(dt)
    for i=1,#lights do
        lights[i]:drawShadows(objectCanvas)
    end
    g.setColor(50,50,50)
    g.draw(objectCanvas)

    --g.push()
    --g.scale(
        --objectCanvas:getWidth() / lights[lightIndex].size,
        --objectCanvas:getHeight() / lights[lightIndex].size
    --)
    --g.translate(
        ---(lights[lightIndex].x - lights[lightIndex].size/2),
        ---(lights[lightIndex].y - lights[lightIndex].size/2)
    --)
    --g.draw(objectCanvas)
    --g.pop()
end

function love.keyreleased(key)
    if key == "escape" then
        love.event.quit()
    end

    if key == '1' and lightIndex > 1 then
        lightIndex = lightIndex - 1
    elseif key == '2' and lightIndex < #lights then
        lightIndex = lightIndex + 1
    end
end

function love.mousemoved(x, y, dx, dy)
    if pressing then
        local l = lights[lightIndex]
        l.x = x
        l.y = y
    end
end

function love.mousepressed(x, y, b)
    if b then
        pressing = true
        local l = lights[lightIndex]
        l.x = x
        l.y = y
    end
end

function love.mousereleased(x, y, b)
    if b then
        pressing = false
    end
end
