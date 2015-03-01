React = require('react')
Store = require('flummox').Store
_ = require('lodash')

module.exports =
class BoardStore extends Store
  constructor: (flux) ->
    super
    gameActions = flux.getActionIds('game')
    @register(gameActions.movePiece, @handlePiece)
    @register(gameActions.moveWood, @handleWood)
    @register(gameActions.startGame, @handleNewGame)
    @register(gameActions.endGame, @handleEndGame)
    @register(gameActions.giveupGame, @handleGiveup)
    @num = 9
    @player = 2
    grids = @createGrids()
    @state =
      pieces: {}
      woods: []
      wood_points: []
      wood_count: {}
      unused_woods: {}
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
    wood_count = {
      1: 10
      2: 10
      }
    unused_woods = _.flatten _.map wood_count, (count,player) ->
      _.map _.range(1, count), (i) ->
        {id: i, status: "waiting", row: 0, col: 0, player: +player}
    wood_points = _.flatten _.flatten(
      _.map [0...@num], (row) =>
        _.map [0...@num], (col) =>
          [ {row: row, col: col, status: "horizontal"}, {row: row, col: col, status: "vertical"} ]
    )
    grids = @createGrids()
    grids = @searchNextPutableGrid(grids, pieces, woods, player)

    @setState
      grids: grids
      pieces: pieces
      woods: woods
      wood_count: wood_count
      wood_points: wood_points
      unused_woods: unused_woods
      player: player
      winner: 0
      play: true
      end: false

  handlePiece: (piece) ->
    # move piece
    pieces = @state.pieces
    pieces[piece.player] = piece

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

  handleWood: (wood) ->
    # move wood
    woods = @state.woods
    woods.push(wood)

    wood_points = @state.wood_points
    _.remove @state.wood_points, (point) ->
      if wood.status is "horizontal"
        return (wood.row is point.row and _.includes([(wood.col-1)..(wood.col+2)], point.col) and point.status is "horizontal") or
          (wood.col+1 is point.col and _.includes([wood.row-1,wood.row], point.row) and point.status is "vertical")
      if wood.status is "vertical"
        return (_.includes([(wood.row-1)..(wood.row+2)], point.row) and wood.col is point.col and point.status is "vertical") or
          (wood.row+1 is point.row and _.includes([wood.col-1,wood.col], point.col) and point.status is "horizontal")


    wood_count = @state.wood_count
    wood_count[wood.player]--

    unused_woods = _.flatten _.map wood_count, (count,player) ->
      _.map _.range(1, count), (i) ->
        {id: i, status: "waiting", row: 0, col: 0, player: +player}

    # update
    grids = @createGrids()
    next_player = @fetchNextPlayer(@state.player)
    grids = @searchNextPutableGrid(grids, @state.pieces, woods, next_player)
    @setState
      grids: grids
      player: next_player
      woods: woods
      wood_count: wood_count
      wood_points: wood_points
      unused_woods: unused_woods


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

