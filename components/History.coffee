React = require('react')
jade = require('react-jade')
_ = require('lodash')

Board = require('./Board.coffee')

module.exports =
class History extends React.Component
  constructor: ->
    @state = moves: 0

  render: =>
    cx = React.addons.classSet
    player_class =
      1: cx(player1: true)
      2: cx(player2: true)
      3: cx(player3: true)
      4: cx(player4: true)
    jade.compile("""
      #history
        .row
          .col-md-2.col-md-offset-2
            a.control.btn.btn-danger.show(onClick=shareBoard) Share Board
            a.control.btn.btn-default.show(onClick=hideHistory) Hide
            hr

            table.table.table-bordered.back
              tbody
                tr
                  th Moves
                  td= history[moves].moves
            .row
              .col-sm-6
                if moves > 0
                  btn.control.btn.btn-default(class=playing_classes onClick=backHistory)
                    .glyphicon.glyphicon-menu-left
                else
                  btn.control.btn.btn-default(class=playing_classes onClick=backHistory disabled)
                    .glyphicon.glyphicon-menu-left
              .col-sm-6
                if moves < history.length - 1
                  btn.control.btn.btn-default(class=playing_classes onClick=nextHistory)
                    .glyphicon.glyphicon-menu-right
                else
                  btn.control.btn.btn-default(class=playing_classes onClick=nextHistory disabled)
                    .glyphicon.glyphicon-menu-right
          .col-md-8
            if history[moves]
              Board(board=history[moves] viewer=true)
    """)(_.assign(@, @props, @state))

  hideHistory: =>
    @props.flux.getActions("panel").hideHistory()
  shareBoard: =>
    socket.emit('action', action: "shareBoard", args: [@props.history[@state.moves]])
    @props.flux.getActions("game").shareBoard(@props.history[@state.moves])
  backHistory: =>
    if @state.moves > 0
      @setState moves: --@state.moves
  nextHistory: =>
    if @state.moves < @props.history.length - 1
      @setState moves: ++@state.moves
