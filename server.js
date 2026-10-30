const http = require('http');
const fs = require('fs');
const path = require('path');
const { exec } = require('child_process');

const PORT = 3000;
const filePath = path.join(__dirname, 'public', 'index.html');

const server = http.createServer((req, res) => {
  fs.readFile(filePath, (err, data) => {
    if (err) {
      res.writeHead(500, { 'Content-Type': 'text/plain' });
      res.end('Error loading application');
      return;
    }
    res.writeHead(200, { 'Content-Type': 'text/html; charset=utf-8' });
    res.end(data);
  });
});

server.listen(PORT, () => {
  console.log(`\n=============================================================`);
  console.log(`⚽ Sports Live Stream App is running!`);
  console.log(`👉 Local Computer:  http://localhost:${PORT}`);
  console.log(`📱 On Your Phone:   http://192.168.100.89:${PORT}`);
  console.log(`=============================================================\n`);

  if (process.platform === 'win32') {
    exec(`start http://localhost:${PORT}`);
  }
});
