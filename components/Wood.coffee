React = require('react')
jade = require('react-jade')
_ = require('lodash')

module.exports =
class Wood extends React.Component
  render: =>
    cx = React.addons.classSet
    classes = cx {
    }
    jade.compile("""
      .wood(class=classes onClick=onClick)
    """)(_.assign(@, @props, @state))
