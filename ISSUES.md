# PNG Game — Production Issues & Feature Roadmap

> **PNG** is a 2-player number-guessing game. Each player secretly picks a 4-digit number (all unique digits). Players take turns guessing the opponent's number and receive feedback in **Position** (right digit, right place) and **Number** (right digit, wrong place) until someone cracks the code.
>
> This file catalogs every known gap, bug, and planned feature needed to take the game to production. Issues are grouped by area and ordered by rough priority.

---

## Legend
- 🔴 **Critical** — Blocks launch / breaks core gameplay
- 🟠 **High** — Significantly degrades experience
- 🟡 **Medium** — Important feature or polish
- 🟢 **Low** — Nice-to-have / future improvement

---
<!-- 
## SECTION 1 — Matchmaking System (Chess.com-style)

### ISSUE-001 🔴 Implement Smart Auto-Pairing (Replace Room Listing)
**Current state:** Player A creates a room → gets a room code → Player B has to browse a room list and manually click "Join Room".  
**Desired state (like Chess.com):** Both players go to "Play" → pick settings (rounds, timer) → click one button → the system intelligently matches them without either player ever seeing the other's room or clicking a join button.

**Backend tasks:**
- Add a `matchmaking_queue` table (or in-memory queue per settings key) that stores waiting players with their chosen settings.
- On `createGame` event, before creating a room, check if a compatible waiting entry exists (same `maxRounds` + same `timeLimit` ± tolerance).
- If a compatible player is waiting → auto-create the game, put both players in it, emit `matchFound` to both sockets with the new `gameId`, and remove the queue entry.
- If no match → add current player to the queue and wait.
- Expose a `cancelMatchmaking` socket event so a player can leave the queue.
- Add a queue TTL (e.g., 5 minutes) after which the entry expires and the player is notified.

**Frontend tasks:**
- Replace the two-step "Create Game → Waiting Room (with share code)" flow with a single "Find Match" screen.
- Show an animated "Searching for opponent…" state with the selected settings.
- Listen for the new `matchFound` event and auto-navigate to `/play_board`.
- Show a "Cancel Search" button.
- Keep the old private-room invite flow (QR / code) as an optional path, but it should no longer be the default.

--- -->

<!-- ### ISSUE-002 🟠 Private Room Flow Needs Cleanup
**Current state:** `CreateRoom` screen always shows QR + room code even for public games. Settings shown in the footer are hardcoded ("Best of 3", "60s / turn").  
**Tasks:**
- Only show QR / share-code UI when `isPrivate = true`.
- Display actual room settings (rounds, time) from the game data instead of hardcoded strings.
- On the waiting screen, show the opponent's name / avatar once they join (currently shows "Waiting…" forever).
- Add a "Cancel Room" button that deletes the game from the DB and returns to home.

---

## SECTION 2 — Rating / ELO System

### ISSUE-003 🔴 Add ELO Rating to User Model
**Current state:** `User` model has `wins`, `losses`, `draws`, `gamesPlayed` — no rating field.  
**Backend tasks (Prisma migration):**
```
model User {
  ...
  rating     Int  @default(1200)   // Starting ELO
  ratingPeak Int  @default(1200)   // All-time best
}
```
- Run `prisma migrate dev` with a new migration file.
- Seed all existing users with 1200.

--- -->

<!-- ### ISSUE-004 🔴 Implement ELO Calculation Engine
**Current state:** `recordUserOutcome()` only increments `wins/losses/draws`.  
**Algorithm (standard ELO):**
```
K = 32  (use K=40 for new players with < 30 games, K=20 for > 100 games)
E_a = 1 / (1 + 10^((R_b - R_a) / 400))
E_b = 1 - E_a

Win:  R_a += K * (1 - E_a)
Loss: R_a += K * (0 - E_a)
Draw: R_a += K * (0.5 - E_a)
```
**Tasks:**
- Create `src/rating/rating.service.ts` with `calculateNewRatings(player1Rating, player2Rating, outcome)`.
- Call it inside `recordUserOutcome()` after the match ends.
- Update both players' `rating` and `ratingPeak` in a single Prisma transaction.
- Include `ratingChange` (+/-) in the `gameEnd` socket event payload so the frontend can show it immediately.

