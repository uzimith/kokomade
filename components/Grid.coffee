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
    jade.compile("""
      .grid(class=classes onClick=onClick)
    """)(_.assign(@, @props, @state))
  onClick: =>
    if @props.grid.next
      socket.emit('action', action: "movePiece", args: [@props.grid, @props.player, @props.moves])
      @props.flux.getActions("game").movePiece(@props.grid, @props.player, @props.moves)
