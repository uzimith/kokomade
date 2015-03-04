React = require('react')
jade = require('react-jade')
_ = require('lodash')

module.exports =
class Controller extends React.Component
  constructor: ->
    @state = pair: false
  render: =>
    cx = React.addons.classSet
    player_class =
      1: cx(player1: true)
      2: cx(player2: true)
      3: cx(player3: true)
      4: cx(player4: true)
    start_classes  = cx show: !@props.board.play, hide:  @props.board.play
    playing_classes = cx show: @props.board.play and !@props.board.end, hide: !@props.board.play or @props.board.end
    end_classes = cx show: @props.board.end, hide: !@props.board.end
    select_classes = cx show: !@props.board.select_wood and @props.board.play, hide: @props.board.select_wood or !@props.board.play
    unselect_classes = cx show: @props.board.select_wood and @props.board.play, hide: !@props.board.select_wood or !@props.board.play
    history_classes = cx show: @props.history and @props.history.length > 0, hide: !(@props.history and @props.history.length > 0)
    jade.compile("""
    .row
      a.control.btn.btn-danger(class=end_classes onClick=endGame) End
      a.control.btn.btn-default(class=start_classes onClick=startGame) Start
      select.control.form-control(class=start_classes onChange=onChange)
        option(value="single") Single
        option(value="pair") Pair
      a.control.btn.btn-default(class=playing_classes onClick=giveupGame) Give up
      a.control.btn.btn-default(class=history_classes onClick=toggleHistory) History

    hr

    table.table.table-bordered.back
      tbody
        tr
          th Room
          td= roomId
        tr
          th Moves
          td= board.moves
        tr(class=player_class[board.player])
          th Current
          td= board.player


    hr

    .row
      a.control.btn.btn-default(class=[player_class[board.player], select_classes] onClick=selectWood) Wood
      a.control.btn.btn-default(class=[player_class[board.player], unselect_classes] onClick=unselectWood) Piece

    """)(_.assign(@, @props, @state))
  startGame: =>
    pair = @state.pair
    socket.push('action', action: "startGame", args: [1, pair])
  giveupGame: =>
    player = @props.board.player
    socket.emit('action', action: "giveupGame", args: [player])
    @props.flux.getActions("game").giveupGame(player)
  endGame: =>
    socket.emit('action', action: "endGame", args: [])
    @props.flux.getActions("game").endGame()
  onChange: (e) =>
    @setState pair: e.target.options[e.target.options.selectedIndex].value is "pair"
  selectWood: =>
    @props.flux.getActions("game").selectWood()
  unselectWood: =>
    @props.flux.getActions("game").unselectWood()
  toggleHistory: =>
    @props.flux.getActions("panel").showHistory()
