React = require('react')
jade = require('react-jade')
_ = require('lodash')

FluxComponent = require('flummox/component')

Board = require('./Board.coffee')
Controller = require('./Controler.coffee')

module.exports =
class Game extends React.Component
  render: =>
    jade.compile("""
      .row
        .col-md-2.col-md-offset-2
          FluxComponent(connectToStores=['board', 'panel'])
            Controller
        .col-md-8
          Board(board=board)
    """)(_.assign(@, @props, @state))
