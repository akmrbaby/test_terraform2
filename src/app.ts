import express from "express";

const app = express();
app.listen(3000, () => {
  console.log("Start on port 3000");
});

app.get("/test", (req, res) => {
  res.send("OK");
});
