const express = require('express');

const app = express();

app.get('/backend', (req, res) => {
  res.send({
    message: 'Hello World!',
    timestamp: new Date().toISOString()
  });
});

const port = process.env.PORT || 3000;
app.listen(port, () => {
  console.log(`Server is running on port ${port}`);
});

module.exports = app;

