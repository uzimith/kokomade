Actions = require('flummox').Actions

module.exports =
class GameActions extends Actions
  startGame: (player, pair) ->
    player: player, pair: pair
  endGame: ->
    null
  giveupGame: (player) ->
    player
  movePiece: (grid, player) ->
    piece = {
      col: grid.col
      row: grid.row
      player: player
    }
    piece
  moveWood: (point, player) ->
    wood = {
      col: point.col
      row: point.row
      status: point.status
      player: player
    }
    wood
