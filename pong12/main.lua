WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

PADDLE_SPEED = 200


Class = require 'class'
push = require 'push'

require 'Ball'
require 'Paddle'


function love.load()
    love.window.setTitle("Pong!")
    math.randomseed(os.time())
    love.graphics.setDefaultFilter('nearest','nearest')

    smallFont = love.graphics.newFont('font.otf', 8)
    victoryFont = love.graphics.newFont('font.otf',24)
    scoreFont = love.graphics.newFont('font.otf', 32)

    player1score = 0
    player2score = 0

    servingPlayer = math.random(2) == 1 and 1 or 2

    winningPlayer = 0

    paddle1 = Paddle(5, 20, 5, 20)
    paddle2 = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 30, 5, 20)

    ball = Ball(VIRTUAL_WIDTH /2 -2, VIRTUAL_HEIGHT /2 -2, 5, 5)

    if servingPlayer == 1 then
        ball.dx = 100
    else
        ball.dx = -100
    end


    gameState = 'start'


    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT,{
        fullscreen = false,
        vsync = true,
        resizable = true
    })

    sounds = {
        ['paddlehit'] = love.audio.newSource('paddlehit.wav', 'static'),
        ['pointscore'] = love.audio.newSource('pointscore.wav', 'static'),
        ['wallhit'] = love.audio.newSource('wallhit.wav', 'static')
    }
end

function love.resize(w,h)
    push:resize(w,h)
end

function love.update(dt)
    if gameState == 'play' then
        if ball.x <= 0 then
            player2score = player2score + 1
            sounds['pointscore']:play()
            servingPlayer = 1
            ball:reset()
            if player2score >= 10 then
                gameState = 'victory'
                winningPlayer = 2
            else
                gameState = 'serve'
            end
        end

        if ball.x>= VIRTUAL_WIDTH - 5 then
            player1score = player1score + 1
            sounds['pointscore']:play()
            servingPlayer = 2
            ball:reset()
            if player1score >= 10 then
                gameState = 'victory'
                winningPlayer = 1
            else
                gameState = 'serve'
            end
        end
    end


    if ball:collides(paddle1) then
        ball.dx = -ball.dx
        sounds['paddlehit']:play()
    end

    if ball:collides(paddle2) then
        ball.dx = -ball.dx
        sounds['paddlehit']:play()
    end

    if ball.y <= 0 then
        ball.dy = -ball.dy
        ball.y = 0
        sounds['wallhit']:play()
    end

    if ball.y >= VIRTUAL_HEIGHT - 5 then
        ball.dy = -ball.dy
        ball.y = VIRTUAL_HEIGHT - 5
        sounds['wallhit']:play()
    end


    paddle1:update(dt)
    paddle2:update(dt)

    if love.keyboard.isDown('w') then
        paddle1.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('s') then
        paddle1.dy = PADDLE_SPEED
    else
        paddle1.dy = 0
    end

    if love.keyboard.isDown('up') then
        paddle2.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('down') then 
        paddle2.dy = PADDLE_SPEED
    else
        paddle2.dy = 0
    end

    if gameState == 'play' then 
        ball:update(dt)
    end
end 


function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()

    elseif key == 'enter' or key == 'return' then
        if gameState == 'start' then
            gameState = 'serve'
        elseif gameState == 'victory' then
            gameState = 'start'
            player1score = 0
            player2score = 0
        elseif gameState == 'serve' then
            gameState = 'play'
        end

    end
end

function love.draw()
    push:apply('start')

    love.graphics.clear(192/255, 192/255, 192/255, 1)

    paddle1:render()
    paddle2:render()
    ball:render()

    displayFPS()
    

    


    love.graphics.setFont(smallFont)
    if gameState == 'start' then
        love.graphics.printf("Welcome to Pong!", 0, 20, VIRTUAL_WIDTH,'center')
        love.graphics.printf("Press Enter to Play!", 0, 32, VIRTUAL_WIDTH, 'center')
    elseif gameState =='serve' then
        love.graphics.printf("Player ".. tostring(servingPlayer) .. "'s turn", 0, 20, VIRTUAL_WIDTH,'center')
        love.graphics.printf("Press Enter to Serve!",0,32, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'victory' then
        love.graphics.setFont(victoryFont)
        love.graphics.printf("Player ".. tostring(winningPlayer) .. "wins", 0, 20, VIRTUAL_WIDTH,'center')
        love.graphics.setFont(smallFont)
        love.graphics.printf("Press Enter to Restart!",0,42, VIRTUAL_WIDTH, 'center')
    end


    love.graphics.setFont(scoreFont)
    love.graphics.print(player1score , VIRTUAL_WIDTH/2 - 50, VIRTUAL_HEIGHT/3)
    love.graphics.print(player2score, VIRTUAL_WIDTH/2 + 30, VIRTUAL_HEIGHT/ 3)

    push:apply('end')
end

function displayFPS()
    love.graphics.setColor(1, 0, 0, 1)
    love.graphics.setFont(smallFont)
    love.graphics.print('FPS: '..tostring(love.timer.getFPS()), 40, 20)
    love.graphics.setColor(1,1,1,1)
end
