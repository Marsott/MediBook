import "dotenv/config";
import { z } from "zod";

const envSchema = z.object({
  NODE_ENV: z
    .enum(["development", "test", "production"])
    .default("development"),

  PORT: z.coerce.number().int().min(1).max(65535).default(3000),

  DB_HOST: z.string().trim().min(1),
  DB_PORT: z.coerce.number().int().min(1).max(65535).default(5432),
  DB_NAME: z.string().trim().min(1),
  DB_USER: z.string().trim().min(1),
  DB_PASSWORD: z.string().min(1),

  JWT_SECRET: z.string().min(64),
  JWT_EXPIRES_IN: z
    .string()
    .regex(/^\d+(s|m|h|d)$/)
    .default("1h")
});

const parsedEnv = envSchema.safeParse(process.env);

if (!parsedEnv.success) {
  const errorMessages = parsedEnv.error.issues.map(
    (issue) => `${issue.path.join(".")}: ${issue.message}`
  );

  throw new Error(
    `Invalid environment variables:\n${errorMessages.join("\n")}`
  );
}

export const env = parsedEnv.data;