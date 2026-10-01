'use strict';

const fs = require('node:fs');
const path = require('node:path');

const DATA_FILE = path.join(__dirname, 'data.json');

function read() {
  if (!fs.existsSync(DATA_FILE)) return { notes: [] };
  return JSON.parse(fs.readFileSync(DATA_FILE, 'utf8'));
}

function write(data) {
  fs.writeFileSync(DATA_FILE, JSON.stringify(data, null, 2), 'utf8');
}

module.exports = { read, write };
