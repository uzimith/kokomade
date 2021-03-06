React = require('react')
jade = require('react-jade')
_ = require('lodash')

FluxComponent = require('flummox/component')

Game = require('./Game.coffee')
Room = require('./Room.coffee')
Route = require('./Route.coffee')
ResultModal = require('./ResultModal.coffee')
History = require('./History.coffee')

module.exports =
class Application extends React.Component
  render: =>
    jade.compile("""
      header.navbar.navbar-default.navbar-static-top
        .container
          .navbar-header
            a.navbar-brand(href="/") Kokomade
      .container
            FluxComponent(flux=flux connectToStores=['panel'])
              Route(show="Room")
                FluxComponent(flux=flux)
                  Room
            FluxComponent(flux=flux connectToStores=['panel'])
              Route(show="Board")
                FluxComponent(flux=flux connectToStores=['board', 'panel'])
                  Game
            FluxComponent(flux=flux connectToStores=['panel'])
              Route(show="History")
                FluxComponent(flux=flux connectToStores=['board', 'panel'])
                  History
            FluxComponent(flux=flux connectToStores=['board', 'panel'])
              ResultModal
    """)(_.assign(@, @props, @state))

