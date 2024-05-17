import gleam/dynamic
import gleam/json
import gleam/result
import gleam/string_builder

import app/errors

pub type Model {
  Model(name: String, email: String, body: String)
}

pub fn encode(comment: Model) -> string_builder.StringBuilder {
  json.object([
    #("Name", json.string(comment.name)),
    #("Email", json.string(comment.email)),
    #("Kommentar", json.string(comment.body)),
  ])
  |> json.to_string_builder
}

pub fn decoder_type() {
  dynamic.tuple3(dynamic.string, dynamic.string, dynamic.string)
}

pub fn decoder() {
  dynamic.decode3(
    Model,
    dynamic.field("name", of: dynamic.string),
    dynamic.field("email", of: dynamic.string),
    dynamic.field("body", of: dynamic.string),
  )
}

pub fn decode_any(a, using decoder: dynamic.Decoder(t)) {
  let value = dynamic.from(a)
  decoder(value)
}

pub fn decode_json(json_string: String) -> Result(Model, errors.ApiError) {
  let comment_decoder = decoder()

  json.decode(from: json_string, using: comment_decoder)
  |> result.map_error(errors.JsonDecodeError)
}
