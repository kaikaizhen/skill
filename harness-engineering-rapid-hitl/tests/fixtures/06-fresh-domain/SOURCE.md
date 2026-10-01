# Requirement — Tide Table Lookup

A command-line tool for a small harbour.

- Input: a station name and a date.
- Output: the high and low tide times for that date at that station, one per
  line, as `HIGH 06:14` / `LOW 12:31`.
- Station data comes from a local CSV file supplied at startup.
- Unknown station ⇒ exit code 2 with `unknown station` on stderr.
- No date given ⇒ use today.
- The tool stores nothing between runs.
