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
    @num = 9
    @player = 2

    grids = @_createGrids()
    @state =
      board:
        pair: false
        pieces: {}
        woods: []
        wood_points: []
        wood_count: {}
        unused_woods: {}
        moves: 0
        grids: grids
        player: 0
        play: false
        end: false
        select_wood: false
      winner: 0
      look_back: false
      history: []

  handleNewGame: (data) ->
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
    grids = @_createGrids()
    grids = @_searchNextPutableGrid(grids, pieces, woods, data.player)
    @setState
      board:
        pair: data.pair
        pieces: pieces
        woods: woods
        wood_points: wood_points
        wood_count: wood_count
        unused_woods: unused_woods
        moves: 0
        grids: grids
        player: data.player
        play: true
        end: false
        select_wood: false
      winner: 0
      look_back: false
      history: []

  handlePiece: (piece) ->
    if @state.look_back
      console.log("warn")
    history = React.addons.update(@state.history, {$push: [@state]})
    # move piece
    pieces = React.addons.update(@state.board.pieces, {"#{piece.player}": {$set: piece}})

    # update
    if @state.board.pair
      end = pieces[1].row is @num - 1 or pieces[2].col is 0 or
            pieces[3].row is        0 or pieces[4].col is @num - 1
    else
      end = pieces[1].row is @num - 1 or pieces[2].row is 0
    grids = @_createGrids()
    unless end
      next_player = @_fetchNextPlayer(@state.board.player)
      grids = @_searchNextPutableGrid(grids, pieces, @state.board.woods, next_player)
    else
      next_player = 0

    board = React.addons.update @state.board, {
      grids: {$set: grids}
      pieces: {$set: pieces}
      player: {$set: next_player}
      end: {$set: end}
      moves: {$set: ++@state.board.moves}
      select_wood: {$set: false}
    }
    @setState
      board: board
      history: history

  handleSelectWood: ->
    grids = @_createGrids()
    board = React.addons.update @state.board, {
      grids: {$set: grids}
      select_wood: {$set: true}
    }
    @setState
      board: board

  handleUnselectWood: ->
    grids = @_createGrids()
    grids = @_searchNextPutableGrid(grids, @state.board.pieces, @state.board.woods, @state.board.player)
    board = React.addons.update @state.board, {
      grids: {$set: grids}
      select_wood: {$set: false}
    }
    @setState
      board: board

  handleMoveWood: (wood) ->
    history = React.addons.update(@state.history, {$push: [@state]})
    # move wood
    woods = React.addons.update(@state.board.woods, {$push: [wood]})

    wood_points = _.clone(@state.board.wood_points)
    _.remove wood_points, (point) ->
      if wood.status is "horizontal"
        return (wood.row is point.row and _.includes([wood.col,wood.col+1], point.col) and point.status is "horizontal") or
          (wood.col+1 is point.col and wood.row-1 is point.row and point.status is "vertical")
      if wood.status is "vertical"
        return (_.includes([wood.row,wood.row+1], point.row) and wood.col is point.col and point.status is "vertical") or
          (wood.row+1 is point.row and wood.col-1 is point.col and point.status is "horizontal")


    wood_count = React.addons.update(@state.board.wood_count, {"#{wood.player}": {$set: @state.board.wood_count[wood.player] - 1}})

    unused_woods = _.flatten _.map wood_count, (count,player) ->
      _.map _.range(1, count+1), (i) ->
        {id: i, status: "waiting", row: 0, col: 0, player: +player}

    # update
    grids = @_createGrids()
    next_player = @_fetchNextPlayer(@state.board.player)
    grids = @_searchNextPutableGrid(grids, @state.board.pieces, woods, next_player)

    board = React.addons.update @state.board, {
      grids: {$set: grids}
      player: {$set: next_player}
      moves: {$set: ++@state.board.moves}
      select_wood: {$set: false}
      woods: {$set: woods}
      wood_count: {$set: wood_count}
      wood_points: {$set: wood_points}
      unused_woods: {$set: unused_woods}
    }
    @setState
      board: board


  handleEndGame: ->
    grids = @_createGrids()

    winner = 0
    pieces = @state.board.pieces
    if @state.board.pair
      winner = 1 if pieces[1].row is @num - 1
      winner = 2 if pieces[2].col is 0
      winner = 3 if pieces[3].row is 0
      winner = 4 if pieces[4].col is @num - 1
    else
      winner = 1 if pieces[1].row is @num - 1
      winner = 2 if pieces[2].row is 0

    board = React.addons.update @state.board, {
      grids: {$set: grids}
      play: {$set: false}
    }
    @setState
      board: board
      winner: winner

  handleGiveup: (player)->
    grids = @_createGrids()
    winner = @_fetchOpponent(player)

    board = React.addons.update @state.board, {
      grids: {$set: grids}
      play: {$set: false}
    }
    @setState
      board: board
      winner: winner

  shareBoard: (board) ->
    @setState
      board: board

  # private

  _createGrids: ->
    _.map [0...@num], (row) =>
      _.map [0...@num], (col) =>
        row: row, col: col, next: false

  _fetchNextPlayer: (player) ->
    if @state.board.pair
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

  _fetchOpponent: (player) ->
    if @state.board.pair
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

  _searchNextPutableGrid: (grids, pieces, woods, player) ->
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
