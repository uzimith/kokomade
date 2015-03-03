React = require('react')
jade = require('react-jade')
_ = require('lodash')

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
      .row
        .col-sm-6
          a.control.btn.btn-default(class=playing_classes onClick=backHistory)
            .glyphicon.glyphicon-menu-left
        .col-sm-6
          a.control.btn.btn-default(class=playing_classes onClick=nextHistory)
            .glyphicon.glyphicon-menu-right
    """)(_.assign(@, @props, @state))
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
