React = require('react')
jade = require('react-jade')
_ = require('lodash')

module.exports =
class Grid extends React.Component
  render: =>
    cx = React.addons.classSet
    classes = cx {
      next: @props.grid.next
      "col#{@props.grid.col}": true
      "row#{@props.grid.row}": true
    }
    if @props.pair
      player_class = cx {
        "player1": @props.board.player is 1 and @props.grid.row is 8
        "player2": @props.board.player is 2 and @props.grid.col is 0
        "player3": @props.board.player is 3 and @props.grid.row is 0
        "player4": @props.board.player is 4 and @props.grid.col is 8
      }
    else
      player_class = cx {
        "player1": @props.board.player is 1 and @props.grid.row is 8
        "player2": @props.board.player is 2 and @props.grid.row is 0
      }
    jade.compile("""
      .grid(class=[classes, player_class] onClick=onClick onTouchTap=onClick)
    """)(_.assign(@, @props, @state))
  onClick: =>
    if @props.viewer
      return
    if @props.grid.next
      grid = @props.grid
      player = @props.board.player
      moves = @props.board.moves
      socket.emit('action', action: "movePiece", args: [grid, player, moves])
