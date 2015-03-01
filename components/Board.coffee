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
    cx = React.addons.classSet
    player_class =
      1: cx(player1: true)
      2: cx(player2: true)
    start_classes  = cx show: !@props.play, hide:  @props.play
    giveup_classes = cx show:  @props.play, hide: !@props.play
    end_classes    = cx show:  @props.end, hide: !@props.end

    jade.compile("""
      .row
        .col-md-2.col-md-offset-2
          .row
            a.control.btn.btn-default(class=start_classes onClick=startGame) Start
            a.control.btn.btn-default(class=giveup_classes onClick=giveupGame) Give up
            a.control.btn.btn-default(class=end_classes onClick=endGame) End

          hr

          table.table.table-bordered.back
            tbody
              tr
                th Room
                td= roomId
              tr(class=player_class[player])
                th Current
                td= player

        .col-md-8
          #board
            .pieces
              each piece, index in pieces
                Piece(piece=piece key=index)
            .woods
              each wood, index in woods
                Wood(wood=wood key=index)
            if wood_count[player] > 0
              .wood_points
                each point, index in wood_points
                  WoodPoint(point=point key=index flux=flux)
            .grids
              each rows, index in grids
                .clearfix(key=index)
                  each col,index in rows
                    .col(key=index)
                      Grid(grid=col flux=flux)
          #case
            .woods
              each wood, index in unused_woods
                Wood(wood=wood key=index)

    """)(_.assign(@, @props, @state))
  startGame: =>
    socket.push('action', action: "startGame", args: [1])
  giveupGame: =>
    player = @props.flux.getStore("board").state.player
    socket.push('action', action: "giveupGame", args: [player])
  endGame: =>
    socket.push('action', action: "endGame", args: [])
