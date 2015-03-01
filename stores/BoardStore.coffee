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
    woods = []
    grids = @createGrids()
    grids = @searchNextPutableGrid(grids, pieces, player)

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
    end = false
    grids = @createGrids()
    next_player = @fetchNextPlayer(@state.player)
    grids = @searchNextPutableGrid(grids, pieces, next_player)
    @setState
      grids: grids
      pieces: pieces
      player: next_player
      end: end

  handleEndGame: ->
    grids = @createGrids()
    winner = 1

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

  searchNextPutableGrid: (grids, pieces, player) ->
    arounds = [[1,0],[0,1],[-1,0],[0,-1]]
    for key, piece of pieces
      if piece.player is player
        for d in arounds
          do =>
            dx = d[0]; dy = d[1]
            row = piece.row
            col = piece.col
            for i in [0...@num]
              row += dx
              col += dy
              return unless (0 <= row and row < @num) and (0 <= col and col < @num)
              unless _.findWhere(pieces, {row: row, col: col})
                grids[row][col].next = true
                return
    return grids

