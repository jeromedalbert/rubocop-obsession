# Rubocop Obsession

A [RuboCop](https://github.com/rubocop/rubocop) extension that mostly focuses on
higher-level concepts, like checking that code reads from
[top to bottom](lib/rubocop/cop/obsession/method_order.rb), or only unit
testing [public methods](lib/rubocop/cop/obsession/rspec/describe_public_method.rb).
There are some lower-level cops as well.

Use the provided cops as is, or as inspiration to build custom cops aligned
with your project's best practices.

## Installation

Install the gem:

```
gem install rubocop-obsession
```

Or add this line to your Gemfile:

```ruby
gem 'rubocop-obsession', require: false
```

and run `bundle install`.

## Usage

You need to tell Rubocop to load the Obsession extension. There are three ways
to do this:

### Rubocop configuration file

Put this into your `.rubocop.yml`.

```yaml
require: rubocop-obsession
```

Alternatively, use the following array notation when specifying multiple extensions.

```yaml
require:
  - rubocop-other-extension
  - rubocop-obsession
```

Now you can run `rubocop` and it will automatically load the Rubocop Obsession
cops together with the standard cops.

### Command line

```bash
rubocop --require rubocop-obsession
```

### Rake task

```ruby
RuboCop::RakeTask.new do |task|
  task.requires << 'rubocop-obsession'
end
```

## The cops

All cops are located under
[`lib/rubocop/cop/obsession`](lib/rubocop/cop/obsession), and contain examples
and documentation.

These cops are opinionated and can often feel like too much, that is why some
of them are disabled by default. They should not be treated as gospel, so do
not hesitate to enable or disable them as needed.

I wrote them to scratch an itch I had at one point or another. Tastes change
with time, and I personally do not use some of them any more, but others might
find them useful.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/jeromedalbert/rubocop-obsession. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/jeromedalbert/rubocop-obsession/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Rubocop::Obsession project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/jeromedalbert/rubocop-obsession/blob/main/CODE_OF_CONDUCT.md).
