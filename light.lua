local shadowMapShader = require('shadowMapShader')
local lightShader = require('lightShader')

local light = {}
light.__index = light

local g = love.graphics

local function new(x, y, size, color)
    x = x or g.getWidth()/2
    y = y or g.getHeight()/2
    size = size or 256
    color = color or {255, 255, 255}

    local shadowMapCanvas = g.newCanvas(size, 1, g.rgba8)
    shadowMapCanvas:setFilter('linear', 'linear')
    shadowMapCanvas:setWrap('repeat', 'repeat')
    return setmetatable({
        x = x,
        y = y,
        size = size,
        color = color,
        occlusionCanvas = g.newCanvas(size, size, g.rgba8),
        shadowMapCanvas = shadowMapCanvas
    }, light)
end

function light:update(x, y)
    self.x = x
    self.y = y
end

function light:drawOcclusionCanvas(objCanvas)
    self.occlusionCanvas:clear()
    self.occlusionCanvas:renderTo(function()
        g.push()
        g.scale(
            objCanvas:getWidth() / self.size,
            objCanvas:getHeight() / self.size
        )
        g.translate(
            -(self.x - self.size/2),
            -(self.y - self.size/2)
        )

        local xr = self.occlusionCanvas:getWidth() / objCanvas:getWidth()
        local yr = self.occlusionCanvas:getHeight() / objCanvas:getHeight()
        love.graphics.draw(
            objCanvas,
            (1 - xr) * (self.x - self.size/2),
            (1 - yr) * (self.y - self.size/2),
            0,
            xr,
            yr
        )

        g.pop()
    end)
end

function light:drawShadowMapCanvas(occCanvas)
    self.shadowMapCanvas:clear()
    self.shadowMapCanvas:renderTo(function()
        g.setShader(shadowMapShader)
        shadowMapShader:send('resolution', {self.size, self.size})
        g.draw(self.occlusionCanvas)
        g.setShader()
    end)
end

function light:drawLight(shadowMapCanvas)
    g.setShader(lightShader)
    lightShader:send('resolution', {self.size, self.size})
    g.setColor(self.color)
    g.draw(
        shadowMapCanvas,
        self.x,
        self.y,
        0, --rot
        1,
        -self.size,
        self.size/2,
        shadowMapCanvas:getHeight()/2
    )
    g.setShader()
end

function light:drawShadows(objCanvas)
    self:drawOcclusionCanvas(objCanvas)
    self:drawShadowMapCanvas(self.occlusionCanvas)
    self:drawLight(self.shadowMapCanvas)
end

return setmetatable({new = new}, {__call = function(_, ...) return new(...) end})
