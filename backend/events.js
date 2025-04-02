import { generateFeedback } from "./gameManager.js";

const games = {}; // Active games stored in memory

export const handleSocketEvents = (socket, io) => {
  socket.on("createGame", ({ playerId, gameId }) => {
    const game = games[gameId];
    games[gameId] = {
      player1: playerId,
      player2: null,
      player1Secret: null,
      player2Secret: null,
      turn: null,
      status: "waiting",
      lastChance: false, // Track if the last chance is active
      guesses: { player1: [], player2: [] }, // Store guesses for both players
    };
    socket.join(gameId);
    io.to(gameId).emit("gameCreated", { gameId });
    console.log(playerId, `created a new game: ${gameId}`);
    console.log(games);
    io.emit("gameInfo", game);
  });

  socket.on("joinGame", ({ gameId, playerId }) => {
    const game = games[gameId];
    if (games[gameId] && !games[gameId].player2) {
      games[gameId].player2 = playerId;
      games[gameId].turn = games[gameId].player2;
      io.to(gameId).emit("gameReady", { gameId });
      console.log(playerId, "joined the game");
      console.log(games);
      io.emit('gameJoined', {gameJoined: true, gameId: gameId, playerId: playerId});
    } else if (games[gameId]) {
      return socket.emit("room_error", "Room does not exist!");
    } else if (games[gameId].player2) {
      return socket.emit("room_error", "Room is already full!");
    }  io.emit("gameInfo", game);
  });

  socket.on("submitSecret", ({ gameId, playerId, secretNumber }) => {
    const game = games[gameId];
    if (!game) return;

    if (game.player1 === playerId) {
      game.player1Secret = secretNumber;
    } else {
      game.player2Secret = secretNumber;
    }

    if (game.player1Secret && game.player2Secret) {
      io.to(gameId).emit("startGame", { gameId });
    }
    console.log(games);
    io.emit("gameInfo", game);
  });

  socket.on("makeGuess", ({ gameId, playerId, guess }) => {
    console.log(gameId, playerId, guess );
    const game = games[gameId];
    if (!game || game.turn !== playerId) return;

    const opponent = playerId === game.player1 ? game.player2 : game.player1;
    const secretNumber = playerId === game.player1 ? game.player2Secret : game.player1Secret;
    const feedback = generateFeedback(guess, secretNumber);

    // Store the guess and feedback
    if (playerId === game.player1) {
      game.guesses.player1.push({ guess, feedback });
    } else {
      game.guesses.player2.push({ guess, feedback });
    }

    // Send feedback and updated guesses to all players
    io.to(gameId).emit("feedback", { playerId, guess, feedback });
    io.to(gameId).emit("updateGuesses", { guesses: game.guesses });

    // Check if the player guessed correctly
    if (feedback.position === 4) {
      if (game.lastChance) {
        // If the last player also guessed correctly, it's a draw
        io.to(gameId).emit("gameEnd", { winnerId: null, message: "It's a draw!" });
        delete games[gameId];
        return;
    } else if (game.guesses.player1.length !== game.guesses.player2.length) {
        // If this is the first correct guess, give the opponent one last chance
        game.lastChance = true;
        io.to(opponent).emit("lastChance", { message: "Your opponent guessed correctly! This is your last chance to draw." });
    } else {
        // The opponent failed to guess correctly, declare the first player as the winner
        io.to(gameId).emit("gameEnd", { winnerId: playerId, message: "Game Over! Winner: " + playerId });
        delete games[gameId];
    }
    
    } else {
      // Switch turns if no one has won yet
      game.turn = opponent;
      io.to(gameId).emit("turnChange", { nextPlayer: game.turn });
    }

    console.log(games);
    io.emit("gameInfo", game);
  });

  socket.on("disconnect", () => {
    console.log(`User disconnected: ${socket.id}`);
  });
};
