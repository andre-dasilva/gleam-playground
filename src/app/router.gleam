import wisp.{type Request, type Response}
import gleam/string_builder
import gleam/json
import gleam/hackney
import gleam/http/request
import gleam/dynamic
import gleam/io

pub type Comment {
  Comment(name: String, email: String, body: String)
}

fn comment_encode(comment: Comment) -> string_builder.StringBuilder {
  json.object([
    #("Name", json.string(comment.name)),
    #("Email", json.string(comment.email)),
    #("Kommentar", json.string(comment.body)),
  ])
  |> json.to_string_builder
}

fn decode_todo(json_string: String) -> Result(Comment, json.DecodeError) {
  let comment_decoder =
    dynamic.decode3(
      Comment,
      dynamic.field("name", of: dynamic.string),
      dynamic.field("email", of: dynamic.string),
      dynamic.field("body", of: dynamic.string),
    )

  json.decode(from: json_string, using: comment_decoder)
}

const url: String = "https://jsonplaceholder.typicode.com/comments/1"

pub fn handle_request(_req: Request) -> Response {
  let assert Ok(request) = request.to(url)

  case hackney.send(request) {
    Ok(response) -> {
      io.debug(response)

      case decode_todo(response.body) {
        Ok(comment) -> {
          let comment = comment_encode(comment)
          wisp.json_response(comment, 200)
        }
        Error(e) -> {
          io.debug(e)
          wisp.unprocessable_entity()
        }
      }
    }
    Error(e) -> {
      io.debug(e)
      wisp.unprocessable_entity()
    }
  }
}
