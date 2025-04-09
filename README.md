# `fullstack`

This is a fullstack template.

## Development

Open in the repository using the Dev Containers vscode extension. Then:

### First Time

```bash
pnpm generate-env
docker compose up -d
pnpm db:push
pnpm db:seed
docker compose down
```

### After

```bash
docker compose up    # Start postgres, minio
pnpm dev             # Start NextJS
```
