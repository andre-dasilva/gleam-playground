import gleam/result
import sqlight

import app/errors

const database_url = "file:playground.sqlite3"

pub fn connection(f: fn(sqlight.Connection) -> a) -> a {
  sqlight.with_connection(database_url, f)
}

pub fn create_tables() -> Result(Nil, errors.DbError) {
  use conn <- connection()

  let sql =
    "
  create table if not exists comments (name text, email text, body text);

  insert into comments (name, email, body) values
  ('Andre da Silva', 'a@a.com', 'this is a test'),
  ('Test Example', 'test@example.com', 'another example');
  "
  sqlight.exec(sql, conn)
  |> result.map_error(errors.DbError)
}
