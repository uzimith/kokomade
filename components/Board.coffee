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
  render: =>
    jade.compile("""
    #board
      .pieces
        each piece, index in pieces
          FluxComponent(connectToStores=['board'] key=index)
            Piece(piece=piece)
      .woods
        each wood, index in woods
          FluxComponent(connectToStores=['board'] key=index)
            Wood(wood=wood)
      if wood_count[player] > 0 && select_wood
        .wood_points
          each point, index in wood_points
            FluxComponent(connectToStores=['board'] key=index)
              WoodPoint(point=point)
      .grids
        each rows, index in grids
          .clearfix(key=index)
            each col,index in rows
              .col(key=index)
                FluxComponent(connectToStores=['board'])
                  Grid(grid=col flux=flux)
    #case
      .woods
        each wood, index in unused_woods
          FluxComponent(connectToStores=['board'] key=index)
            Wood(wood=wood)
    """)(_.assign(@, @props, @state))
