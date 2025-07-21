import express from "express";
import { MongoClient } from "mongodb";

const app = express();
const port = 3000;
const mongoUrl = "mongodb://mongodb:27017";
const client = new MongoClient(mongoUrl);

function rot13(str) {
  return str.replace(/[a-zA-Z]/g, function (c) {
    return String.fromCharCode(
      (c <= "Z" ? 90 : 122) >= (c = c.charCodeAt(0) + 13) ? c : c - 26
    );
  });
}

app.use(express.json());

app.post("/note", async (req, res) => {
  try {
    const { note, method } = req.body;

    if (!note || !method) {
      return res.status(400).json({ error: "Faltando nota ou método" });
    }

    let encoded;

    switch (method) {
      case 'base64':
        encoded = Buffer.from(note).toString("base64");
        break;
      case 'rot13':
        encoded = rot13(note);
        break;
      case 'reverse':
        encoded = note.split('').reverse().join('');
        break;
      case 'urlencode':
        encoded = encodeURIComponent(note);
        break;
      default:
        return res.status(400).json({ error: "Método não suportado" });
    }

    const db = client.db("notesdb");
    const collection = db.collection("notes");

    await collection.insertOne({
      note: encoded,
      created: new Date()
    });

    res.status(201).json({ status: "Nota salva" });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Internal server error" });
  }
});

app.get("/notes", async (req, res) => {
  try {
    const db = client.db("notesdb");
    const collection = db.collection("notes");
    const notes = await collection.find({}).sort({ created: -1 }).toArray();
    res.status(200).json(notes);
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