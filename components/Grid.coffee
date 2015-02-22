React = require('react')
jade = require('react-jade')
_ = require('lodash')

class Application extends React.Component
  render: =>
    jade.compile("""
      ◯
    """)(_.assign(@, @props, @state))

module.exports = Application
