shadowMapShader = require('shadowMapShader')
lightShader = require('lightShader')

light = {x = 256, y = 256, size = 512}

local g = love.graphics
function love.load()
    love.window.setMode(512, 512)
    Wwidth, Wheight = love.window.getDimensions()
    Xcenter, Ycenter = Wwidth/2, Wheight/2
    g.setBackgroundColor(200, 200, 200)

    objectCanvas = g.newCanvas(Wwidth, Wheight)
    objectCanvas :renderTo(function()
        g.setColor(50, 50, 50, 255)
        --local w = 8 h = 8
        --local pad = 40 s = 10
        --local circlesSize = function(x) return (1 + x) * pad; end
        --local xmargin = objectCanvas:getWidth()/2 - circlesSize(w)/2
        --local ymargin = objectCanvas:getHeight()/2 - circlesSize(h)/2
        --for i=1, w do
            --for j=1, h do
                --g.circle('fill',
                         --xmargin + i * pad,
                         --ymargin + j * pad,
                         --s)
            --end
        --end
        g.rectangle('fill', Xcenter - 100, Ycenter - 100, 50, 50)
        g.rectangle('fill', Xcenter + 50, Ycenter + 50, 50, 50)
        g.rectangle('fill', Xcenter - 50, Ycenter + 50, 50, 50)
    end)


    shadowMapCanvas = g.newCanvas(light.size, 1, g.rgba8)
    shadowMapCanvas:setFilter('linear', 'linear')
    shadowMapCanvas:setWrap('repeat', 'repeat')
    shadowMapShader:send('resolution', {light.size, light.size})
    lightShader:send('resolution', {light.size, light.size})
end

function setcam()
    g.push()
    --g.scale(
        --shadowMapCanvas:getWidth() / Wwidth,
        --shadowMapCanvas:getHeight() / Wheight
    --)
    g.translate(
        -(light.x - light.size/2),
        -(light.y - light.size/2)
    )
end

function unsetcam()
    g.pop()
end

function love.draw(dt)
    shadowMapCanvas:clear(255, 255, 255, 255)

    shadowMapCanvas:renderTo(function()
        g.setShader(shadowMapShader)
            setcam()
            g.draw(objectCanvas)
            unsetcam()

        g.setShader()
    end)
    g.draw(shadowMapCanvas, 0, 5)

    g.setShader(lightShader)
        g.setColor(255, 255, 255, 255)
        g.draw(
            shadowMapCanvas,
            light.x,
            light.y,
            0, --rot
            1,
            -light.size,
            shadowMapCanvas:getWidth()/2,
            shadowMapCanvas:getHeight()/2
        )
    g.setShader()

    setcam()
    g.draw(objectCanvas)
    unsetcam()

end

function love.update(dt)
    if love.keyboard.isDown('escape') then
        love.event.push('quit')
    end
end

function love.mousemoved(x, y, dx, dy)
    light.x = x
    --light.y = y
end
