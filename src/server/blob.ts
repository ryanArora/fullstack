import * as Minio from "minio";
import { env } from "~/env";

export const blob = new Minio.Client({
  endPoint: env.MINIO_HOST,
  port: env.MINIO_PORT,
  useSSL: env.MINIO_URL.startsWith("https://"),
  accessKey: env.MINIO_USER,
  secretKey: env.MINIO_PASSWORD,
});
