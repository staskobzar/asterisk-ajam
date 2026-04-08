# Copilot Instructions

## Build & Test Commands

```bash
bundle install          # install dependencies
rake spec               # run all tests (default task)
rake spec_doc           # run tests with documentation formatter
rspec spec/asterisk/ajam/session_spec.rb   # run a single spec file
rspec spec/asterisk/ajam/response_spec.rb  # run a single spec file
rake rdoc               # generate RDoc documentation
```

## Publishing to RubyGems

```bash
# One-time: authenticate with your RubyGems account
gem signin
# Or manually fetch and store the API key:
# curl -u USERNAME https://rubygems.org/api/v1/api_key.yaml > ~/.gem/credentials && chmod 0600 ~/.gem/credentials

# Bump version in lib/asterisk/ajam/version.rb, then:
rake build    # builds pkg/asterisk-ajam-X.Y.Z.gem
rake release  # builds, tags vX.Y.Z in git, pushes tag, and publishes to rubygems.org
```

`rake release` requires a clean git working tree and that the tag doesn't already exist.

## Architecture

This is a Ruby gem (`asterisk-ajam`) that communicates with the Asterisk PBX [AMI](https://wiki.asterisk.org/wiki/display/AST/Asterisk+11+AMI+Actions) over HTTP(S) via [AJAM](https://wiki.asterisk.org/wiki/pages/viewpage.action?pageId=4817256).

**Entry point:** `Asterisk::AJAM.connect(options)` in `lib/asterisk/ajam.rb` — creates and logs in a `Session`, returning it.

**Two core classes:**

- `Asterisk::AJAM::Session` (`lib/asterisk/ajam/session.rb`) — manages the HTTP connection, login, session cookie, and dispatches actions. Uses `method_missing` to implement `action_NAME` dynamic methods that map to AMI action names.
- `Asterisk::AJAM::Response` (`lib/asterisk/ajam/response.rb`) — wraps `Net::HTTPResponse`, parses the AJAM XML body using `libxml-ruby`, and exposes:
  - `#list` — array of hashes for eventlist responses (e.g., SIP peers)
  - `#attribute` — hash of attributes for single-result responses
  - `#data` — string output for `command` responses (`opaque_data`)
  - `#session_id` — parsed from `Set-Cookie` header (`mansession_id`)

**Request flow:** `Session#send_action` → `http_send_action` → `Net::HTTP::Post` with form data → `Response.new`. Session cookies (`mansession_id`) are passed back on every subsequent request via `request_headers`.

**Custom exceptions** defined in `session.rb`: `InvalidURI`, `InvalidAMILogin`, `NotLoggedIn`. In `response.rb`: `InvalidHTTPBody`.

## Key Conventions

- **Dynamic action methods:** `action_NAME` calls are handled via `method_missing`. Any method matching `/^action_\w+$/` is dispatched to `send_action` with the suffix as the AMI action symbol (e.g., `action_sippeers` → `send_action(:sippeers, {})`).
- **SSL:** Enabled automatically when URI scheme is `https`. Certificate verification is intentionally disabled (`VERIFY_NONE`).
- **Specs use modern RSpec expectations** (`expect(...).to receive(...)`) rather than the older RSpec 2 `.stub(...)` / `.should_receive(...)` syntax.
- **Fixture helpers** for HTTP responses are defined as top-level methods in `spec/spec_helper.rb` (e.g., `get_body_sippeers`, `cmd_body_dialplan_reload`).
- **XML format:** AJAM responses are `<ajax-response>` documents; each `<generic>` element maps to one node. The first node is the status node (checked for `response='Success'` or `response='Follows'`); subsequent nodes form the event list.
- Runtime dependency: `libxml-ruby` gem (used in `Response`).
