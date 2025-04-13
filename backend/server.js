import express from "express";
import { createServer } from "http";
import { Server } from "socket.io";
import dotenv from "dotenv";
import cors from "cors";
import { handleSocketEvents } from "./events.js";

dotenv.config();
const app = express();
const server = createServer(app);
app.use(express.static("public"));


const io = new Server(server, {
  cors: {
    origin: "*",
    methods: ["GET", "POST"]
  }
});

app.use(cors());

app.get("/", (req, res) => res.send("PNG Game Server Running"));

io.on("connection", (socket) => {
  console.log(`User connected: ${socket.id}`);
  handleSocketEvents(socket, io);
});

const PORT = process.env.PORT || 3000;
server.listen(PORT, "0.0.0.0",() => console.log(`Server running on port ${PORT}`));
