express = require('express')
app = express()
http = require('http').Server(app)
io = require('socket.io')(http)
port = process.env.PORT || 3001
app.use express.static('.')

_ = require('lodash')

io.on 'connection', (socket) ->
  console.log('a user connected')

  socket.on 'create', ->
    loop
      name = (Math.floor(Math.random() * 10) for _ in [0...5]).join("")
      break unless name in Object.keys(io.sockets.adapter.rooms)
    console.log("create : " + name)
    socket.game_room = name
    socket.join(name)
    socket.emit('join', name)
    socket.emit('count', Object.keys(io.sockets.adapter.rooms[socket.game_room]).length)

  socket.on 'join', (name) ->
    console.log("join : " + name)
    socket.game_room = name
    socket.join(name)
    socket.emit('join', name)
    socket.emit('count', Object.keys(io.sockets.adapter.rooms[socket.game_room]).length)
    socket.to(socket.game_room).emit('count', Object.keys(io.sockets.adapter.rooms[socket.game_room]).length)

  socket.on 'leave', (name) ->
    socket.leave(name)

  socket.on 'action', (data) ->
    console.log(data)
    socket.to(socket.game_room).broadcast.emit('action', data)

  socket.on 'disconnect', ->
    console.log("a user disconnected")
    if io.sockets.adapter.rooms[socket.game_room]
      socket.to(socket.game_room).emit('count', Object.keys(io.sockets.adapter.rooms[socket.game_room]).length)


http.listen port, ->
  console.log "listening on *:", port
