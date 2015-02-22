React = require('react')
jade = require('react-jade')
_ = require('lodash')

FluxComponent = require('flummox/component')

class Application extends React.Component
  render: =>
    jade.compile("""
      h1 Kokomade
    """)(_.assign(@, @props, @state))

module.exports = Application
