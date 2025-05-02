# Stage 1: Build with native deps
FROM node:20-slim AS builder
WORKDIR /app
COPY . .
RUN apt-get update && apt-get install -y python3 make g++
RUN corepack enable && corepack prepare pnpm@9.14.2 --activate
RUN pnpm install --frozen-lockfile
RUN pnpm run build
RUN pnpm prune --prod

# Stage 2: Runtime only
FROM node:20-slim
WORKDIR /app
COPY --from=builder /app/build ./build
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./
CMD ["node", "build/index.js"]
