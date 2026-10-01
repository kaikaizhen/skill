# Brief — Reading List API

A small HTTP API for tracking books a person wants to read.

- `POST /books` adds a book with a `title` and an `author`. Returns the created
  book with an `id`.
- `GET /books` returns all books.
- `POST /books/:id/finish` marks a book as finished and records the date it was
  finished.
- A finished book stays in the list. It is not removed.
- The list must survive a server restart.

Single user. No authentication.
