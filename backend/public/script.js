const socket = io('http://localhost:5000');

// Game Variables
let playerId = "player" + Math.floor(Math.random() * 1000);
let currentGameId = null;

// HTML Elements
const createGameBtn = document.getElementById("create-game");
const joinGameBtn = document.getElementById("join-game");
const submitSecretBtn = document.getElementById("submit-secret");
const sendGuessBtn = document.getElementById("send-guess");
const gameIdInput = document.getElementById("game-id");
const secretInput = document.getElementById("secret-number");
const guessInput = document.getElementById("guess-input");
const gameInfo = document.getElementById("game-info");
const turnIndicator = document.getElementById("turn-indicator");
const guessSection = document.getElementById("guess-section");
const guessList = document.getElementById("guess-list");

// Generate Random Hexadecimal Game ID
function generateGameId() {
    return Math.random().toString(16).substr(2, 10);
}

// Create Game
createGameBtn.addEventListener("click", () => {
    currentGameId = generateGameId();
    document.getElementById("current-game-id").innerText = currentGameId;
    gameInfo.style.display = "block";
    gameIdInput.value = currentGameId; // Auto-fill input field
    socket.emit("createGame", { gameId: currentGameId, playerId });
});

// Join Game
joinGameBtn.addEventListener("click", () => {
    const gameId = gameIdInput.value.trim();
    if (gameId) {
        currentGameId = gameId;
        socket.emit("joinGame", { gameId, playerId });
        document.getElementById("current-game-id").innerText = currentGameId;
        gameInfo.style.display = "block";
    } else {
        alert("Enter a valid Game ID!");
    }
});

// When Game is Ready
socket.on("gameReady", (data) => {
    document.getElementById("current-game-id").innerText = data.gameId;
    gameInfo.style.display = "block";
    document.getElementById("secret-input").style.display = "block";
});

// Submit Secret Number
submitSecretBtn.addEventListener("click", () => {
    const secretNumber = secretInput.value.trim();
    if (secretNumber.length === 4 && !isNaN(secretNumber)) {
        socket.emit("submitSecret", { gameId: currentGameId, playerId, secretNumber });
        document.getElementById("secret-input").style.display = "none";
    } else {
        alert("Enter a valid 4-digit number!");
    }
});

socket.on("startGame", () => {
    guessSection.style.display = "block";
});

// Make a Guess
sendGuessBtn.addEventListener("click", () => {
    const guess = guessInput.value.trim();
    if (guess.length === 4 && !isNaN(guess)) {
        socket.emit("makeGuess", { gameId: currentGameId, playerId, guess });
        guessInput.value = "";
    } else {
        alert("Enter a valid 4-digit number!");
    }
});

// Receive Feedback
socket.on("feedback", ({ playerId: guessingPlayer, guess, feedback }) => {
    const guessItem = document.createElement("div");
    guessItem.innerHTML = `<strong>${guessingPlayer === playerId ? "You" : "Opponent"}:</strong> 
        ${guess} - Correct Position: ${feedback.correctPosition}, Correct Number: ${feedback.correctNumber}`;
    guessList.appendChild(guessItem);
});

// Update Guesses
socket.on("updateGuesses", ({ guesses }) => {
    guessList.innerHTML = "";
    const allGuesses = [...guesses.player1, ...guesses.player2];
    allGuesses.forEach(({ guess, feedback }) => {
        const guessItem = document.createElement("div");
        guessItem.innerHTML = `Guess: ${guess} - Position: ${feedback.correctPosition}, Number: ${feedback.correctNumber}`;
        guessList.appendChild(guessItem);
    });
});

// Change Turn
socket.on("turnChange", ({ nextPlayer }) => {
    turnIndicator.innerText = nextPlayer === playerId ? "Your Turn" : "Opponent's Turn";
});

// Game Over
socket.on("gameEnd", ({ winnerId }) => {
    alert(`Game Over! Winner: ${winnerId}`);
});