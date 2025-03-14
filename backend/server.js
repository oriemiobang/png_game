const express = require('express');
const {createServer} = require('node:http');
const {Server} = require('socket.io');


const app = express();
const server = createServer(app);
const io  = new Server(server);
app.use(express.static("public"));

io.on('connection', (socket)=> {
    console.log(socket.id, 'has joined our server!');
    socket.on('message', message=> {
        console.log(message);
        socket.emit('messageToAll', message);
    })
});

server.listen(5000, ()=> {
    console.log('Server is running on port 5000')
})