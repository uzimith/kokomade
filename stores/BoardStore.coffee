React = require('react')
Store = require('flummox').Store
_ = require('lodash')

module.exports =
class BoardStore extends Store
  constructor: (flux) ->
    super
    gameActions = flux.getActionIds('game')
    @register(gameActions.movePiece, @handleMovePiece)
    @register(gameActions.startGame, @handleNewGame)
    @register(gameActions.endGame, @handleEndGame)
    @register(gameActions.giveupGame, @handleGiveup)
    @num = 9
    grids = @createGrids()
    @state =
      pieces: {}
      woods: []
      grids: grids
      player: 0
      winner: 0
      play: false
      end: false

  handleNewGame: (player) ->
    pieces =
      1: {player: 1, row:      0, col: 4}
      2: {player: 2, row: @num-1, col: 4}
    woods = [
      {status: "vertical"   , row: 0 , col: 0 , player: 1}
      {status: "horizontal" , row: 1 , col: 3 , player: 1}
      {status: "horizontal" , row: 8 , col: 3 , player: 1}
      {status: "vertical"   , row: 0 , col: 1 , player: 1}
    ]
    grids = @createGrids()
    grids = @searchNextPutableGrid(grids, pieces, woods, player)

    @setState
      grids: grids
      pieces: pieces
      woods: woods
      player: player
      winner: 0
      play: true
      end: false

  handleMovePiece: (data) ->
    # move piece
    pieces = @state.pieces
    pieces[data.player] = data.piece

    # update
    end = pieces[1].row is @num - 1 or pieces[2].row is 0
    grids = @createGrids()
    unless end
      next_player = @fetchNextPlayer(@state.player)
      grids = @searchNextPutableGrid(grids, pieces, @state.woods, next_player)
    else
      next_player = 0
    @setState
      grids: grids
      pieces: pieces
      player: next_player
      end: end

  handleEndGame: ->
    grids = @createGrids()

    winner = 0
    winner = 1 if @state.pieces[1].row is @num - 1
    winner = 2 if @state.pieces[2].row is 0

    @setState
      grids: grids
      winner: winner
      play: false

  handleGiveup: (player)->
    grids = @createGrids()
    winner = @fetchOpponent(player)

    @setState
      grids: grids
      winner: winner
      play: false

  # private

  createGrids: ->
    _.map [0...@num], (row) =>
      _.map [0...@num], (col) =>
        row: row, col: col, next: false

  fetchNextPlayer: (player) ->
    if player == 1
      return 2
    if player == 2
      return 1

  fetchOpponent: (player) ->
    if player == 1
      return 2
    if player == 2
      return 1

  searchNextPutableGrid: (grids, pieces, woods, player) ->
    arounds = [
      {diff: [-1,0], direction: "left"}
      {diff: [1,0], direction: "right"}
      {diff: [0,-1], direction: "above"}
      {diff: [0,1],  direction: "below"}
    ]
    for ke, piece of pieces
      if piece.player is player
        for around in arounds
          do =>
            dx = around.diff[1]
            dy = around.diff[0]
            row = piece.row
            col = piece.col
            for i in [0...@num]
              row += dx
              col += dy
              return unless (0 <= row and row < @num) and (0 <= col and col < @num)
              return if around.direction is "left" and
                (_.findWhere(woods, {row: row, col: col+1, status: "vertical"}) or _.findWhere(woods, {row: row-1, col: col+1, status: "vertical"}))
              return if around.direction is "right" and
                (_.findWhere(woods, {row: row, col: col, status: "vertical"}) or _.findWhere(woods, {row: row-1, col: col, status: "vertical"}))
              return if around.direction is "above" and
                (_.findWhere(woods, {row: row+1, col: col, status: "horizontal"}) or _.findWhere(woods, {row: row+1, col: col-1, status: "horizontal"}))
              return if around.direction is "below" and
                (_.findWhere(woods, {row: row, col: col, status: "horizontal"}) or _.findWhere(woods, {row: row, col: col-1, status: "horizontal"}))
              unless _.findWhere(pieces, {row: row, col: col})
                grids[row][col].next = true
                return
    return grids

