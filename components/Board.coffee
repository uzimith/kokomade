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
  constructor: ->
    @state = pair: false
  render: =>
    cx = React.addons.classSet
    player_class =
      1: cx(player1: true)
      2: cx(player2: true)
      3: cx(player3: true)
      4: cx(player4: true)
    start_classes  = cx show: !@props.play, hide:  @props.play
    playing_classes = cx show:  @props.play, hide: !@props.play
    end_classes    = cx show:  @props.end, hide: !@props.end

    jade.compile("""
      .row
        .col-md-2.col-md-offset-2
          .row
            a.control.btn.btn-default(class=start_classes onClick=startGame) Start
            select.form-control(class=start_classes onChange=onChange)
              option(value="single") Single
              option(value="pair") Pair
            a.control.btn.btn-default(class=playing_classes onClick=giveupGame) Give up
            a.control.btn.btn-default(class=playing_classes onClick=shareBoard) Share Board
            .row
              .col-sm-6
                a.control.btn.btn-default(class=playing_classes onClick=backHistory)
                  .glyphicon.glyphicon-menu-left
              .col-sm-6
                a.control.btn.btn-default(class=playing_classes onClick=nextHistory)
                  .glyphicon.glyphicon-menu-right
            a.control.btn.btn-default(class=end_classes onClick=endGame) End

          hr

          table.table.table-bordered.back
            tbody
              tr
                th Room
                td= roomId
              tr
                th Moves
                td= moves
              tr(class=player_class[player])
                th Current
                td= player


          hr

          .row
            a.control.btn.btn-default(class=[player_class[player], playing_classes] onClick=selectWood) Wood

          hr

        .col-md-8
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
  startGame: =>
    socket.emit('action', action: "startGame", args: [1, @state.pair])
    @props.flux.getActions("game").startGame(1, @state.pair)
  giveupGame: =>
    player = @props.flux.getStore("board").state.player
    socket.emit('action', action: "giveupGame", args: [player])
    @props.flux.getActions("game").giveupGame(player)
  endGame: =>
    socket.emit('action', action: "endGame", args: [])
    @props.flux.getActions("game").endGame()
  onChange: (e) =>
    @setState pair: e.target.options[e.target.options.selectedIndex].value is "pair"
  selectWood: =>
    @props.flux.getActions("game").selectWood()
  shareBoard: =>
    state =
      pieces: @props.pieces
      woods: @props.woods
      wood_points: @props.wood_points
      wood_count: @props.wood_count
      unused_woods: @props.unused_woods
      select_wood: @props.select_wood
      moves: @props.moves
      grids: @props.grids
      player: @props.player
      pair: @props.pair
      winner: @props.winner
      play: @props.play
      end: @props.end
    socket.emit('action', action: "shareBoard", args: [state])
  backHistory: =>
    @props.flux.getActions("game").backHistory()
  nextHistory: =>
    @props.flux.getActions("game").nextHistory()