--- -->

<!-- ### ISSUE-005 🟠 Expose Rating on Game & Result Screens
**Frontend tasks:**
- Show each player's current rating next to their name on the Play Board (e.g., "You — ⭐ 1,204").
- On the `GameResultPage`, show a rating change card: "+18 🟢" or "-12 🔴" per player.
- On the Home Page / Profile, display current rating and peak rating.

---

### ISSUE-006 🟡 Add Rating Tiers / Badges
**Tasks:**
- Define tiers: Beginner (< 1000), Intermediate (1000–1400), Advanced (1400–1800), Expert (1800–2200), Master (2200+).
- Show a badge icon/color next to each player's name everywhere ratings appear.
- Backend: add a computed `tier` field to the `/auth/me` response.

--- -->

<!-- ## SECTION 3 — Chess Timer (Per-Player Clock)

### ISSUE-007 🔴 Fix Timer Initialization Bug
**Current state:** `timeLimit` is stored in **minutes** in the DB (e.g., `3`). In `submitSecret()` the code does `game.timeLimit * 60 * 1000` which is correct, but `CreateGames` passes `timeLimit` in minutes while the backend `createGame` service stores it as-is. Needs to be explicit and consistent.  
**Tasks:**
- Decide on a canonical unit (**seconds** recommended) and enforce it everywhere.
- Fix `submitSecret()` — if `timeLimit` is already in seconds, multiply by 1000; if in minutes, multiply by 60000.
- Add a comment in the schema clarifying the unit.

---

### ISSUE-008 🔴 Server-Side Timeout Enforcement (Ticker)
**Current state:** Timeout is only triggered when the player makes a guess (lazy check). If a player just goes idle and never guesses, the game stalls forever.  
**Tasks:**
- In `GameGateway`, maintain a `Map<gameId, NodeJS.Timeout>` of active turn timers.
- When a turn starts (`submitSecret` starts the game, or a guess is processed and the game continues), schedule a server-side `setTimeout` for the remaining time of the active player.
- When it fires, call the existing timeout logic (mark the game finished, award the win to the opponent) and emit `gameEnd` without waiting for the player to act.
- Clear and reset the timer each time a valid guess arrives.

---

### ISSUE-009 🟠 Timer State Persistence Across Reconnects
**Current state:** If a player disconnects and reconnects, the timer on their device resets because `lastMoveAt` is the only anchor. The device-local elapsed calculation can drift significantly.  
**Tasks:**
- On reconnect (new socket connects with the same `playerId` + `gameId`), re-join the socket room and emit a fresh `gameInfo` with the current server-side time remaining.
- Store the active player's turn start time on the server (`turnStartedAt: DateTime`) to allow precise remaining-time calculation.
- Add `turnStartedAt` field to the `Game` model.

--- -->

<!-- ### ISSUE-010 🟠 Fix Timer Display — Opponent vs Self
**Current state:** In `play_board.dart` line 412, `_buildTimerBadge(!isPlayer1 ? _player1TimeLeft : _player2TimeLeft, !isMyTurn)` — this logic is inverted and shows the wrong timer for the opponent in some configurations.  
**Tasks:**
- Audit and fix the timer badge logic so "You" always shows the current player's clock and "Opponent" always shows the opponent's clock, regardless of player1/player2 assignment.
- Add visual urgency state (e.g., red color, pulsing) when < 30 seconds remain.

--- -->

<!-- ## SECTION 4 — Backend Architecture & Reliability

