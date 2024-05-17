import wisp

import gleam/json

pub fn handler(_req: wisp.Request) -> wisp.Response {
  let json = [#("ping", json.string("We are running... Time to relax :)"))]

  json.object(json)
  |> json.to_string_builder
  |> wisp.json_response(200)
}
