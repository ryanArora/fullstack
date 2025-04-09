FROM node:22.14.0-slim AS base

# Install dependencies only when needed
FROM base AS deps
RUN apt update && \
    apt upgrade -y && \
    apt install -y postgresql-client && \
    rm -rf /var/lib/apt/lists/*
RUN npm install -g corepack@latest
WORKDIR /app

# Install dependencies based on the preferred package manager
COPY package.json yarn.lock* package-lock.json* pnpm-lock.yaml* pnpm-workspace.yaml* .npmrc* ./
COPY prisma ./prisma
RUN \
  if [ -f yarn.lock ]; then yarn --frozen-lockfile; \
  elif [ -f package-lock.json ]; then npm ci; \
  elif [ -f pnpm-lock.yaml ]; then corepack enable pnpm && pnpm i --frozen-lockfile; \
  else echo "Lockfile not found." && exit 1; \
  fi


# Rebuild the source code only when needed
FROM base AS builder
RUN apt update && \
    apt upgrade -y && \
    apt install -y postgresql-client && \
    rm -rf /var/lib/apt/lists/*
RUN npm install -g corepack@latest
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .

# Environment variables
ARG NEXT_TELEMETRY_DISABLED
ARG PORT
ARG AUTH_SECRET
ARG AUTH_DISCORD_ID
ARG AUTH_DISCORD_SECRET
ARG AUTH_TRUST_HOST
ARG AUTH_URL
ARG AUTH_REDIRECT_PROXY_URL
ARG POSTGRES_USER
ARG POSTGRES_PASSWORD
ARG POSTGRES_HOST
ARG POSTGRES_PORT
ARG POSTGRES_DB
ARG POSTGRES_URL
ARG MINIO_USER
ARG MINIO_PASSWORD
ARG MINIO_ENDPOINT
ARG MINIO_PORT
ARG MINIO_USE_SSL

ENV NEXT_TELEMETRY_DISABLED=$NEXT_TELEMETRY_DISABLED
ENV PORT=$PORT
ENV AUTH_SECRET=$AUTH_SECRET
ENV AUTH_DISCORD_ID=$AUTH_DISCORD_ID
ENV AUTH_DISCORD_SECRET=$AUTH_DISCORD_SECRET
ENV AUTH_TRUST_HOST=$AUTH_TRUST_HOST
ENV AUTH_URL=$AUTH_URL
ENV AUTH_REDIRECT_PROXY_URL=$AUTH_REDIRECT_PROXY_URL
ENV POSTGRES_USER=$POSTGRES_USER
ENV POSTGRES_PASSWORD=$POSTGRES_PASSWORD
ENV POSTGRES_HOST=$POSTGRES_HOST
ENV POSTGRES_PORT=$POSTGRES_PORT
ENV POSTGRES_DB=$POSTGRES_DB
ENV POSTGRES_URL=$POSTGRES_URL
ENV MINIO_USER=$MINIO_USER
ENV MINIO_PASSWORD=$MINIO_PASSWORD
ENV MINIO_ENDPOINT=$MINIO_ENDPOINT
ENV MINIO_PORT=$MINIO_PORT
ENV MINIO_USE_SSL=$MINIO_USE_SSL

RUN \
  if [ -f yarn.lock ]; then yarn run build; \
  elif [ -f package-lock.json ]; then npm run build; \
  elif [ -f pnpm-lock.yaml ]; then corepack enable pnpm && pnpm run build; \
  else echo "Lockfile not found." && exit 1; \
  fi

# Production image, copy all the files and run next
FROM base AS runner
RUN apt update && \
    apt upgrade -y && \
    apt install -y postgresql-client && \
    rm -rf /var/lib/apt/lists/*
RUN npm install -g corepack@latest
WORKDIR /app

ENV NODE_ENV=production

RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

COPY --from=builder /app/public ./public

# Automatically leverage output traces to reduce image size
# https://nextjs.org/docs/advanced-features/output-file-tracing
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

USER nextjs

EXPOSE 3000

ENV PORT=3000

# server.js is created by next build from the standalone output
# https://nextjs.org/docs/pages/api-reference/config/next-config-js/output
ENV HOSTNAME="0.0.0.0"
CMD ["node", "server.js"]