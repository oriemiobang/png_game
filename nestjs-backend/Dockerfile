FROM node:20-alpine AS builder

WORKDIR /app

# Copy package.json and lockfile
COPY package*.json ./
COPY prisma ./prisma/

# Install dependencies
RUN npm ci

# Copy the rest of the application
COPY . .

# Generate Prisma Client
RUN npx prisma generate

# Build the application
RUN npm run build

# Second stage for the final production image
FROM node:20-alpine AS runner

WORKDIR /app

# Install only production dependencies
COPY package*.json ./
RUN npm ci --only=production

# Copy generated Prisma client
COPY --from=builder /app/node_modules/.prisma ./node_modules/.prisma
COPY --from=builder /app/node_modules/@prisma ./node_modules/@prisma

# Copy the built application
COPY --from=builder /app/dist ./dist

# Expose the API port
EXPOSE 3000

# Start the application
CMD ["npm", "run", "start:prod"]
