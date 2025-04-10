import { generateFeedback } from "./gameManager.js";

const games = {}; // Active games stored in memory
const randomGames = {};
const randomPlaying = {};

export const handleSocketEvents = (socket, io) => {

  socket.on('createRandomGames', ({playerId, gameId})=>{
   
    games[gameId] = {
      player1: playerId,
      gameId: gameId,
      player2: null,
      player1Secret: null,
      player2Secret: null,
      turn: null,
      status: "waiting",
      lastChance: false, // Track if the last chance is active
      guesses: { player1: [], player2: [] }, // Store guesses for both players

    };
    
    randomGames[gameId] ={
      player1: playerId,
      gameId: gameId,
      player2: null,
      player1Secret: null,
      player2Secret: null,
      turn: null,
      status: "waiting",
      lastChance: false, // Track if the last chance is active
      guesses: { player1: [], player2: [] }, // Store guesses for both players

    };
    const game = games[gameId];

    socket.join(gameId);
    io.to(gameId).emit("gameCreated", { gameId });
    console.log(playerId, `created a new game: ${gameId}`);
    console.log(games);
    io.emit("randomGameInfo", randomGames);
    io.to(gameId).emit("gameInfo", game);
  });

  socket.on('joinRandomGame', ({playerId, gameId})=> {

   
    if (games[gameId] && !games[gameId].player2) {
      socket.join(gameId);
      games[gameId].player2 = playerId;
      games[gameId].turn = games[gameId].player2;
      io.to(gameId).emit("gameReady", { gameId });
      console.log(playerId, "joined the game");
      // console.log(game);
      io.emit('gameJoined', {gameJoined: true, gameId: gameId, playerId: playerId});
    } else if (games[gameId]) {
      return socket.emit("room_error", "Room does not exist!");
    } else if (games[gameId].player2) {
      return socket.emit("room_error", "Room is already full!");
    }  
     // console.log('here are the info: ' + playerId + ' ' + gameId);
     const game = games[gameId];
    // randomPlaying[gameId] = game;
    delete randomGames[gameId];

    io.to(gameId).emit("randomRoomGame", game);
    io.emit("randomGameInfo", randomGames);
    io.to(gameId).emit("gameInfo", game);

  });
  socket.on("createGame", ({ playerId, gameId }) => {
    console.log('here are the info: ' + playerId + ' ' + gameId);
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
    io.to(gameId).emit("gameInfo", game);
  });

  socket.on('chat', ({gameId, playerId, message})=>{
    console.log('the sender is ' + playerId);
    io.to(gameId).emit('sendMessage', {gameId: gameId, currentSender: playerId, message: message});

  });

socket.on('newGame',({gameId, playerId})=>{
  io.to(gameId).emit('requestNewGame', {playerId: playerId, message: 'let\'s  play another game!', aprroved: null});
})

  socket.on("joinGame", ({ gameId, playerId }) => {
    console.log('here are the info: ' + playerId + ' ' + gameId);
    const game = games[gameId];
    if (games[gameId] && !games[gameId].player2) {
      socket.join(gameId);
      games[gameId].player2 = playerId;
      games[gameId].turn = games[gameId].player2;
      io.to(gameId).emit("gameReady", { gameId });
      console.log(playerId, "joined the game");
      console.log(game);
      io.emit('gameJoined', {gameJoined: true, gameId: gameId, playerId: playerId});
    } else if (games[gameId]) {
      return socket.emit("room_error", "Room does not exist!");
    } else if (games[gameId].player2) {
      return socket.emit("room_error", "Room is already full!");
    }  io.to(gameId).emit("gameInfo", game);
  });

  socket.on("submitSecret", ({ gameId, playerId, secretNumber }) => {
    const game = games[gameId];
   
    if (!game) return;
    if(game.turn != playerId) {
      io.to(gameId).emit('turnWait',{message: 'Please wait for your turn', player: playerId})

      return
    }
    if (game.player1 === playerId) {
      game.player1Secret = secretNumber;
    } else {
      game.player2Secret = secretNumber;
    }

    if (game.player1Secret && game.player2Secret) {
      io.to(gameId).emit("startGame", { gameId });
    }
    
    const opponent = playerId === game.player1 ? game.player2 : game.player1;
   
    game.turn = opponent;
    console.log(game);
    io.to(gameId).emit("gameInfo", game);

  });

  socket.on("makeGuess", ({ gameId, playerId, guess }) => {
    console.log('here are the info: ' + playerId + ' ' + gameId + ' '+ guess);
    console.log(gameId, playerId, guess );
    const game = games[gameId];
    if (!game) return;
    if(game.turn !== playerId){
      io.to(gameId).emit('turnWait',{message: 'Please wait for your turn', player: playerId})
      console.log('please wait for your turn');
      return
    }

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
        console.log('the game is a draw');
        io.to(gameId).emit("gameInfo", game);
        delete games[gameId];
        // game.turn = null;
        return;
    } else if (game.guesses.player1.length !== game.guesses.player2.length) {
        // If this is the first correct guess, give the opponent one last chance
        game.lastChance = true;
        io.to(gameId).emit("lastChance", { chanceTo: opponent, message: "There is last Chance" });
        console.log('Your opponent guessed correctly! This is your last chance to draw.')
    } else {
        // The opponent failed to guess correctly, declare the first player as the winner
        io.to(gameId).emit("gameEnd", { winnerId: playerId, message: "Game Over!"});
        console.log('game over');
        io.to(gameId).emit("gameInfo", game);
        delete games[gameId];
        // game.turn = null;

        return
    }
    
    } else {

       // 👇🏽 Here's the missing case you need to handle
  if (game.lastChance) {
    // The last chance player failed to guess
    io.to(gameId).emit("gameEnd", { winnerId: opponent, message: "Game Over! Opponent wins." });
    console.log('Game Over! Opponent wins.');
    io.to(gameId).emit("gameInfo", game);
    delete games[gameId];
    return;
  }
      // Switch turns if no one has won yet
      console.log('turn change')
      game.turn = opponent;
      io.to(gameId).emit("turnChange", { nextPlayer: game.turn });
    }

    console.log(games);
    game.turn = opponent;
    io.to(gameId).emit("turnChange", { nextPlayer: game.turn });
    io.to(gameId).emit("gameInfo", game);
    
  });

  socket.on("disconnect", () => {
    console.log(`User disconnected: ${socket.id}`);
  });
};
