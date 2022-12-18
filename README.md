`Jekyll_href`
[![Gem Version](https://badge.fury.io/rb/jekyll_href.svg)](https://badge.fury.io/rb/jekyll_href)
===========

`Jekyll_href` is a Jekyll plugin that provides a new Liquid tag: `href`.
It provides a convenient way to generate formatted and clickable URIs.
The Liquid tag generates an `a href` HTML tag, which by default contains `target="_blank"` and `rel=nofollow`.

If the url starts with `http`, or the `match` keyword is specified:
 - The url will open in a new tab or window.
 - The url will include `rel=nofollow` for SEO purposes.

CAUTION: if linked text contains a single or double quote you will see the error message: `Liquid Exception: Unmatched quote`. Instead, use &lsquo;, &rsquo;, &ldquo;, &rdquo;

In `_config.yml`, if a section called `plugin-vars` exists,
then its name/value pairs are available for substitution.
```yaml
  plugin-vars:
    django-github: 'https://github.com/django/django/blob/3.1.7'
    django-oscar-github: 'https://github.com/django-oscar/django-oscar/blob/3.0.2'
```


## Syntax 1 (requires `url` does not have embedded spaces):
```
{% href [match | [follow] [notarget]] url text to display %}
```
 1. The url must be a single token, without embedded spaces.
 2. The url need not be enclosed in quotes.
 3. The square brackets denote optional keyword parameters, and should not be typed.


## Syntax 2 (always works):
This syntax is recommended when the URL contains a colon (:).
```
{% href [match | [follow] [notarget]]
  url="http://link.com with space.html" some text %}

{% href [match | [follow] [notarget]]
  url='http://link.com with space.html' some text %}
```
  1. Each of the above examples contain an embedded newline, which is legal.
  2. The url must be enclosed by either single or double quotes.
  3. The square brackets denote optional keyword parameters, and should not be typed.


## Environment Variable Expansion
URLs can contain environment variable references.
For example, if `$domain`, `$uri` and `$USER` are environment variables:
```
{% href http://$domain.html some text %}

{% href url="$uri" some text %}

{% href https://mslinn.html <code>USER=$USER</code> %}
```

## Optional Parameters
### `follow`
To suppress the `nofollow` attribute, preface the link with the word `follow`.


### `notarget`
To suppress the `target` attribute, preface the link with the word `notarget`.


### `match`
`match` will attempt to match the url fragment (specified as a regex) to a URL in any collection.
If multiple documents have matching URL an error is thrown.
The `match` option looks through the pages collection for a URL with containing the provided substring.
`Match` implies `follow` and `notarget`.


## Examples
 1. Generates `nofollow` and `target` attributes:
    ```
    {% href https://mslinn.com The Awesome %}
    ```

 2. Does not generate `nofollow` or `target` attributes.
    ```
    {% href follow notarget https://mslinn.com The Awesome %}
    ```

 3. Does not generate `nofollow` attribute.
    ```
    {% href follow https://mslinn.com The Awesome %}
    ```

 4. Does not generate `target` attribute.
    ```
    {% href notarget https://mslinn.com The Awesome %}
    ```

 5. Matches page with URL containing abc.
    ```
    {% href match abc The Awesome %}
    ```

 6. Matches page with URL containing abc.
    ```
    {% href match abc.html#tag The Awesome %}
    ```

 7. Substitute name/value pair for the `django-github` variable defined above:
    ```
    {% href {{django-github}}/django/core/management/__init__.py#L398-L401
      <code>django.core.management.execute_from_command_line</code> %}
    ```
    Substitutions are only made to the URL, not to the linked text.


## Additional Information
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


## Generated HTML

### Without Keywords
```
{% href https://mslinn.com The Awesome %}
```

Expands to this:
```html
<a href='https://mslinn.com' target='_blank' rel='nofollow'>The Awesome</a>
```

Which renders as this: <a href='https://mslinn.com' target='_blank' rel='nofollow'>The Awesome</a>

### With `follow`
```
{% href follow https://mslinn.com The Awesome %}
```

Expands to this:
```html
<a href='https://mslinn.com' target='_blank'>The Awesome</a>
```


### With `notarget`
```
 {% href notarget https://mslinn.com The Awesome %}
```

Expands to this:
```html
<a href='https://mslinn.com' rel='nofollow'>The Awesome</a>
```


### With `follow notarget`
```
{% href follow notarget https://mslinn.com The Awesome %}
```

Expands to this:
```html
<a href='https://mslinn.com'>The Awesome</a>
```

### With `match`
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

## Test
A test web site is provided in the `demo` directory.
 1. Set breakpoints.

 2. Initiate a debug session from the command line:
    ```shell
    $ bin/attach demo
    ```

  3. Once the `Fast Debugger` signon appears, launch the test configuration called `Attach rdebug-ide`.

  4. View the generated website at [`http://localhost:4444`](http://localhost:4444)


## Release
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
