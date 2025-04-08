import * as Minio from "minio";
import { env } from "~/env";

export const blob = new Minio.Client({
  endPoint: env.MINIO_ENDPOINT,
  useSSL: env.MINIO_ENDPOINT.startsWith("https://"),
  accessKey: env.MINIO_USER,
  secretKey: env.MINIO_PASSWORD,
});
