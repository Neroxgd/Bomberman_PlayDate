SceneAurelien = {}
class("SceneAurelien").extends(NobleScene)

SceneAurelien.baseColor = Graphics.kColorWhite

local menu
local sequence



function SceneAurelien:init()
    SceneAurelien.super.init(self)

    self.tileSize = 16       -- la size d'une tile en pixels
    self.gameTileShiftX = 6  -- le décallage horizontale en nombre de tile
    self.gameTileShiftY = 1  -- le décallage verticale en nombre de tile
    self.gameTileWidth = 13  -- la largeur en nombre de tile
    self.gameTileHeight = 13 -- la hauteur en nombre de tile
    -- menu = Noble.Menu.new(false, Noble.Text.ALIGN_CENTER, false, Graphics.kColorWhite, 4, 6, 0, Noble.Text.FONT_SMALL)


    -- menu:addItem('Ⓐ Start Game', function()
    --     Noble.transition(World, 0.5, Noble.TransitionType.SLIDE_OFF_LEFT)
    -- end)

    SceneAurelien.inputHandler = {
        upButtonHold = function()
            print(self.player1.inputMovement.x )
            self.player1:Move(self.player1.inputMovement.x, -1)
        end,
        downButtonHold = function()
            self.player1:Move(self.player1.inputMovement.x, 1)
        end,
        leftButtonHold = function()
            self.player1:Move(-1, self.player1.inputMovement.y)
        end,
        rightButtonHold = function()
            self.player1:Move(1, self.player1.inputMovement.y)
        end
        -- AButtonDown = function()
        --     player1:dropBomb()
        -- end
    }

    self.gameTileTable = {}
    for i = 1, self.gameTileWidth, 1 do
        self.gameTileTable[i] = {}
        for j = 1, self.gameTileHeight, 1 do
            self.gameTileTable[i][j] = {}
        end
    end
end

function SceneAurelien:getPositionAtCoordinates(i, j)
    return ((i - 1) + 0.5 + self.gameTileShiftX) * self.tileSize,
        ((j - 1) + 0.5 + self.gameTileShiftY) * self.tileSize
end

function SceneAurelien:getcoordinates(x, y)
    return math.floor((x / self.tileSize) - self.gameTileShiftX + 1),
        math.floor((y / self.tileSize) - self.gameTileShiftY + 1)
end

function SceneAurelien:addElement(Type, i, j, ...)
    local tileSprites = self.gameTileTable[i][j]
    tileSprites[#tileSprites + 1] = Type(i, j, ...)
end

function SceneAurelien:getElementOfTypeAt(type, i, j)
    return getObjectOfClass(self.gameTileTable[i][j], type)
end

function SceneAurelien:updateFloor(i, j)
    local floor = self:getElementOfTypeAt(Floor, i, j)

    local caseTable = self.gameTileTable[i][j - 1]
    local shadow = containsClass(caseTable, Block)

    if floor then
        floor:setShadow(shadow)
    end
end

function SceneAurelien:enter()
    SceneAurelien.super.enter(self)
    playdate.graphics.setBackgroundColor(playdate.graphics.kColorBlack)
    -- SceneAurelien = self



    self.player1 = Player(2, 2, P1)
    -- sequence = Sequence.new():from(0):to(180, 1, Ease.outBounce)

    -- if sequence then sequence:start() end

    -- local sound = playdate.sound.sampleplayer
    -- self.backgroundMusic = sound.new('sounds/Title Screen.wav')
    -- self.backgroundMusic:setVolume(0.6)
    -- self.backgroundMusic:play(0, 1)

    -- self.background = NobleSprite("images/background2")

    -- self.background:add()
    -- self.background:moveTo(200, 120)

    for i = 1, self.gameTileWidth, 1 do
        self:addElement(UnbreakableBlock, i, 1)
        self:addElement(UnbreakableBlock, i, self.gameTileHeight)
    end

    -- add block on right and left
    for j = 2, self.gameTileHeight - 1, 1 do
        self:addElement(UnbreakableBlock, 1, j)
        self:addElement(UnbreakableBlock, self.gameTileWidth, j)
    end

    -- add block on middle
    for i = 3, self.gameTileWidth - 2, 2 do
        for j = 3, self.gameTileHeight - 2, 2 do
            self:addElement(UnbreakableBlock, i, j)
        end
    end

    -- add empty block around spawn player 1
    --self:addElement(NoBlock, 2, 2)
    --self:addElement(NoBlock, 3, 2)
    --self:addElement(NoBlock, 2, 3)

    -- add empty block around spawn player 2
    --self:addElement(NoBlock, self.gameTileWidth - 1, self.gameTileHeight - 1)
    --self:addElement(NoBlock, self.gameTileWidth - 1, self.gameTileHeight - 2)
    --self:addElement(NoBlock, self.gameTileWidth - 2, self.gameTileHeight - 1)

    --add BreakableBlock randomly
    local emptySpace = {}
    local emptySpaceIndex = 1

    for i = 2, self.gameTileWidth - 1, 1 do
        for j = 2, self.gameTileHeight - 1, 1 do
            if #self.gameTileTable[i][j] <= 0 then
                emptySpace[emptySpaceIndex] = { i, j }
                emptySpaceIndex = emptySpaceIndex + 1
            end
        end
    end

    local nbBloc = math.floor(#emptySpace * 0.6)

    while nbBloc ~= 0 do
        local elementsIndex = math.random(#emptySpace)
        local coord = table.remove(emptySpace, elementsIndex)
        local i, j = coord[1], coord[2]
        self:addElement(BreakableBlock, i, j)
        nbBloc = nbBloc - 1
    end

    for i = 2, self.gameTileWidth -1, 1 do
        for j = 2, self.gameTileHeight -1, 1 do
            self:addElement(Floor, i, j)
            self:updateFloor(i, j)
        end
    end
end

function SceneAurelien:start()
    SceneAurelien.super.start(self)
end

function SceneAurelien:drawBackground()
    SceneAurelien.super.drawBackground(self)
end

function SceneAurelien:update()
    SceneAurelien.super.update(self)
end

function SceneAurelien:exit()
    SceneAurelien.super.exit(self)
end

function SceneAurelien:finish()
    SceneAurelien.super.finish(self)
end
