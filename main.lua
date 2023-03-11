local imgui = require 'imgui'
local encoding = require 'encoding'
encoding.default = 'CP1251'
u8 = encoding.UTF8

local window = imgui.ImBool(false)

local cross = imgui.CreateTextureFromFile(getWorkingDirectory() .. "\\resource\\krestikinoliki\\krestik.png")
local zero = imgui.CreateTextureFromFile(getWorkingDirectory() .. "\\resource\\krestikinoliki\\nolik.png")

local gamestate = 1

local winner = ""

local huPlayer = ""
local aiPlayer = ""

local field = {
    {{cell = nil}, {cell = nil}, {cell = nil}},
    {{cell = nil}, {cell = nil}, {cell = nil}}, 
    {{cell = nil}, {cell = nil}, {cell = nil}}
}

local board = {1, 2, 3, 4, 5, 6, 7, 8, 9}

local step = "X"

function main()
    while not isSampAvailable() do wait(200) end
    imgui.Process = false 
    
    sampRegisterChatCommand('tictactoe', function()
        window.v = not window.v
    end)

    while true do
        wait(0)
        imgui.Process = window.v
    end
end

function imgui.OnDrawFrame()
    local sizex, sizey = 200, 200
    if gamestate == 1 then sizex, sizey = 250, 150 end
    if gamestate == 2 then sizex, sizey = 200, 200 end
    if gamestate == 3 then sizex, sizey = 200, 230 end
    if window.v then
        imgui.SetNextWindowPos(imgui.ImVec2(350.0, 250.0), imgui.Cond.FirstUseEver)
        imgui.SetNextWindowSize(imgui.ImVec2(sizex, sizey))
        imgui.Begin('tic tac toe', window, imgui.WindowFlags.NoScrollbar)

        if gamestate == 1 then
            imgui.Text(u8'������ ������ �����!')
            imgui.NextColumn()
            
            imgui.SetCursorPos(imgui.ImVec2(10, 45))
            imgui.Image(cross, imgui.ImVec2(50, 50))

            imgui.SetCursorPos(imgui.ImVec2(10, 45))
            if imgui.InvisibleButton("x", imgui.ImVec2(50, 50)) then
                huPlayer = "X"
                aiPlayer = "O"
                gamestate = 2
                step = huPlayer
            end

            imgui.SameLine()

            imgui.SetCursorPos(imgui.ImVec2(65, 45))
            imgui.Image(zero, imgui.ImVec2(50, 50))

            imgui.SetCursorPos(imgui.ImVec2(65, 45))
            if imgui.InvisibleButton("o", imgui.ImVec2(50, 50)) then
                huPlayer = "O"
                aiPlayer = "X"
                gamestate = 2
                step = aiPlayer 
                doStep()
            end
        end

        if gamestate == 2 or gamestate == 3 then
            for i=1, 3 do
                for j=1, 3 do
                    imgui.Cell(i, j)
                end
            end
            if gamestate == 3 then
                imgui.NewLine()
                imgui.Text("Winner: " .. winner)
                if imgui.Button('restart', imgui.ImVec2(100, 25)) then
                    restart()
                end
            end
        end

        imgui.End()
    end
end

function restart()
    gamestate = 1
    field = {
        {{cell = nil}, {cell = nil}, {cell = nil}},
        {{cell = nil}, {cell = nil}, {cell = nil}}, 
        {{cell = nil}, {cell = nil}, {cell = nil}}
    }
    
    board = {1, 2, 3, 4, 5, 6, 7, 8, 9}
    
    step = "X"
    
    winner = ""
end

function imgui.Cell(x, y)
    local posy = 10 + x*36
    local posx = 10 + y*36
    local dl = imgui.GetWindowDrawList()
    imgui.SetCursorPos(imgui.ImVec2(posx, posy))
    local p = imgui.GetCursorScreenPos()
    dl:AddRect(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 35, p.y + 35), 0xFF0000FF, 2, -1, 1);
    imgui.SetCursorPos(imgui.ImVec2(posx + 5, posy + 4))
    if field[x][y].cell == "X" then
        imgui.Image(cross, imgui.ImVec2(25, 25))
    else if field[x][y].cell == "O" then
            imgui.Image(zero, imgui.ImVec2(25, 25))
        end
    end
    imgui.SetCursorPos(imgui.ImVec2(posx, posy))
    if imgui.InvisibleButton(x .. y, imgui.ImVec2(35, 35)) then
        if step == huPlayer then
            if field[x][y].cell == nil then
                field[x][y].cell = step
                board[((x-1)*3)+y] = step
                step = aiPlayer
                if winning(board, huPlayer) then
                    gamestate = 3
                    winner = "player"
                end
                if winning(board, aiPlayer) then
                    gamestate = 3
                    winner = "ai"
                end
                local t = emptyIndexies(board)
                if #t == 0 then
                    gamestate = 3
                    winner = "draw"
                end
                doStep()
            end
        end
    end
end

function doStep()
    local i = minimax(board, aiPlayer).index
    if i == nil then return end
    local x = math.ceil(i / 3)
    local y = (i) % 3
    if y == 0 then y = 3 end
    board[i] = step
    field[x][y].cell = step
    step = huPlayer
    if winning(board, huPlayer) then
        gamestate = 3
        winner = "player"
    end
    if winning(board, aiPlayer) then
        gamestate = 3
        winner = "ai"
    end
    local t = emptyIndexies(board)
    if #t == 0 then
        gamestate = 3
        winner = "draw"
    end
end

function minimax(newBoard, player)
    
    local availSpots = emptyIndexies(newBoard)
    
    
    if winning(newBoard, huPlayer) then
       return {score = -10}
    else if winning(newBoard, aiPlayer) then
            return {score = 10}
        else if #availSpots == 0 then
                return {score = 0}
            end
        end
    end
  
    local moves = {}
  
    for i = 1, #availSpots do
        local move = {
            index = -1,
            score = -1,
        }
        move.index = newBoard[availSpots[i]]
  
        newBoard[availSpots[i]] = player;
    
        if player == aiPlayer then
            local result = minimax(newBoard, huPlayer)
            move.score = result.score
        else
            local result = minimax(newBoard, aiPlayer)
            move.score = result.score   
        end
    
        newBoard[availSpots[i]] = move.index;
    
        table.insert(moves, move)
    end
  
    local bestMove
    if player == aiPlayer then
        local bestScore = -10000
        for i = 1, #moves do
            if moves[i].score > bestScore then
                bestScore = moves[i].score
                bestMove = i
            end
        end
    else
  
    local bestScore = 10000
    for i=1, #moves do
        if moves[i].score < bestScore then
                bestScore = moves[i].score
                bestMove = i
            end
        end
    end
  
    return moves[bestMove];
end

function emptyIndexies(nboard)
    local res = {}
    for i = 1, #nboard do
        if tostring(nboard[i]):match("%d") then table.insert(res, nboard[i]) end
    end
    return res
end

function winning(nboard, player) 
    if (
           (nboard[1] == player and nboard[2] == player and nboard[3] == player) or
           (nboard[4] == player and nboard[5] == player and nboard[6] == player) or
           (nboard[7] == player and nboard[8] == player and nboard[9] == player) or 
           (nboard[1] == player and nboard[4] == player and nboard[7] == player) or
           (nboard[2] == player and nboard[5] == player and nboard[8] == player) or
           (nboard[3] == player and nboard[6] == player and nboard[9] == player) or
           (nboard[1] == player and nboard[5] == player and nboard[9] == player) or
           (nboard[3] == player and nboard[5] == player and nboard[7] == player)
           ) 
        then
           return true;
        else
           return false;
        end
end