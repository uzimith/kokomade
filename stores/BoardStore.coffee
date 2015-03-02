React = require('react')
Store = require('flummox').Store
_ = require('lodash')

module.exports =
class BoardStore extends Store
  constructor: (flux) ->
    super
    gameActions = flux.getActionIds('game')
    @register(gameActions.movePiece, @handlePiece)
    @register(gameActions.moveWood, @handleMoveWood)
    @register(gameActions.selectWood, @handleSelectWood)
    @register(gameActions.unselectWood, @handleUnselectWood)
    @register(gameActions.startGame, @handleNewGame)
    @register(gameActions.endGame, @handleEndGame)
    @register(gameActions.giveupGame, @handleGiveup)
    @register(gameActions.shareBoard, @shareBoard)
    @register(gameActions.backHistory, @backHistory)
    @register(gameActions.nextHistory, @nextHistory)
    @num = 9
    @player = 2

    @history = []
    @post_history = []
    @state_number = 0
    grids = @createGrids()
    @state =
      pieces: {}
      woods: []
      wood_points: []
      wood_count: {}
      unused_woods: {}
      select_wood: false
      moves: 0
      grids: grids
      player: 0
      pair: false
      winner: 0
      play: false
      end: false
      look_back: false

  handleNewGame: (data) ->
    @history = []
    @post_history = []
    if data.pair
      @player = 4
      pieces =
        1: {player: 1, row:      0, col: 4}
        2: {player: 2, row:      4, col: @num-1}
        3: {player: 3, row: @num-1, col: 4}
        4: {player: 4, row:      4, col: 0}
      wood_count = {
        1: 5
        2: 5
        3: 5
        4: 5
        }
    else
      @player = 2
      pieces =
        1: {player: 1, row:      0, col: 4}
        2: {player: 2, row: @num-1, col: 4}
      wood_count = {
        1: 10
        2: 10
        }
    woods = []
    unused_woods = _.flatten _.map wood_count, (count,player) ->
      _.map _.range(1, count+1), (i) ->
        {id: i, status: "waiting", row: 0, col: 0, player: +player}
    wood_points = _.flatten _.flatten(
      _.map [0...@num], (row) =>
        _.map [0...@num], (col) =>
          [ {row: row, col: col, status: "horizontal"}, {row: row, col: col, status: "vertical"} ]
    )
    grids = @createGrids()
    grids = @searchNextPutableGrid(grids, pieces, woods, data.player)

    @setState
      grids: grids
      pieces: pieces
      woods: woods
      wood_count: wood_count
      wood_points: wood_points
      unused_woods: unused_woods
      player: data.player
      winner: 0
      play: true
      end: false
      pair: data.pair
      moves: 0
      select_wood: false

  handlePiece: (piece) ->
    if @state.look_back
      console.log("warn")
    @pushHistroy(@history, @state)
    # move piece
    pieces = React.addons.update(@state.pieces, {"#{piece.player}": {$set: piece}})

    # update
    if @state.pair
      end = pieces[1].row is @num - 1 or pieces[2].col is 0 or
            pieces[3].row is        0 or pieces[4].col is @num - 1
    else
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
      moves: ++@state.moves
      select_wood: false

  handleSelectWood: ->
    grids = @createGrids()
    @setState
      grids: grids
      select_wood: true

  handleUnselectWood: ->
    grids = @createGrids()
    grids = @searchNextPutableGrid(grids, @state.pieces, @state.woods, @state.player)
    @setState
      grids: grids
      select_wood: false

  handleMoveWood: (wood) ->
    if @state.look_back
      console.log("warn")
    @pushHistroy(@history, @state)
    # move wood
    woods = React.addons.update(@state.woods, {$push: [wood]})

    wood_points = _.clone(@state.wood_points)
    _.remove wood_points, (point) ->
      if wood.status is "horizontal"
        return (wood.row is point.row and _.includes([wood.col,wood.col+1], point.col) and point.status is "horizontal") or
          (wood.col+1 is point.col and wood.row-1 is point.row and point.status is "vertical")
      if wood.status is "vertical"
        return (_.includes([wood.row,wood.row+1], point.row) and wood.col is point.col and point.status is "vertical") or
          (wood.row+1 is point.row and wood.col-1 is point.col and point.status is "horizontal")


    wood_count = React.addons.update(@state.wood_count, {"#{wood.player}": {$set: @state.wood_count[wood.player] - 1}})

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
      moves: ++@state.moves
      select_wood: false


  handleEndGame: ->
    grids = @createGrids()

    winner = 0
    if @state.pair
      winner = 1 if @state.pieces[1].row is @num - 1
      winner = 2 if @state.pieces[2].col is 0
      winner = 3 if @state.pieces[3].row is 0
      winner = 4 if @state.pieces[4].col is @num - 1
    else
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

  shareBoard: (state) ->
    @setState state

  pushHistroy: (history, state)->
    history.push(state)
    @state_number++

  backHistory: ->
    if @state_number > 0
      @state_number--
      console.log(@state_number)
      @setState _.assign(@history[@state_number], look_back: true)
      @post_history.push(@state)
  nextHistory: ->
    if @post_history.length > 0
      @state_number++
      @setState _.assign(@post_history.pop(), look_back: @post_history.length isnt 0) 

  # private

  createGrids: ->
    _.map [0...@num], (row) =>
      _.map [0...@num], (col) =>
        row: row, col: col, next: false

  fetchNextPlayer: (player) ->
    if @state.pair
      if player is 1
        return 2
      if player is 2
        return 3
      if player is 3
        return 4
      if player is 4
        return 1
    else
      if player is 1
        return 2
      if player is 2
        return 1

  fetchOpponent: (player) ->
    if @state.pair
      if player == 1
        return 3
      if player == 2
        return 4
      if player == 2
        return 4
      if player == 3
        return 1
    else
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
