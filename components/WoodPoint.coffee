React = require('react')
jade = require('react-jade')
_ = require('lodash')

module.exports =
class WoodPoint extends React.Component
  constructor: ->
    @state = hover: false
  render: =>
    cx = React.addons.classSet

    classes = cx {
      "col#{@props.point.col}": true
      "row#{@props.point.row}": true
      "#{@props.point.status}": true
    }
    jade.compile("""
      .wood_point(class=classes onTouchTap=onClick onMouseOver=onMouseOver onMouseOut=onMouseOut)
      .wood.hover(class=classes)
    """)(_.assign(@, @props, @stjjate))
  onClick: =>
    if @props.viewer
      return
    point = @props.point
    player = @props.board.player
    moves = @props.board.moves
    socket.push('action', action: "moveWood", args: [point, player, moves])
  onMouseOver: =>
    @setState hover: true
  onMouseOut: =>
    @setState hover: false
