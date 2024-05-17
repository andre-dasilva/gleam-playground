import gleam/int
import gleam/io
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

fn fetch_one_form_api(url: String) -> Result(comment.Model, errors.ApiError) {
  use response <- result.try(http.send_request(url))
  use comment <- result.try(comment.decode_json(response.body))

  Ok(comment)
}

fn url() -> String {
  let random_number = int.random(10)

  base_url
  |> string.append("/")
  |> string.append(int.to_string(random_number))
}

fn fetch_all_from_database() {
  use conn <- database.connection()

  let sql = "select * from comments;"

  // TODO: fix this encoder stuff, also check if sqlight library
  let assert Ok(comments) =
    sqlight.query(sql, on: conn, with: [], expecting: comment.decoder())

  io.debug(
    comments
    |> list.map(fn(c) { comment.decode_any(c, comment.decoder()) }),
  )
}

pub fn handler(_req: wisp.Request) -> wisp.Response {
  fetch_all_from_database()

  let url = url()
  let comment = fetch_one_form_api(url)

  case comment {
    Ok(comment) -> {
      let json_comment = comment.encode(comment)
      wisp.json_response(json_comment, 200)
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
