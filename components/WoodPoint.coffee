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
      .wood_point(class=classes onClick=onClick onMouseOver=onMouseOver onMouseOut=onMouseOut)
      .wood.hover(class=classes)
    """)(_.assign(@, @props, @state))
  onClick: =>
    socket.emit('action', action: "moveWood", args: [@props.point, @props.player, @props.moves])
    @props.flux.getActions("game").moveWood(@props.point, @props.player, @props.moves)
  onMouseOver: =>
    @setState hover: true
  onMouseOut: =>
    @setState hover: false
