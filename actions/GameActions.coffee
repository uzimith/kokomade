Actions = require('flummox').Actions

module.exports =
class GameActions extends Actions
  startGame: (player, pair) ->
    player: player, pair: pair
  endGame: ->
    null
  giveupGame: (player) ->
    player
  movePiece: (grid, player, moves) ->
    piece = {
      col: grid.col
      row: grid.row
      player: player
      moves: ++moves
    }
    piece
  selectWood: ->
    null
  shareBoard: (state) =>
    state
  moveWood: (point, player, moves) ->
    wood = {
      col: point.col
      row: point.row
      status: point.status
      player: player
      moves: ++moves
    }
    wood
