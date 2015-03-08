React = require('react')
jade = require('react-jade')
_ = require('lodash')

module.exports =
class Room extends React.Component
  constructor: ->
    @state = {
      roomId: ""
    }
  render: =>
    jade.compile("""
    .row
      .col-md-3
        .panel.panel-default
          .panel-body
            h2 Room
            hr
            form(onSubmit=onCreateForm)
              input.control.btn.btn-default(type="submit" value="Create")
            hr
            form(onSubmit=onJoinForm)
              input.control.form-control(type="text" value=roomId placeholder="room name" onChange=handleRoomId)
              input.control.btn.btn-default(type="submit" value="Join")
      .col-md-9
        .panel.panel-default
          .panel-body
            h2 How to use
            ol
              li 「Create」でゲームルームを作る
              li 一緒に遊びたい人にルームID（左のメニューの「Room」）を教える
              li 教わった人はルームIDを入力して「Join」する
              li Enjoy Game!

            hr

            h2 Rule
            h3 勝利条件
            .media
              .media-left.media-middle
                img.media-object(src="images/goal.png")
              .media-body
                h4 相手より先に、自分の駒を向かい側まで導く
            h3 各ターンの行動
            p
              b ２つのアクション
              | を選択する
            .media
              .media-left.media-middle
                img.media-object(src="images/rule01.png")
              .media-body
                h4 1. コマを一マス進める
            .media
              .media-left.media-middle
                img.media-object(src="images/rule02.png")
              .media-body
                h4 2. フェンスで相手の進路を妨害する
            h3 補足
            .media
              .media-left.media-middle
                img.media-object(src="images/rule03.png")
              .media-body
                h4 完全にゴールまでの道を塞げない
            .media
              .media-left.media-middle
                img.media-object(src="images/rule04.png")
              .media-body
                h4 相手をジャンプすることができる
    """)(_.assign(@, @props, @state))

  handleRoomId: (e) =>
    @setState roomId: e.target.value

  onCreateForm: (e) =>
    e.preventDefault()
    socket.emit("create")
    @props.flux.getActions("panel").createBoard()

  onJoinForm: (e) =>
    e.preventDefault()
    if @state.roomId
      socket.emit("join", @state.roomId)
      @props.flux.getActions("panel").joinBoard()
