React = require('react')
jade = require('react-jade')
_ = require('lodash')

module.exports =
class ResultModal extends React.Component
  render: =>
    cx = React.addons.classSet

    classes = cx {
      in: @props.showResult
      show: @props.showResult
    }

    player_class =
      1: cx(player1: true)
      2: cx(player2: true)
      3: cx(player3: true)
      4: cx(player4: true)

    jade.compile("""
      .modal.fade(class=classes)
        .modal-dialog
          .modal-content
            .modal-header
              button.close(onClick=onClick)
                span &times;
              h4.modal-title Result
            .modal-body
            .modal-footer
              h4.winner
                if winner === 0
                  span Draw
                else
                  span Winner : 
                  span.result(class=player_class[winner])= "Player " + winner

    """)(_.assign(@, @props, @state))

  onClick: =>
    @props.flux.getActions("panel").hideResult()
