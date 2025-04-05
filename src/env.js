import { createEnv } from "@t3-oss/env-nextjs";
import { z } from "zod";

const booleanSchema = z
  .string()
  .refine(
    (val) => val === "true" || val === "1" || val == "false" || val == "0",
    "Must be a boolean",
  )
  .transform((val) => val === "true" || val === "1");

const trueSchema = booleanSchema.refine((val) => val === true, "Must be true");

const portSchema = z.coerce
  .number()
  .int("Must be an integer between 1 and 65535")
  .min(1, "Must be an integer between 1 and 65535")
  .max(65535, "Must be an integer between 1 and 65535");

export const env = createEnv({
  server: {
    NODE_ENV: z
      .enum(["development", "test", "production"])
      .default("development"),
    NEXT_TELEMETRY_DISABLED: trueSchema,
    AUTH_SECRET: z.string(),
    AUTH_DISCORD_ID: z.string(),
    AUTH_DISCORD_SECRET: z.string(),
    AUTH_TRUST_HOST: trueSchema,
    AUTH_URL: z.string().url(),
    POSTGRES_USER: z.string(),
    POSTGRES_PASSWORD: z.string(),
    POSTGRES_HOST: z.string(),
    POSTGRES_PORT: portSchema,
    POSTGRES_DB: z.string(),
    POSTGRES_URL: z.string().url(),
    MINIO_USER: z.string(),
    MINIO_PASSWORD: z.string(),
    MINIO_HOST: z.string(),
    MINIO_PORT: portSchema,
    MINIO_URL: z.string().url(),
  },
  client: {},
  experimental__runtimeEnv: {},
  skipValidation: !!process.env.SKIP_ENV_VALIDATION,
  emptyStringAsUndefined: true,
});
