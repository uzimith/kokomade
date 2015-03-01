React = require('react')
jade = require('react-jade')
_ = require('lodash')

module.exports =
class WoodPoint extends React.Component
  render: =>
    cx = React.addons.classSet
    classes = cx {
      "col#{@props.point.col}": true
      "row#{@props.point.row}": true
      "#{@props.point.status}": true
    }
    jade.compile("""
      .wood_point(class=classes onClick=onClick onMouseMove=onMouseMove)
    """)(_.assign(@, @props, @state))
  onClick: =>
    player = @props.flux.getStore("board").state.player
    socket.push('action', action: "moveWood", args: [@props.point, player])
  onMouseMove: =>
    player = @props.flux.getStore("board").state.player
    console.log("")
