import gleam/dynamic
import gleam/json
import gleam/result

import app/errors

pub type Comment {
  Comment(name: String, email: String, body: String)
}

pub fn encode(comment: Comment) -> json.Json {
  json.object([
    #("Name", json.string(comment.name)),
    #("Email", json.string(comment.email)),
    #("Kommentar", json.string(comment.body)),
  ])
}

pub fn decoder_type() {
  dynamic.tuple3(dynamic.string, dynamic.string, dynamic.string)
}

pub fn decoder() {
  dynamic.decode3(
    Comment,
    dynamic.field("name", of: dynamic.string),
    dynamic.field("email", of: dynamic.string),
    dynamic.field("body", of: dynamic.string),
  )
}

pub fn decode_json(
  json_string: String,
  decoder: dynamic.Decoder(t),
) -> Result(t, errors.ApiError) {
  json.decode(from: json_string, using: decoder)
  |> result.map_error(errors.JsonDecodeError)
}