### ISSUE-011 🔴 MatchState Lives Only in Memory (No Persistence)
**Current state:** `GameService.matchStates` is a `Map` in the NestJS singleton. If the server restarts (crash, deploy, scale-out), **all active match states are lost** — round wins, round history, current round number.  
**Tasks:**
- Migrate `MatchState` to the database. Add columns to `Game`:
  ```
  currentRound    Int  @default(1)
  player1RoundWins Int @default(0)
  player2RoundWins Int @default(0)
  ```
- Move `roundHistory` to a new `RoundResult` model linked to `Game`.
- Remove the in-memory `matchStates` Map.
- This also fixes the bug where round state is silently lost on reconnect.

---

### ISSUE-012 🔴 Socket Authentication — Anyone Can Emit Events
**Current state:** All WebSocket events accept `playerId` from the payload (client-controlled). A malicious client can spoof any `playerId` and make moves on behalf of another player.  
**Tasks:**
- Implement JWT authentication for WebSocket connections. Send the JWT in the `auth` handshake option from the Flutter client.
- In `GameGateway`, use a `WsGuard` or `handleConnection` to verify the token and store the authenticated user on `client.data.userId`.
- Replace all `payload.playerId` usages with `client.data.userId`.
- Reject connections without a valid token.

--- -->

<!-- ### ISSUE-013 ✅ No Input Validation on Socket Events
**Current state:** Payloads are used directly with no validation (no NestJS `ValidationPipe`, no DTOs on the gateway).  
**Tasks:**
- Create DTOs (`CreateGameDto`, `MakeGuessDto`, `SubmitSecretDto`, etc.) using `class-validator`.
- Enable `ValidationPipe` globally or per gateway.
- Return a structured `room_error` for invalid payloads.

---

### ISSUE-014 ✅ Forfeit / Leave Game Logic is Missing
**Current state:** When a player taps "Leave Game" on the Play Board, the app just navigates to `/` locally. The opponent is never notified, the game stays in `playing` status forever in the DB, and the leaving player suffers no consequences (no rating loss, no loss recorded).  
**Tasks:**
- Add a `forfeit` socket event.
- Server marks game `finished`, awards win + rating to the remaining player, records the loss for the forfeiting player.
- Emit `gameEnd` to both clients.
- Add a `leaveGame` gateway handler that handles the client disconnecting mid-game gracefully.

---

### ISSUE-015 ✅ Handle Disconnect Mid-Game (Reconnection Window)
**Current state:** `handleDisconnect` only logs. If a player disconnects mid-game there is no grace period or automatic forfeit.  
**Tasks:**
- On disconnect, start a server-side countdown (e.g., 60 seconds grace period).
- If the player reconnects within the window, rejoin their socket room and restore game state.
- If they don't reconnect, trigger forfeit logic (ISSUE-014).
- Emit `opponentDisconnected` to the other player immediately so they know their opponent dropped.

--- -->

<!-- ### ISSUE-016 🟠 Old Backend (`/backend`) Should Be Removed or Documented
**Current state:** There is a plain Node.js/Express + Socket.io backend in `/backend/` alongside the production NestJS backend in `/nestjs-backend/`. This is confusing.  
**Tasks:**
- Decide: archive it (move to a `_legacy` folder) or delete it.
- Update any documentation or `.env` references. -->

---

### ISSUE-017 🟡 Rate Limiting on Auth and Game Events
**Tasks:**
- Add `throttler` guard (`@nestjs/throttler`) to `AuthController` endpoints (sign-in, sign-up, Google OAuth).
- Add per-socket event rate limiting to prevent guess spamming.

---

### ISSUE-018 🟡 Database Indexing
**Tasks:**
- Add index on `Game.status` + `Game.isPrivate` for the `getPublicRooms()` query.
- Add index on `Guess.gameId` + `Guess.round` for per-round queries.
- Add index on `User.rating` for leaderboard queries.

---

