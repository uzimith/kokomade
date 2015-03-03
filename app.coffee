window.socket = require('socket.io-client')()

React = require('react')
injectTapEventPlugin = require("react-tap-event-plugin")
injectTapEventPlugin()

jade = require('react-jade')
_ = require('lodash')
Application = require('./components/Application.coffee')
AppFlux = require('./dispatcher/AppFlux.coffee')

flux = new AppFlux

require('./socket.coffee')(flux)

React.render(React.createFactory(Application)(flux: flux), document.getElementById("container"))
