React = require('react')
jade = require('react-jade')
_ = require('lodash')

module.exports =
class Grid extends React.Component
  render: =>
    cx = React.addons.classSet
    classes = cx {
      next: @props.grid.next
    }
    jade.compile("""
      .grid(class=classes onClick=onClick)
    """)(_.assign(@, @props, @state))
  onClick: =>
    if @props.grid.next
      player = @props.flux.getStore("board").state.player
      socket.push('action', action: "movePiece", args: [@props.grid, player])
