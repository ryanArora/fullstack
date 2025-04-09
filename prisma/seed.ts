import { blob } from "~/server/blob";
import { db } from "~/server/db";

async function clearDatabase() {
  const tables = await db.$queryRaw<{ table_name: string }[]>`
   SELECT table_name
   FROM information_schema.tables
   WHERE table_schema = 'public' AND table_type = 'BASE TABLE'
 `;

  console.log("Clearning tables:", tables);

  for (const { table_name } of tables) {
    await db.$executeRawUnsafe(
      `TRUNCATE TABLE "${table_name}" RESTART IDENTITY CASCADE`,
    );
    console.log(`Cleared table: ${table_name}`);
  }

  console.log("Database cleared");
}

async function clearBlob() {
  const buckets = await blob.listBuckets();
  console.log("Clearing buckets:", buckets);

  for (const bucket of buckets) {
    const objects = blob.listObjects(bucket.name);

    for await (const object of objects) {
      const obj = object as unknown;
      if (
        typeof obj !== "object" ||
        !obj ||
        !("name" in obj) ||
        typeof obj.name !== "string"
      )
        continue;

      console.log(`Removing object ${obj.name} from bucket ${bucket.name}`);
      await blob.removeObject(bucket.name, obj.name);
    }

    console.log(`Removing bucket ${bucket.name}`);
    await blob.removeBucket(bucket.name);
  }

  console.log("Blob cleared");
}

async function main() {
  await clearDatabase();
  await clearBlob();
}

main()
  .catch((e) => {
    console.error("Error seeding database:", e);
    process.exit(1);
  })
  .finally(() => {
    void db.$disconnect();
  });
