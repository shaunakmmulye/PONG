push = require 'push'
class = require 'class'


require 'Ball'
require 'Paddle'


MAX_WIDTH = 1280
MAX_HEIGHT = 720


VIRTUAL_HEIGHT = 243
VIRTUAL_WIDTH = 342
PADDLE_SPEED = 200


function love.load()

    love.window.setTitle('Pong')

    love.graphics.setDefaultFilter('nearest', 'nearest')

    math.randomseed(os.time())

    pixelFont = love.graphics.newFont('font.ttf', 8)

    basicFont = love.graphics.newFont('font.ttf', 16)

    scoreFont = love.graphics.newFont('font.ttf', 32)

    pixelFont:setFilter('nearest', 'nearest')

    love.graphics.setFont(pixelFont)

    sounds = {
        ['paddle_hit'] = love.audio.newSource('sounds/paddle_hit.wav', 'static'),

        ['score'] = love.audio.newSource('sounds/score.wav', 'static'),

        ['wall_hit'] = love.audio.newSource('sounds/wall_hit.wav', 'static')
    }

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, MAX_WIDTH, MAX_HEIGHT,
        {
            fullscreen = false,
            resizable = true,
            vsync = true
        })

    player1Score = 0
    player2Score = 0

    player1 = Paddle(10, 30, 5, 20)
    player2 = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 30, 5, 20)

    ball = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 4, 4)

    gameState = 'start'
end

function love.resize(w, h)
    push:resize(w, h)
end

function love.update(dt)
   
   
    player1:update(dt)
    player2:update(dt)


    if gameState == 'play' then
      
        ball:update(dt)


        if ball:collides(player1) then
            ball.dx = -ball.dx * 1.03
            ball.x = player1.x + 4

            if ball.dy < 0 then
                ball.dy = -math.random(10, 100)
            else
                ball.dy = math.random(10, 100)
            end

            sounds['paddle_hit']:play()
        end


        if ball:collides(player2) then
            ball.dx = -ball.dx * 1.03
            ball.x = player2.x - 4

            if ball.dy < 0 then
                ball.dy = -math.random(10, 100)
            else
                ball.dy = math.random(10, 100)
            end
            sounds['paddle_hit']:play()
        end
        if ball.y <= 0 then
            ball.y = 0
            ball.dy = -ball.dy
            sounds['wall_hit']:play()
        end
        if ball.y >= VIRTUAL_HEIGHT - 4 then
            ball.y = VIRTUAL_HEIGHT - 4
            ball.dy = -ball.dy
            sounds['wall_hit']:play()
        end
        if ball.x < 0 then
            player2Score = player2Score + 1
            sounds['score']:play()

            if player2Score == 10 then
                winningPlayer = 2
                gameState = 'done'
            else
                ball:reset()
            end
        end
        if ball.x > VIRTUAL_WIDTH then
            player1Score = player1Score + 1
            sounds['score']:play()
            if player1Score == 10 then
                winningPlayer = 1
                gameState = 'done'
            else
                ball:reset()
            end
        end


        if love.keyboard.isDown('up') then
            player1.dy = -PADDLE_SPEED
        elseif love.keyboard.isDown('down') then
            player1.dy = PADDLE_SPEED
        else
            player1.dy = 0
        end

        if ball.y < player2.y then
            player2.dy = -player2.y - player2.dy * dt
        elseif ball.y > player2.y then
            player2.dy = player2.y + player2.dy * dt
        else
            player2.dy = 0
        end
        -- if ball.y < player1.y then
        --     player1.dy = -player1.y - player1.dy * dt
        -- elseif ball.y > player1.y then
        --     player1.dy = player1.y + player1.dy * dt
        -- else
        --     player1.dy = 0
        -- end
    end
end

function love.keypressed(key)

    if key == 'escape' then
        love.event.quit()
    elseif key == 'enter' or key == 'return' then
        if gameState == 'start' then
            gameState = 'play'
            ball:reset()
        elseif gameState == 'done' then
            gameState = 'start'

            player1Score = 0
            player2Score = 0

            ball:reset()
        end
    end
end

function love.draw()
    push:apply('start')

    love.graphics.clear(128 / 255, 0 / 255, 128 / 255, 255 / 255)

    love.graphics.setFont(pixelFont)

    love.graphics.printf('PONG', 0, VIRTUAL_HEIGHT - 30, VIRTUAL_WIDTH, 'center')
    
    if gameState == 'start' then
        love.graphics.printf('Press Enter to start', 0, 15, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'done' then
        love.graphics.setFont(scoreFont)
        if winningPlayer == 1 then
            love.graphics.printf('YOU WIN!', 0, 30, VIRTUAL_WIDTH, 'center')
        elseif winningPlayer == 2 then
            love.graphics.printf('YOU LOSE!', 0, 30, VIRTUAL_WIDTH, 'center')
        end
    end

    love.graphics.setFont(scoreFont)

    love.graphics.print(tostring(player1Score), VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 3)
    love.graphics.print(tostring(player2Score), VIRTUAL_WIDTH / 2 + 30, VIRTUAL_HEIGHT / 3)

    player1:render()
    player2:render()   
    ball:render()

    displayFPS()

    push:apply('end')
end

function displayFPS()
    love.graphics.setFont(pixelFont)
    love.graphics.setColor(255 / 255, 255 / 255, 255 / 255, 255 / 255)
    love.graphics.print(tostring(love.timer.getFPS()) .. 'FPS', 30, 10)
end
