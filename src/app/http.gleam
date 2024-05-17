import gleam/hackney
import gleam/http/request
import gleam/http/response.{type Response}
import gleam/result

import app/errors

pub fn send_request(url: String) -> Result(Response(String), errors.ApiError) {
  let assert Ok(request) = request.to(url)

  hackney.send(request)
  |> result.map_error(errors.HttpError)
}
