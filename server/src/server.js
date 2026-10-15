import { app } from "./app.js";
import { env } from "./config/env.js";
import { pool } from "./db/pool.js";

async function startServer() {
  await pool.query("SELECT 1");

  const server = app.listen(env.PORT, () => {
    console.log(
      `MediBook API is running at http://localhost:${env.PORT}`
    );
  });

  const shutdown = (signal) => {
    console.log(`${signal} received. Shutting down...`);

    server.close(async () => {
      try {
        await pool.end();
        console.log("HTTP server and database pool closed.");
      } catch (error) {
        console.error("Error while closing the database pool:", error.message);
        process.exitCode = 1;
      }
    });
  };

  process.once("SIGINT", () => shutdown("SIGINT"));
  process.once("SIGTERM", () => shutdown("SIGTERM"));
}

startServer().catch(async (error) => {
  console.error("Failed to start MediBook API:", error.message);

  await pool.end();
  process.exitCode = 1;
});