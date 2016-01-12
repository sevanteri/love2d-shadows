local light = require('light')

local lightIndex = 1
local pressing = false
local lights = {
    light(256,  256,  256,  {255,  255,  255,  200}),
    light(200,  256,  215,  {0,    0,    255,  200}),
    light(0,    0,    400,  {255,  255,  0,    200}),
    light(800,  0,    500,  {200,  0,    200,  200}),
    light(0,    600,  300,  {0,    200,  200,  200})
}

local g = love.graphics

function love.load()
    love.window.setMode(800, 600)
    Wwidth, Wheight = g.getDimensions()
    Xcenter, Ycenter = Wwidth/2, Wheight/2
    g.setBackgroundColor(50, 50, 50)

    objectCanvas = g.newCanvas(Wwidth, Wheight)
    objectCanvas:renderTo(function()
        g.setColor(50, 50, 50, 255)
        local w = 8 h = 8
        local pad = 40 s = 10
        local circlesSize = function(x) return (1 + x) * pad; end
        local xmargin = objectCanvas:getWidth()/2 - circlesSize(w)/2
        local ymargin = objectCanvas:getHeight()/2 - circlesSize(h)/2
        for i=1, w do
            for j=1, h do
                g.circle('fill',
                         xmargin + i * pad,
                         ymargin + j * pad,
                         s)
            end
        end

        --g.rectangle('fill', Xcenter - 100, Ycenter - 100, 50, 50)
        --g.rectangle('fill', Xcenter + 50, Ycenter + 50, 50, 50)
        --g.rectangle('fill', Xcenter - 50, Ycenter + 50, 50, 50)
    end)

end

function love.draw(dt)
    for i=1,#lights do
        lights[i]:drawShadows(objectCanvas)
    end
    g.setColor(0, 0, 0)
    g.draw(objectCanvas)

    --g.setColor(255, 255, 255)
    --g.draw(lights[lightIndex].shadowMapCanvas, 0, 5)

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
        lights[lightIndex]:update(x, y)
    end
end

function love.mousepressed(x, y, b)
    if b then
        pressing = true
        lights[lightIndex]:update(x, y)
    end
end

function love.mousereleased(x, y, b)
    if b then
        pressing = false
    end
end
