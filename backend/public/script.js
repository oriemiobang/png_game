const socket = io('http://localhost:5000');
let game_id;
let player_id;
let secret_number;
const guess_ul = document.getElementById('guess-ul');
const postion_ul =document.getElementById('position-ul');
const number_ul = document.getElementById('number-ul');


let guesses = [];



document.getElementById('create-game').addEventListener('click', function() {
    const playerId = `PNG${[...Array(9)].map(() => Math.floor(Math.random() * 10).toString(10)).join('')}`;
    const gameId = `PNG${[...Array(15)].map(() => Math.floor(Math.random() * 16).toString(16)).join('')}`;
    document.getElementById('playerId').innerHTML = playerId;
    document.getElementById('gameId').innerHTML = gameId;

    game_id = gameId;
    player_id = playerId;

    console.log('creating new game')
    socket.emit('createGame', { playerId: playerId, gameId: gameId});

});
document.getElementById('secret-btn').addEventListener('click', function() {
    // socket.on("submitSecret", ({ gameId, playerId, secretNumber }) => {
   const secretNumber = document.getElementById('secret-input').value;
   document.getElementById('secretNumber').innerHTML = secretNumber;
   secret_number = secretNumber;
    socket.emit('submitSecret', {gameId: game_id, playerId: player_id, secretNumber: secretNumber})
});

socket.on('gameInfo', info => {
    console.log('gameInfo', info)
    const player = info.player1 === player_id? 'player1': 'player2';
    turn = info.turn === player_id? 'Your turn': 'Opponent turn';
  


    info.guesses[player].forEach((playerInfo)=> {

        const li1 = document.createElement('li');
        const li2 = document.createElement('li');
        const li3 = document.createElement('li');


        li1.textContent = playerInfo.guess;
        li2.textContent = playerInfo.feedback.position;
        li3.textContent = playerInfo.feedback.number;

        guess_ul.appendChild(li1);
        postion_ul.appendChild(li2);
        number_ul.appendChild(li3);
    

    });

    
    console.log(player);

});




document.getElementById('join-game').addEventListener('click', function() {
    const inputId = document.getElementById('game-id').value;
    const playerId = `PNG${[...Array(9)].map(() => Math.floor(Math.random() * 10).toString(10)).join('')}`;
    player_id = playerId;
    game_id = inputId;
    document.getElementById('playerId').innerHTML = playerId;
    console.log('joining game')
    socket.emit('joinGame', { gameId: inputId, playerId: playerId });
});


document.getElementById('guess-btn').addEventListener('click', function() {
    // gameId, playerId, guess


   const guessInput = document.getElementById('guess-input').value;


    socket.emit('makeGuess', {gameId: game_id, playerId: player_id, guess: guessInput})
});


// // Game Variables
// let playerId = "player" + Math.floor(Math.random() * 1000);
// let currentGameId = null;

// // HTML Elements
// const createGameBtn = document.getElementById("create-game");
// const joinGameBtn = document.getElementById("join-game");
// const submitSecretBtn = document.getElementById("submit-secret");
// const sendGuessBtn = document.getElementById("send-guess");
// const gameIdInput = document.getElementById("game-id");
// const secretInput = document.getElementById("secret-number");
// const guessInput = document.getElementById("guess-input");
// const gameInfo = document.getElementById("game-info");
// const turnIndicator = document.getElementById("turn-indicator");
// const guessSection = document.getElementById("guess-section");
// const guessList = document.getElementById("guess-list");

// // Generate Random Hexadecimal Game ID
// function generateGameId() {
//     return Math.random().toString(16).substr(2, 10);
// }

// // Create Game
// createGameBtn.addEventListener("click", () => {
//     currentGameId = generateGameId();
//     document.getElementById("current-game-id").innerText = currentGameId;
//     gameInfo.style.display = "block";
//     gameIdInput.value = currentGameId; // Auto-fill input field
//     socket.emit("createGame", { gameId: currentGameId, playerId });
// });

// // Join Game
// joinGameBtn.addEventListener("click", () => {
//     const gameId = gameIdInput.value.trim();
//     if (gameId) {
//         currentGameId = gameId;
//         socket.emit("joinGame", { gameId, playerId });
//         document.getElementById("current-game-id").innerText = currentGameId;
//         gameInfo.style.display = "block";
//     } else {
//         alert("Enter a valid Game ID!");
//     }
// });

// // When Game is Ready
// socket.on("gameReady", (data) => {
//     document.getElementById("current-game-id").innerText = data.gameId;
//     gameInfo.style.display = "block";
//     document.getElementById("secret-input").style.display = "block";
// });

// // Submit Secret Number
// submitSecretBtn.addEventListener("click", () => {
//     const secretNumber = secretInput.value.trim();
//     if (secretNumber.length === 4 && !isNaN(secretNumber)) {
//         socket.emit("submitSecret", { gameId: currentGameId, playerId, secretNumber });
//         document.getElementById("secret-input").style.display = "none";
//     } else {
//         alert("Enter a valid 4-digit number!");
//     }
// });

// socket.on("startGame", () => {
//     guessSection.style.display = "block";
// });

// // Make a Guess
// sendGuessBtn.addEventListener("click", () => {
//     const guess = guessInput.value.trim();
//     if (guess.length === 4 && !isNaN(guess)) {
//         socket.emit("makeGuess", { gameId: currentGameId, playerId, guess });
//         guessInput.value = "";
//     } else {
//         alert("Enter a valid 4-digit number!");
//     }
// });

// // Receive Feedback
// socket.on("feedback", ({ playerId: guessingPlayer, guess, feedback }) => {
//     const guessItem = document.createElement("div");
//     guessItem.innerHTML = `<strong>${guessingPlayer === playerId ? "You" : "Opponent"}:</strong> 
//         ${guess} - Correct Position: ${feedback.correctPosition}, Correct Number: ${feedback.correctNumber}`;
//     guessList.appendChild(guessItem);
// });

// // Update Guesses
// socket.on("updateGuesses", ({ guesses }) => {
//     guessList.innerHTML = "";
//     const allGuesses = [...guesses.player1, ...guesses.player2];
//     allGuesses.forEach(({ guess, feedback }) => {
//         const guessItem = document.createElement("div");
//         guessItem.innerHTML = `Guess: ${guess} - Position: ${feedback.correctPosition}, Number: ${feedback.correctNumber}`;
//         guessList.appendChild(guessItem);
//     });
// });

// // Change Turn
// socket.on("turnChange", ({ nextPlayer }) => {
//     turnIndicator.innerText = nextPlayer === playerId ? "Your Turn" : "Opponent's Turn";
// });

// // Game Over
// socket.on("gameEnd", ({ winnerId }) => {
//     alert(`Game Over! Winner: ${winnerId}`);
// });