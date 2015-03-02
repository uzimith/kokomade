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
      "current": @props.piece.moves is @props.moves
    }
    jade.compile("""
    .piece(class=classes)
      if pair
        if piece.player === 1
          .glyphicon.glyphicon-menu-down
        if piece.player === 2
          .glyphicon.glyphicon-menu-left
        if piece.player === 3
          .glyphicon.glyphicon-menu-up
        if piece.player === 4
          .glyphicon.glyphicon-menu-right
      else
        if piece.player === 1
          .glyphicon.glyphicon-menu-down
        if piece.player === 2
          .glyphicon.glyphicon-menu-up
    """)(_.assign(@, @props, @state))
