import express from "express";

export const app = express();

app.disable("x-powered-by");

app.use(express.json({ limit: "10kb" }));

app.get("/api/health", (_request, response) => {
  response.status(200).json({
    status: "ok",
    message: "MediBook API is running"
  });
});

app.use((_request, response) => {
  response.status(404).json({
    error: "Route not found"
  });
});