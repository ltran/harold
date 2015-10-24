# harold

harold - crystal library for in-process pub-sub communication.

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  harold:
    github: waterlink/harold
```

## Usage

```crystal
require "harold"

Harold.start
```

### Publishing

```crystal
Harold.publish(topic :: String, "message")
```

NOTE: `topic` is expected to be a valid crystal identifier.

NOTE: ` :: {{Type}}` part after topic name is the type annotation for message.

### Subscribing

```crystal
spawn do
  Harold.subscribe(topic :: String).each do |message|
    puts "Someone said: #{message}"
  end
end
```

NOTE: `topic` is expected to be a valid crystal identifier.

NOTE: ` :: {{Type}}` part after topic name is the type annotation for message.

## Development

After cloning the project:

- Use `crystal deps` or `shards` to install development dependencies.
- Use `crystal spec` to run tests.
- Use TDD.

## Contributing

1. Fork it ( https://github.com/waterlink/harold/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [waterlink](https://github.com/waterlink) Oleksii Fedorov - creator, maintainer