### ISSUE-019 🟡 Environment Variable Validation
**Current state:** `DATABASE_URL`, `JWT_SECRET`, `GOOGLE_CLIENT_ID` are read from `.env` with no startup validation.  
**Tasks:**
- Use `@nestjs/config` with `Joi` schema validation so the server refuses to start if required env vars are missing.
- Add a `.env.example` file documenting all variables.

---

## SECTION 5 — Frontend Architecture & UX

### ISSUE-020 🔴 `randomWaitRoom.dart` is a Stub
**Current state:** The `RandomWaitRoom` screen displays "Wait here" with no logic. The `createRandomGame` and `joinRandomGames` socket events are emitted but there is no server-side handler for `createRandomGames` in the NestJS gateway.  
**Tasks:**
- Implement this screen as part of the new matchmaking flow (ISSUE-001) or remove it entirely.
- The server gateway needs to handle `createRandomGames` → delegate to the matchmaking queue.

---

### ISSUE-021 🔴 Game Result Page — Rating Change Not Shown
**Current state:** `GameResultPage` shows round scores, guesses, and time — but no rating change.  
**Tasks:**
- After ISSUE-004 lands, display a "Rating" card: previous rating → new rating → delta (e.g., `1200 → 1218 (+18)`).
- Animate the number change on page load.

---

### ISSUE-022 🟠 Player Names / Avatars Are Never Shown
**Current state:** Everywhere in the app, players are referred to as "You" and "Opponent" with no names. The room list shows the raw UUID as "Host".  
**Tasks:**
- Include `player1Name`, `player2Name` (and avatars if applicable) in `gameInfo` responses.
- Update `game.gateway.ts` / `game.service.ts` to select `name` from the `User` relation.
- Update Flutter screens to display names and initial-based avatar circles.
- Replace the raw UUID in `rooms_page.dart` line 176 with the player's actual name.

---

### ISSUE-023 🟠 No Profile / Stats Screen
**Current state:** There is a `/auth/me` endpoint with stats, but no screen in the app to display them.  
**Tasks:**
- Build a `ProfileScreen` showing: name, email, rating, peak rating, tier badge, games played, wins, losses, draws, win rate, last played.
- Add navigation to it from the Home Page (avatar tap or menu icon).

---

### ISSUE-024 🟠 No Leaderboard Screen
**Tasks:**
- Backend: add `GET /auth/leaderboard` endpoint returning top N users sorted by `rating DESC`.
- Frontend: build a `LeaderboardScreen` with rank, name, rating, tier badge, win rate.

---

### ISSUE-025 🟠 Home Page Needs a Proper "Play Now" Entry Point
**Current state:** The Home Page has multiple entry points (Create Game, Join Game, Rooms, Random) which are confusing.  
**Tasks:**
- After ISSUE-001 lands, simplify to: **"Play Now"** (auto-matchmaking) + **"Play Private"** (invite a friend).
- Remove the rooms browsing flow from the main navigation.

---

### ISSUE-026 🟠 Game Board UX — No Real-Time Turn Animation
**Current state:** Turn changes are communicated only via text ("YOUR TURN" / "OPPONENT'S TURN") and a status badge color.  
**Tasks:**
- Add a subtle animation / pulse on the active timer badge when it's your turn.
- Show a small toast/snackbar "Your turn!" when control returns to you.
- Dim the guess input and send button (disable them) while it's the opponent's turn (currently only disabled via `onPressed: isMyTurn ? _submitGuess : null` — no visual dimming).

---

### ISSUE-027 🟡 Guess History — Add Color-Coded Digit Indicators
**Current state:** Guesses show a plain 4-digit number with "P: 2, N: 1" badges.  
**Tasks:**
- Color each digit cell: **green** if position-correct, **orange** if number-correct but wrong position, **grey** if not in the secret. (Like Wordle-style feedback per digit.)
- This requires the backend to return per-digit feedback instead of aggregate counts.
- Backend: add `positionDetails` (array of booleans) and `numberDetails` to the guess response.

---

