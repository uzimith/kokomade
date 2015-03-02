React = require('react')
Store = require('flummox').Store
_ = require('lodash')

module.exports =
class HistoryStore extends Store
  constructor: (flux) ->
    super
    gameActions = flux.getActionIds('game')
    @register(gameActions.backHistory, @backHistory)
    @register(gameActions.nextHistory, @nextHistory)
