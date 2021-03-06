React = require('react')
jade = require('react-jade')
_ = require('lodash')

FluxComponent = require('flummox/component')

Grid = require('./Grid.coffee')
Piece = require('./Piece.coffee')
Wood = require('./Wood.coffee')
WoodPoint = require('./WoodPoint.coffee')

module.exports =
class Board extends React.Component
  @propTypes =
    viewer: React.PropTypes.bool
  @defaultProps =
        viewer: false
  constructor: ->
    @state = rotate: 0
  render: =>
    cx = React.addons.classSet
    rotate_class = cx("rotate#{ @state.rotate % 4}": true)
    jade.compile("""
    #board(class=rotate_class)
      .pieces
        each piece, index in pieces
          FluxComponent(connectToStores=['board'] key=index)
            Piece(piece=piece viewer=viewer)
      .woods
        each wood, index in woods
          FluxComponent(connectToStores=['board'] key=index)
            Wood(wood=wood)
      if wood_count[player] > 0 && select_wood
        .wood_points
          each point, index in wood_points
            FluxComponent(connectToStores=['board'] key=index)
              WoodPoint(point=point viewer=viewer)
      .grids
        each rows, index in grids
          .clearfix(key=index)
            each col,index in rows
              .col(key=index)
                FluxComponent(connectToStores=['board'])
                  Grid(grid=col viewer=viewer)

    hr

    .controller
      .row
        .col-sm-3
            btn.control.btn.btn-default.control.show(onClick=rotateLeft)
              .glyphicon.glyphicon-refresh

    hr

    #case
      .woods
        each wood, index in unused_woods
          FluxComponent(connectToStores=['board'] key=index)
            Wood(wood=wood viewer=viewer)
    """)(_.assign(@, @props, @state, @props.board))
  rotateLeft: =>
    @setState rotate: ++@state.rotate