### ISSUE-028 🟡 Chat System — Messages Not Persisted Per Round
**Current state:** `chat` event is "not saved to DB" (comment in gateway). Chat messages are lost on page refresh or reconnect.  
**Tasks:**
- Decide: either explicitly keep chat ephemeral (in-memory per session, which is fine) and add a visual "messages are not saved" disclaimer, OR persist them in a `ChatMessage` model.
- The chat screen (`chat_room.dart`) must not crash when the game data hasn't loaded yet.

---

### ISSUE-029 🟡 No Push Notifications
**Tasks:**
- Integrate Firebase Cloud Messaging (FCM) — Firebase config already exists in the project.
- Notify a player when: their opponent joins their room, it's their turn, they get a match.
- Backend: store `fcmToken` on the User model; send notifications via Firebase Admin SDK from NestJS.

---

### ISSUE-030 🟡 App Theme & Branding Is Inconsistent
**Current state:** Some screens use `Colors.blueGrey.shade50` background, others `Color(0xFFF4F5F7)`. Some use `Colors.blue.shade600`, others `Colors.blueAccent`. No centralized theme.  
**Tasks:**
- Define a `ThemeData` in `main.dart` with a consistent primary color, color scheme, text styles, and shape defaults.
- Use `Theme.of(context)` everywhere instead of hardcoded colors.
- Pick and embed a custom Google Font (e.g., "Outfit" or "Inter").

---

## SECTION 6 — Game Logic Bugs

### ISSUE-031 🔴 Round Win Accounting Is Incorrect
**Current state:** `recordRoundResult` increments `player1Wins` / `player2Wins` in memory, but `resetMatch` is supposed to advance to the next round. However, calling `resetMatch` with `resetSeries = false` only increments `currentRound` — it does **not** check if the series winner has been decided. The match can exceed `maxRounds` if the client keeps calling `newGame`.  
**Tasks:**
- After advancing the round, check if either player has won the majority (e.g., > `maxRounds / 2` rounded up). If so, emit `matchOver` instead of resetting.
- Persist round wins to the DB (ISSUE-011).

---

### ISSUE-032 🔴 Guess Count Logic — "Max Rounds" Meaning Is Ambiguous
**Current state:** `maxRounds` is used both as the number of rounds in the series AND as the max number of guesses per round (line 413 in `game.service.ts`: `p1Guesses.length >= game.maxRounds`). These are two different concepts.  
**Tasks:**
- Rename `maxRounds` to `seriesLength` (number of rounds in the match).
- Add a separate `maxGuessesPerRound` field (or remove the per-round guess limit and rely solely on the timer).
- Decide the correct game design and update the schema and logic accordingly.

---

### ISSUE-033 🟠 `lastChance` Flag is Never Reset Between Rounds
**Current state:** After a round ends with a `lastChance` draw, `resetMatch` does reset `lastChance: false` ✅. But if the `lastChance` event fires and then the round ends normally (opponent wins), the flag stays `true` in the DB until the next `resetMatch`.  
**Tasks:**
- Review all code paths where `lastChance` can be left `true` after a round ends without it being consumed.
- Add a `lastChance: false` reset wherever game status transitions to `finished`.

---

### ISSUE-034 🟠 Timeout Handler is a Hack
**Current state:** `handleTimeout` in the gateway sends a fake `TIMEOUT_CHECK` guess to the `makeGuess` handler. This will throw a validation error if DTOs are added (ISSUE-013) and is semantically wrong.  
**Tasks:**
- Create a dedicated `handleTimeout` pathway in `GameService` that directly marks the game finished without going through the guess logic.
- Emit `gameEnd` directly from `handleTimeout` in the gateway.

---

### ISSUE-035 🟡 Draws Are Recorded Wrongly in Multi-Round Matches
**Current state:** `recordUserOutcome` is called with `isDraw = true` when a single round is a draw, but this increments the user's `draws` counter — even if the overall series is not a draw (one player can still win the series).  
**Tasks:**
- Only update `draws` on the `User` model when the entire **series** is a draw (equal round wins after all rounds).
- Use round-level results for in-game display and series-level results for persistent stats and rating.

