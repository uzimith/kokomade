Actions = require('flummox').Actions

module.exports =
class GameActions extends Actions
  startGame: (player) ->
    player
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
    piece: piece, player: player
