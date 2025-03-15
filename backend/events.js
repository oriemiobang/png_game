import { generateFeedback } from "./gameManager.js";

const games = {}; // Active games stored in memory

export const handleSocketEvents = (socket, io) => {
  socket.on("createGame", ({ playerId, gameId }) => {


    games[gameId] = {
      player1: playerId,
      player2: null,
      player1Secret: null,
      player2Secret: null,
      turn: null,
      status: "waiting",
      guesses: { player1: [], player2: [] }, // Store guesses for both players
    };
    socket.join(gameId);
    io.to(gameId).emit("gameCreated", { gameId });
    console.log(playerId, `created a new game: ${gameId}`);
    console.log(games)
  });

  socket.on("joinGame", ({ gameId, playerId }) => {
    if (games[gameId] && !games[gameId].player2) {
      games[gameId].player2 = playerId;
      games[gameId].turn = games[gameId].player2;
      io.to(gameId).emit("gameReady", { gameId });
      console.log(playerId, 'joined the game');
      console.log(games)
    }
  });

  socket.on("submitSecret", ({ gameId, playerId, secretNumber }) => {
    console.log(gameId, playerId, secretNumber)
    if (games[gameId].player1 === playerId) {
      games[gameId].player1Secret = secretNumber;
    } else {
      games[gameId].player2Secret = secretNumber;
    }

    if (games[gameId].player1Secret && games[gameId].player2Secret) {
      io.to(gameId).emit("startGame", { gameId });
    }

    console.log(games)
  });

  socket.on("makeGuess", ({ gameId, playerId, guess }) => {
    const game = games[gameId];

    if (!game || game.turn !== playerId) return;

    const secretNumber = playerId === game.player1 ? game.player2Secret : game.player1Secret;
    const feedback = generateFeedback(guess, secretNumber);

    // Store the guess and feedback
    if (playerId === game.player1) {
      game.guesses.player1.push({ guess, feedback });
    } else {
      game.guesses.player2.push({ guess, feedback });
    }

    // Send feedback to all players
    io.to(gameId).emit("feedback", { playerId, guess, feedback });

    // Send updated guesses to both players
    io.to(gameId).emit("updateGuesses", { guesses: game.guesses });

    if (feedback.correctPosition === 4) {
      io.to(gameId).emit("gameEnd", { winnerId: playerId });
      delete games[gameId];
    } else {
      game.turn = game.turn === game.player1 ? game.player2 : game.player1;
      io.to(gameId).emit("turnChange", { nextPlayer: game.turn });
    }
    console.log(games)
  });

  socket.on("disconnect", () => {
    console.log(`User disconnected: ${socket.id}`);
  });
};