---

## SECTION 7 — Security & Production Readiness

### ISSUE-036 🔴 Google OAuth Client ID Not Verified
**Current state:** `auth.service.ts` line 56: `// audience: process.env.GOOGLE_CLIENT_ID` is commented out. This means **any** valid Google token is accepted, not just tokens intended for this app.  
**Tasks:**
- Uncomment and set `GOOGLE_CLIENT_ID` in `.env`.
- Add `GOOGLE_CLIENT_ID` to the NestJS config validation (ISSUE-019).

---

### ISSUE-037 🔴 JWT Secret Hardcoded / Not Validated
**Tasks:**
- Ensure `JWT_SECRET` is a long (≥ 64 char) random string in production `.env`.
- Set a reasonable token expiry (e.g., `7d`) and implement refresh token flow if sessions should be longer.

---

### ISSUE-038 🔴 CORS is `origin: '*'`
**Current state:** WebSocket gateway and (presumably) HTTP server allow all origins.  
**Tasks:**
- Restrict CORS to the actual deployed frontend origin(s) in production.
- Use environment variables for allowed origins.

---

### ISSUE-039 🟠 No HTTPS / WSS Enforcement
**Tasks:**
- Ensure the deployed server uses TLS (HTTPS + WSS). Add redirect from HTTP → HTTPS.
- Update Flutter `AppEnv.backendBaseUrl` to use `wss://` and `https://`.

---

### ISSUE-040 🟠 Flutter Backend URL is Hardcoded
**Current state:** `core/env.dart` presumably has the backend URL hardcoded (seen referenced in `socket_service.dart`).  
**Tasks:**
- Use Flutter's `--dart-define` or `.env` approach to configure the URL per build flavor (dev / staging / prod).
- Add separate `debug` and `release` configurations.

---

## SECTION 8 — DevOps & Deployment

### ISSUE-041 🟠 No CI/CD Pipeline
**Tasks:**
- Set up GitHub Actions (or equivalent):
  - Backend: lint → test → Docker build → deploy to server.
  - Frontend: `flutter analyze` → `flutter test` → `flutter build apk/ios`.

---

### ISSUE-042 🟠 No Unit / Integration Tests
**Tasks:**
- Backend: write Jest unit tests for `GameService.generateFeedback`, `calculateNewRatings`, and matchmaking queue logic.
- Frontend: write widget tests for `PlayBoard`, `GameResultPage`.
- Add integration tests for the complete game flow (create → join → secret → guess → end).

---

### ISSUE-043 🟡 Dockerize the NestJS Backend
**Tasks:**
- Write a `Dockerfile` for `nestjs-backend`.
- Write a `docker-compose.yml` with NestJS + PostgreSQL.
- Add health-check endpoint `GET /health`.

---

### ISSUE-044 🟡 Database Backups & Migration Strategy
**Tasks:**
- Set up automated daily PostgreSQL backups (pg_dump to S3 or equivalent).
- Document the Prisma migration workflow for production (`prisma migrate deploy`).

---

## SECTION 9 — Game Settings & Quality of Life

### ISSUE-045 🟡 Room Name Field Has No Effect
**Current state:** `CreateGames` has a "Room Name" text field whose value is stored in a local `roomName` variable but never sent to the server or stored in the DB.  
**Tasks:**
- Either remove the room name field (games are identified by code) or add a `name` field to the `Game` model and pass it through.

---

### ISSUE-046 🟡 Add Sound Effects & Haptic Feedback
**Tasks:**
- Use `audioplayers` package for: correct guess sound, wrong guess sound, timer warning tick, game end fanfare.
- Use `HapticFeedback.lightImpact()` on guess submit and turn change.

---

