simple_secrets_ex [![Build Status](https://travis-ci.org/camshaft/simple_secrets_ex.png?branch=master)](https://travis-ci.org/camshaft/simple_secrets_ex)
==================

The elixir implementation of a simple, opinionated library for encrypting small packets of data securely. Designed for exchanging tokens among systems written in a variety of programming languages:

* [Node.js](https://github.com/timshadel/simple-secrets)
* [Ruby](https://github.com/timshadel/simple-secrets.rb)
* [Objective-C](https://github.com/timshadel/SimpleSecrets)
* [Java](https://github.com/timshadel/simple-secrets.java)
* [Erlang](https://github.com/camshaft/simple_secrets.erl)
* [Elixir](https://github.com/camshaft/simple_secrets_ex)

## Examples

### Basic

Send:

```elixir
# Try `head /dev/urandom | shasum -a 256` to make a decent 256-bit key
master_key = "64-char-hex"

sender = SimpleSecrets.init(master_key)
packet = SimpleSecrets.pack("this is a secret message", sender)

IO.inspect(packet)
# <<"bBDTl5NKdpvMfriRElbbOw0WEsENjbvv7mqK4"...>>
```

Receive:

```elixir
master_key = "shared-key-hex"
sender = SimpleSecrets.init(master_key)

# Read data from somewhere
packet = <<"bBDTl5NKdpvMfriRElbbOw0WEsENjbvv7mqK4"...>>
message = SimpleSecrets.unpack(packet, master_key)

IO.inspect(message)
# "this is a secret message"
```

## Can you add ...

No. Seriously. But we might replace what we have with what you suggest. We want exactly one, well-worn path. If you have improvements, we want them. If you want alternatives to choose from you should probably keep looking.

## License

MIT.
