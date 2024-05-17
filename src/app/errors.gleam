import gleam/hackney
import gleam/json
import sqlight

pub type ApiError {
  HttpError(hackney.Error)
  JsonDecodeError(json.DecodeError)
}

pub type DbError {
  DbError(sqlight.Error)
}