### ISSUE-047 🟢 Dark Mode Support
**Tasks:**
- Extend the theme (ISSUE-030) to support a dark color scheme.
- Persist the user's theme preference in local storage.

---

### ISSUE-048 🟢 Localization / i18n
**Tasks:**
- Add `flutter_localizations` and `intl`.
- Externalize all user-visible strings to ARB files.
<!-- - Support at minimum English + Arabic (considering the project owner's locale). -->

---

## Summary Table

| # | Area | Priority | Title |
|---|------|----------|-------|
| 001 | Matchmaking | 🔴 | Chess.com-style Auto-Pairing |
| 002 | Matchmaking | 🟠 | Private Room Flow Cleanup |
| 003 | Rating | 🔴 | Add ELO Field to User Model |
| 004 | Rating | 🔴 | ELO Calculation Engine |
| 005 | Rating | 🟠 | Show Rating on Screens |
| 006 | Rating | 🟡 | Rating Tiers & Badges |
| 007 | Timer | 🔴 | Fix Timer Unit Inconsistency |
| 008 | Timer | 🔴 | Server-Side Timeout Enforcement |
| 009 | Timer | 🟠 | Timer State on Reconnect |
| 010 | Timer | 🟠 | Fix Timer Display Bug |
| 011 | Backend | 🔴 | MatchState to Database |
| 012 | Backend | 🔴 | WebSocket Authentication |
| 013 | Backend | 🔴 | Input Validation / DTOs |
| 014 | Backend | 🟠 | Forfeit / Leave Logic |
| 015 | Backend | 🟠 | Disconnect Grace Period |
| 016 | Backend | 🟠 | Remove Legacy Backend |
| 017 | Backend | 🟡 | Rate Limiting |
| 018 | Backend | 🟡 | Database Indexing |
| 019 | Backend | 🟡 | Env Var Validation |
| 020 | Frontend | 🔴 | Random Wait Room Stub |
| 021 | Frontend | 🔴 | Rating Change on Result Page |
| 022 | Frontend | 🟠 | Show Player Names Everywhere |
| 023 | Frontend | 🟠 | Profile / Stats Screen |
| 024 | Frontend | 🟠 | Leaderboard Screen |
| 025 | Frontend | 🟠 | Simplify Home Page |
| 026 | Frontend | 🟠 | Turn Animation UX |
| 027 | Frontend | 🟡 | Per-Digit Color Feedback |
| 028 | Frontend | 🟡 | Chat Persistence / Disclaimer |
| 029 | Frontend | 🟡 | Push Notifications (FCM) |
| 030 | Frontend | 🟡 | Consistent Theme & Branding |
| 031 | Game Logic | 🔴 | Round Win Accounting Bug |
| 032 | Game Logic | 🔴 | maxRounds vs maxGuesses Ambiguity |
| 033 | Game Logic | 🟠 | lastChance Flag Not Reset |
| 034 | Game Logic | 🟠 | Timeout Handler Hack |
| 035 | Game Logic | 🟡 | Draws Recorded Incorrectly |
| 036 | Security | 🔴 | Google OAuth Audience Not Verified |
| 037 | Security | 🔴 | JWT Secret Validation |
| 038 | Security | 🔴 | CORS Wildcard |
| 039 | Security | 🟠 | HTTPS / WSS Enforcement |
| 040 | Security | 🟠 | Hardcoded Backend URL |
| 041 | DevOps | 🟠 | CI/CD Pipeline |
| 042 | DevOps | 🟠 | Unit & Integration Tests |
| 043 | DevOps | 🟡 | Dockerize Backend |
| 044 | DevOps | 🟡 | DB Backups & Migration Strategy |
| 045 | QoL | 🟡 | Room Name Field Has No Effect |
| 046 | QoL | 🟡 | Sound Effects & Haptics |
| 047 | QoL | 🟢 | Dark Mode |
| 048 | QoL | 🟢 | Localization / i18n |

---

*Last updated: 2026-06-22*
