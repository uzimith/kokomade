React = require('react')
jade = require('react-jade')
_ = require('lodash')

module.exports =
class Piece extends React.Component
  render: =>
    cx = React.addons.classSet
    classes = cx {
      "player#{@props.piece.player}": true
      "col#{@props.piece.col}": true
      "row#{@props.piece.row}": true
    }
    jade.compile("""
    .piece(class=classes)
    """)(_.assign(@, @props, @state))
