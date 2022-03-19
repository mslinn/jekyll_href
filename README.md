`Jekyll_href`
[![Gem Version](https://badge.fury.io/rb/jekyll_href.svg)](https://badge.fury.io/rb/jekyll_href)
===========

`Jekyll_href` is a Jekyll plugin that provides a new Liquid tag: `href`.
The Liquid tag generates and `<a href>` HTML tag, by default containing `target="_blank"` and `rel=nofollow`.
To suppress the `nofollow` attribute, preface the link with the word `follow`.
To suppress the `target` attribute, preface the link with the word `notarget`.


### Syntax:
```
{% href [match | [follow] [notarget]] url text to display %}
```
Note that the url should not be enclosed in quotes.
Also please note that the square brackets denote optional parameters, and should not be typed.


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

```
{% href https://mslinn.com The Awesome %}
```

Expands to this:
```html
<a href='https://mslinn.com' target='_blank' rel='nofollow'>The Awesome</a>
```

Which renders as this: <a href='https://mslinn.com' target='_blank' rel='nofollow'>The Awesome</a>


```
{% href follow https://mslinn.com The Awesome %}
```

Expands to this:
```html
<a href='https://mslinn.com' target='_blank'>The Awesome</a>
```


```
 {% href notarget https://mslinn.com The Awesome %}
```

Expands to this:
```html
<a href='https://mslinn.com' rel='nofollow'>The Awesome</a>
```


```
{% href follow notarget https://mslinn.com The Awesome %}
```

Expands to this:
```html
<a href='https://mslinn.com'>The Awesome</a>
```

```
{% href match setting-up-django-oscar.html tutorial site %}
```

Expands to this:
```html
<a href='/blog/2021/02/11/setting-up-django-oscar.html'>tutorial site</a>
```


## Development

After checking out the repo, run `bin/setup` to install dependencies.

You can also run `bin/console` for an interactive prompt that will allow you to experiment.



### Build and Install Locally
To build and install this gem onto your local machine, run:
```shell
$ rake install:local
```

The following also does the same thing:
```shell
$ bundle exec rake install
```

Examine the newly built gem:
```shell
$ gem info Jekyll_href

*** LOCAL GEMS ***

Jekyll_href (1.0.0)
    Author: Mike Slinn
    Homepage:
    https://github.com/mslinn/Jekyll_href
    License: MIT
    Installed at: /home/mslinn/.gems

    Generates Jekyll logger with colored output.
```


### Build and Push to RubyGems
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

1. Fork the project
2. Create a descriptively named feature branch
3. Add your feature
4. Submit a pull request


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
