React = require('react')
jade = require('react-jade')
_ = require('lodash')

module.exports =
class Wood extends React.Component
  render: =>
    cx = React.addons.classSet
    classes = cx {
      "player#{@props.wood.player}": true
      "col#{@props.wood.col}": true
      "row#{@props.wood.row}": true
      "wood#{@props.wood.id}": _.isEmpty(@props.wood.id)
      "#{@props.wood.status}": true
      "current": @props.wood.moves is @props.board.moves
    }
    jade.compile("""
      .wood(class=classes onClick=onClick)
    """)(_.assign(@, @props, @state))
  onClick: =>
    @props.flux.getActions("game").selectWood()
