const socket = io('http://localhost:5000');


const inputValue = document.getElementById('message-input');
const button = document.getElementById('send-btn');
const container = document.getElementById('mess');

button.addEventListener('click', (e) => {
    e.preventDefault();
    console.log('Sending message:', inputValue.value);
    socket.emit('message', inputValue.value);
});

socket.on('messageToAll', message=> {
   container.innerHTML = container.innerHTML + '\n' +  message;
})