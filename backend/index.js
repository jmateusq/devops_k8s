import express from "express";
import { MongoClient } from "mongodb";

const app = express();
const port = 3000;
const mongoUrl = "mongodb://mongodb:27017";
const client = new MongoClient(mongoUrl);

app.use(express.json());

app.post("/note", async (req, res) => {
  try {
    const { note } = req.body;
    if (!note) return res.status(400).json({ error: "Missing note" });

    const db = client.db("notesdb");
    const collection = db.collection("notes");

    const encoded = Buffer.from(note).toString("base64");
    await collection.insertOne({ note: encoded, created: new Date() });

    res.status(201).json({ status: "Note saved" });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Internal server error" });
  }
});

app.listen(port, async () => {
  try {
    await client.connect();
    console.log("Connected to MongoDB");
    console.log(`API listening on port ${port}`);
  } catch (err) {
    console.error("MongoDB connection error:", err);
  }
});
