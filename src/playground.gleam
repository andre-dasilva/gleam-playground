import app/router
import gleam/erlang/process
import mist
import wisp

import app/database

pub fn main() {
  wisp.configure_logger()

  let assert Ok(Nil) = database.create_tables()

  let secret_key_base = wisp.random_string(64)

  let assert Ok(_) =
    wisp.mist_handler(router.handle_request, secret_key_base)
    |> mist.new
    |> mist.port(9000)
    |> mist.start_http

  process.sleep_forever()
}
