import gleam/int
import gleam/io
import gleam/json
import gleam/list
import gleam/result
import gleam/string
import sqlight
import wisp

import app/database
import app/errors
import app/http
import app/models/comment

const base_url: String = "https://jsonplaceholder.typicode.com/comments"

fn fetch_one_from_api(url: String) -> Result(comment.Comment, errors.ApiError) {
  use response <- result.try(http.send_request(url))
  use comment <- result.try(comment.decode_json(
    response.body,
    comment.decoder(),
  ))

  Ok(comment)
}

fn url() -> String {
  let random_number = int.random(10)

  base_url
  |> string.append("/")
  |> string.append(int.to_string(random_number))
}

fn fetch_all_from_database() -> List(comment.Comment) {
  use conn <- database.connection()

  let sql = "select * from comments;"

  let assert Ok(comments) =
    sqlight.query(sql, on: conn, with: [], expecting: comment.decoder_type())

  comments
  |> list.map(fn(comment) {
    let #(name, email, body) = comment
    comment.Comment(name, email, body)
  })
}

pub fn handler(_req: wisp.Request) -> wisp.Response {
  let url = url()
  let single_comment = fetch_one_from_api(url)

  case single_comment {
    Ok(_single_comment) -> {
      // let json_comment = comment.encode(single_comment)

      let comments = fetch_all_from_database()
      let json_comments = json.array(comments, of: comment.encode)

      wisp.json_response(json.to_string_builder(json_comments), 200)
    }
    Error(err) -> {
      io.debug(err)
      case err {
        errors.HttpError(_) -> wisp.internal_server_error()
        errors.JsonDecodeError(_) -> wisp.internal_server_error()
      }
    }
  }
}
