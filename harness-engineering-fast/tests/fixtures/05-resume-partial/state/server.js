// Reading List API — partial implementation (intentionally broken; see PROMPT.md)
const http = require('http');

const books = [];
let nextId = 1;

function readBody(req) {
  return new Promise((resolve) => {
    let data = '';
    req.on('data', (c) => { data += c; });
    req.on('end', () => resolve(data ? JSON.parse(data) : {}));
  });
}

const server = http.createServer(async (req, res) => {
  res.setHeader('Content-Type', 'application/json');

  if (req.method === 'POST' && req.url === '/books') {
    const body = await readBody(req);
    const book = { id: nextId++, title: body.title, author: body.author, finishedAt: null };
    books.push(book);
    res.statusCode = 201;
    res.end(JSON.stringify(book));
    return;
  }

  if (req.method === 'GET' && req.url === '/books') {
    res.end(JSON.stringify(books));
    return;
  }

  res.statusCode = 404;
  res.end(JSON.stringify({ error: 'not found' }));
};

server.listen(3000, () => console.log('listening on 3000'));
