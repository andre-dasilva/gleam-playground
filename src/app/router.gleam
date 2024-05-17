import wisp.{type Request, type Response}

import app/handlers/comment
import app/handlers/ping
import app/middleware

pub fn handle_request(req: Request) -> Response {
  use req <- middleware.setup(req)

  case wisp.path_segments(req) {
    [] -> comment.handler(req)
    ["ping"] -> ping.handler(req)

    _ -> wisp.not_found()
  }
}
