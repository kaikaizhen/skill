'use strict';

const store = require('./store');

function createNote(ownerId, title, body) {
  const data = store.read();
  const note = {
    id: String(Date.now()) + String(data.notes.length),
    ownerId,
    title,
    body,
  };
  data.notes.push(note);
  store.write(data);
  return note;
}

function listNotes(ownerId) {
  return store.read().notes.filter((n) => n.ownerId === ownerId);
}

function getNote(ownerId, id) {
  return listNotes(ownerId).find((n) => n.id === id) || null;
}

function deleteNote(ownerId, id) {
  const data = store.read();
  const before = data.notes.length;
  data.notes = data.notes.filter((n) => !(n.id === id && n.ownerId === ownerId));
  store.write(data);
  return data.notes.length < before;
}

module.exports = { createNote, listNotes, getNote, deleteNote };
