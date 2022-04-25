`Jekyll_href`
[![Gem Version](https://badge.fury.io/rb/jekyll_href.svg)](https://badge.fury.io/rb/jekyll_href)
===========

`Jekyll_href` is a Jekyll plugin that provides a new Liquid tag: `href`.
The Liquid tag generates and `<a href>` HTML tag, by default containing `target="_blank"` and `rel=nofollow`.
To suppress the `nofollow` attribute, preface the link with the word `follow`.
To suppress the `target` attribute, preface the link with the word `notarget`.
Also provides a convenient way to generate formatted and clickable URIs.


### Syntax:
```
{% href [match | [follow] [notarget]] [url] text to display %}
```
Note that the url should not be enclosed in quotes.
Also please note that the square brackets denote optional parameters, and should not be typed.

`match` will attempt to match the url fragment (specified as a regex) to a URL in any collection.
If multiple documents have matching URL an error is thrown.


### Additional Information
More information is available on my web site about [my Jekyll plugins](https://www.mslinn.com/blog/2020/10/03/jekyll-plugins.html).


## Installation

Add this line to your Jekyll website's `Gemfile`, within the `jekyll_plugins` group:

```ruby
group :jekyll_plugins do
  gem 'jekyll_href'
end
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install jekyll_href

## Usage

### Defaults
```
{% href https://mslinn.com The Awesome %}
```

Expands to this:
```html
<a href='https://mslinn.com' target='_blank' rel='nofollow'>The Awesome</a>
```

Which renders as this: <a href='https://mslinn.com' target='_blank' rel='nofollow'>The Awesome</a>

### `follow`
```
{% href follow https://mslinn.com The Awesome %}
```

Expands to this:
```html
<a href='https://mslinn.com' target='_blank'>The Awesome</a>
```


### `notarget`
```
 {% href notarget https://mslinn.com The Awesome %}
```

Expands to this:
```html
<a href='https://mslinn.com' rel='nofollow'>The Awesome</a>
```


### `follow notarget`
```
{% href follow notarget https://mslinn.com The Awesome %}
```

Expands to this:
```html
<a href='https://mslinn.com'>The Awesome</a>
```

### `match`
Looks for a post with a matching URL.
```
{% href match setting-up-django-oscar.html tutorial site %}
```

Might expand to this:
```html
<a href='/blog/2021/02/11/setting-up-django-oscar.html'>tutorial site</a>
```

### URI
```html
{% href mslinn.com %}
```
Expands to this:
```html
<a href='https://mslinn.com' target='_blank' rel='nofollow'><code>mslinn.com</code></a>
```
Which renders as: [`mslinn.com`](https://mslinn.com)

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

Install development dependencies like this:
```
$ BUNDLE_WITH="development" bundle install
```

To install this gem onto your local machine, run:
```shell
$ bundle exec rake install
```

To release a new version,
  1. Update the version number in `version.rb`.
  2. Commit all changes to git; if you don't the next step might fail with an unexplainable error message.
  3. Run the following:
     ```shell
     $ bundle exec rake release
     ```
     The above creates a git tag for the version, commits the created tag,
     and pushes the new `.gem` file to [RubyGems.org](https://rubygems.org).


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/mslinn/jekyll_href.


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
