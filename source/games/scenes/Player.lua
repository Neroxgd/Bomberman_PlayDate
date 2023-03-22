class('Player').extends(AnimatedSprite)

P1, P2 = 0, 1

playerImagetable = playdate.graphics.imagetable.new('images/character-table-32-32.png')

function Player:init(i, j, player)
    Player.super.init(self, playerImagetable)

    self.nbBombMax = 1
    self.power = 1
    self.maxSpeed = 2
    self.canKick = false
    self.isDead = false

    local x, y = Noble.currentScene():getPositionAtCoordinates(i, j)
    print(self.className)

    self:moveTo(x, y - 8)
    self:playAnimation()
    self:setZIndex(10)

    self:setCollideRect(8, 16, 16, 16)

    self:setZIndex(10)

    local playerShiftSpriteSheet = player == P1 and 0 or 5
    local animationSpeed = 5

    self.inputMovement = playdate.geometry.vector2D.new(0, 0)

    self:addState("dead", 64 + playerShiftSpriteSheet, 67 + playerShiftSpriteSheet, {
        tickStep = animationSpeed,
        loop = false
    })

    self:addState('IdleUp', 1 + playerShiftSpriteSheet, 1 + playerShiftSpriteSheet, {
        tickStep = animationSpeed
    })
    self:addState('RunUp', 1, 3, {
        tickStep = animationSpeed,
        yoyo = true,
        frames = { 2 + playerShiftSpriteSheet, 1 + playerShiftSpriteSheet, 3 + playerShiftSpriteSheet }
    })

    self:addState('IdleRight', 10 + playerShiftSpriteSheet, 10 + playerShiftSpriteSheet, {
        tickStep = animationSpeed
    })
    self:addState('RunRight', 1, 3, {
        tickStep = animationSpeed,
        yoyo = true,
        frames = { 11 + playerShiftSpriteSheet, 10 + playerShiftSpriteSheet, 12 + playerShiftSpriteSheet }
    })

    -- default state
    self:addState('IdleDown', 19 + playerShiftSpriteSheet, 19 + playerShiftSpriteSheet, {
        tickStep = animationSpeed
    }).asDefault()
    self:addState('RunDown', 1, 3, {
        tickStep = animationSpeed,
        yoyo = true,
        frames = { 20 + playerShiftSpriteSheet, 19 + playerShiftSpriteSheet, 21 + playerShiftSpriteSheet }
    })

    self:addState('IdleLeft', 28 + playerShiftSpriteSheet, 28 + playerShiftSpriteSheet, {
        tickStep = animationSpeed
    })
    self:addState('RunLeft', 1, 3, {
        tickStep = animationSpeed,
        yoyo = true,
        frames = { 29 + playerShiftSpriteSheet, 28 + playerShiftSpriteSheet, 30 + playerShiftSpriteSheet }
    })

    self.lastDirection = "Up"
    self.lastDirection = "Right"
    self.lastDirection = "Down"
    self.lastDirection = "Left"
end

function Player:Move(x, y)
    print(x .. " " .. y)
    local inputMovement = playdate.geometry.vector2D.new(x, y)
    inputMovement:normalize()
    self.inputMovement = inputMovement
end

function Player:update()
    Player.super.update(self)

    if self.inputMovement.y < 0 then
        self:changeState('RunUp', true)
        self.lastDirection = "Up"
    elseif self.inputMovement.x > 0 then
        self:changeState('RunRight', true)
        self.lastDirection = "Right"
    elseif self.inputMovement.y > 0 then
        self:changeState('RunDown', true)
        self.lastDirection = "Down"
    elseif self.inputMovement.x < 0 then
        self:changeState('RunLeft', true)
        self.lastDirection = "Left"
    else
        self:changeState('Idle' .. self.lastDirection, true)
    end

    local x, y, _, _ = self:moveWithCollisions(
        self.x + self.inputMovement.x * self.maxSpeed,
        self.y + self.inputMovement.y * self.maxSpeed
    )

    self.inputMovement.x = 0
    self.inputMovement.y = 0



    if self.isDead then
        self:changeState('dead', true)
        return
    end

    if (self.inputMovement.x ~= 0 and self.inputMovement.y == 0)
        or (self.inputMovement.y ~= 0 and self.inputMovement.x == 0) then
        -- on crée un rect avec la position du player,
        -- et la position du player +  un offset en fonction de playerInput
        -- !!! pour l'instant notre rect à une aire de zéro,
        -- car les deux points sont soit tous les deux sur l'axe x, ou sur l'axe y
        local rect = getRect(
            self.x,
            self.y + 8,
            self.x + self.inputMovement.x * 16,
            self.y + 8 + self.inputMovement.y * 16
        )

        -- on ajoute ici 2 pixels de largeur et de hauteur à notre rect
        -- pour prendre en compte une zone plus large
        rect.x = rect.x - 1
        rect.y = rect.y - 1
        rect.w = rect.w + 2
        rect.h = rect.h + 2


        -- On detecte les sprite en collision avec notre rect
        local collisions = playdate.graphics.sprite.querySpritesInRect(rect)

        -- Si un des sprite en collision avec le player et du type Block
        -- On set la variable isObstacleFront à true
        local isObstacleFront = false
        if collisions then
            for i = 1, #collisions, 1 do
                if collisions[i]:isa(Block) then
                    isObstacleFront = true
                    break
                end
            end
        end


        --si on n'a pas d'obstacle
        if not isObstacleFront then
            -- en fonction de si on se déplace horizontalement ou verticalement,
            -- on force la position en y ou en x à notre grid
            if self.lastDirection == "Left" or self.lastDirection == "Right" then
                local i, j = Noble.currentScene():getcoordinates(self.x, self.y + 8)
                local _, y = Noble.currentScene():getPositionAtCoordinates(i, j)
                self:moveTo(self.x, y - 8)
            end
            if self.lastDirection == "Up" or self.lastDirection == "Down" then
                local i, j = Noble.currentScene():getcoordinates(self.x, self.y + 8)
                local x, _ = Noble.currentScene():getPositionAtCoordinates(i, j)
                self:moveTo(x, self.y)
            end
        end
    end

    local x, y, _, _ = self:moveWithCollisions(
        self.x + self.inputMovement.x * self.maxSpeed,
        self.y + self.inputMovement.y * self.maxSpeed
    )
end
