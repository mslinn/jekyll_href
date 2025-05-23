# `Jekyll_href` [![Gem Version](https://badge.fury.io/rb/jekyll_href.svg)](https://badge.fury.io/rb/jekyll_href)

`Jekyll_href` is a flexible Jekyll plugin that is designed to minimize the work of creating and maintaining a Jekyll website.


## Features

1. It provides a new Liquid tag: `href` with default options such as generating `target="_blank"` and `rel="nofollow"`
   that can be overridden.
2. The `match` keyword causes the title of the linked Jekyll page to be used as the link text;
  an error is displayed if the page does not exist.
3. Provides a convenient syntax for generating links with monospaced text that display the URL being linked to.
4. Can generate soft hyphens (&amp;shy; and &lt;wbr>).
5. If the url starts with `http`, or the `match` keyword is specified:

    a. The url will open in a new tab or window.

    b. The url will include `rel="nofollow"` for SEO purposes.

6. URLs can be composed from environment variable references.
7. The href tags in a page can be summarized by the `href_summary` tag.

CAUTION: if linked text contains a single or double quote,
you will see the error message: `Liquid Exception: Unmatched quote`.
Instead, use one of the following:

 <ul style="column-count: 3; list-style-type: none; padding: 0; margin: 0 2em;">
    <li><code>&amp;apos;</code> (&apos;)</li>
    <li><code>&amp;quot;</code> (&quot;)</li>
    <li><code>&amp;lsquo;</code> (&lsquo;)</li>
    <li><code>&amp;rsquo;</code> (&rsquo;)</li>
    <li><code>&amp;ldquo;</code> (&ldquo;)</li>
    <li><code>&amp;rdquo;</code> (&rdquo;)</li>
  </ul>


## Installation

Add the following to your Jekyll website's `Gemfile`, within the `jekyll_plugins` group:

```text
group :jekyll_plugins do
  gem 'jekyll_href'
end
```

And then execute:

```shell
$ bundle
```


## Configuration

In `_config.yml`, if a section called `plugin-vars` exists,
then its name/value pairs are available for substitution.
When referenced from a web page, the names must be enclosed within {{double curly braces}} in order for substitution to occur.

```yaml
plugin-vars:
  django-github: 'https://github.com/django/django/blob/3.1.7'
  django-oscar-github: 'https://github.com/django-oscar/django-oscar/blob/3.0.2'
```

Use it as shown below. The lines have been folded for legibility; whitespace formatting is optional:

```text
{% href
  label="django.core.management.execute_from_command_line"
  url="{{django-github}}/django/core/management/__init__.py#L398-L401"
%}
```

The following sections and settings can be set:
`Pry_on_href_error` has priority over `die_on_href_error`.

```yaml
href:
  die_on_href_error: false # Default value is false
  die_on_nomatch: true     # Default value is false
  pry_on_href_error: true  # Default value is false
href_summary:
  die_on_href_error: false # Default value is false
  pry_on_href_error: true  # Default value is false
```


## Common Usages

1. For local links (links within a Jekyll website), the best way to make them is with an incantation like this:
   ```text
   {% href match url='trust_winning.html' %}{% endraw %}
   ```

   The above uses the page title of <code>trust_winning.html</code> as the link text;
   an error is displayed if the page does not exist.
   It renders like this: {% href match url='trust_winning.html' %}.

2. To display external links with a monospaced font, and use the URL as the link text, use an incantation like this:
   ```text
   {% href url='mslinn.com' %}{% endraw %}
   ```
   The above renders as: <a href="https://mslinn.com"><code>mslinn.com</code></a>.


## Suppprted Syntaxes

Square brackets in the [BNF notation](https://en.wikipedia.org/wiki/Backus%E2%80%93Naur_form)
below denote optional keyword parameters, and are not meant to be typed.
Additional usage examples follow.


## Syntax 1: Mmost verbose

This is the most verbose syntax, but it provides most reliable results.
If `match` is specified, the title from the matching page is used as the link
text unless overridden by the value of the `label` parameter.

Options are:

```html
{% href [match | [follow] [blank|notarget] [summary_exclude]]
  label="text to display"
  url="local_page.html"
%}
```

1. The url can be #relative, a page in the Jekyll website, or prefaced with a protocol, such as `https:`
2. Embedded newlines within the label are legal.
3. The `url` and `label` parameter values can be enclosed in single or double quotes.
4. If `match` is provided, and `label` is not provided, then the title of the matched page is used as the label.


## Syntax 2: Easiest to Type

This syntax uses positional parameters instead of labeled parameters.
This syntax can only be used if the url does not contain embedded spaces.
You can write the tag on one line, or several lines as shown.

```html
{% href [match | [follow] [blank|notarget] [page_title] [summary_exclude]]
  url
  text to display
%}
```

1. Embedded newlines within the tag are legal.
2. The url need not be enclosed in quotes.
3. The `match` keyword causes the title of the linked page to be used as the link text unless the `label` option is provided.
4. If `url` is not provided, then the text to display is assumed to be a URI,
   as described in syntax 4, and is formatted into a clickable link.


## Syntax 3: `url` Option

This syntax is recommended when the URL contains a problematic character,
such as a colon (`:`) or space, and you are too lazy to type out label=.
Contrast with the explicit `label` parameter syntax, described next.

```html
{% href [match | [follow] [blank|notarget]] [page_title] [summary_exclude]
  url="http://link.com with space.html"
  some text
%}
```

1. Each of the above examples contain an embedded newline, which is legal.
2. The url must be enclosed by either single or double quotes.


## Syntax 4 Explicit `label` Option

This syntax is recommended when the linked text contains an option keyword, such as `summary` or `label`.
It can be combined with an explicit url, described above.

```html
{% href [match | [follow] [blank|notarget] [page_title] [summary_exclude]] [shy|wbr]
  www.domain.com
%}
```

1. Embedded newlines within the tag are legal.

2. The URI provided, for example `www.domain.com`,
   is used to form the URL by prepending `https://`,
   in this case the result would be `https://www.domain.com`.
   The displayed URI is enclosed in `<code></code>`,
   so the resulting text is `<code>www.domain.com</code>`.


## Environment Variable Expansion

URLs can contain environment variable references.
For example, if `$domain`, `$uri` and `$USER` are environment variables:

```html
Using keyword options:
{% href http://$domain.html some text %}

Using the url option and positional link text:
{% href url="$uri" some text %}

Using positional parameters for the URL and the link text:
{% href https://mslinn.html <code>USER=$USER</code> %}
```


## Optional Parameters

### `blank`

The `target='_blank'` attribute is not normally generated for relative links.
To enforce the generation of this attribute, preface the link with the word `blank`.
The `blank` and `notarget` parameters are mutually exclusive.
If both are specified, `blank` prevails.


### `class`

This option allows CSS classes to be added to the HTML generated by the `href` tag.
It has no effect on the `href_summary` tag output.

For example:

```html
{% href class='bg_yellow' https://mslinn.com click here %}
```

Expands to:

```html
<a href="https://mslinn.com" class="bg_yellow" rel="nofollow" target="_blank">click here</a>
```


### `follow`

To suppress the `nofollow` attribute, preface the link with the word `follow`.


### `label='whatever you want'`

If the text to be linked contains an optional keyword argument,
for example `summary`, that word will be removed from the displayed link text,
unless the link text is provided via the `label` option.
Both of the following produce the same output:

```html
{% href https://mslinn.com label="This is a summary" %}
{% href label="This is a summary" https://mslinn.com %}
```


### `match`

`match` will attempt to match the url fragment (specified as a regex) to a URL in any collection.
If multiple documents have matching URLs an error is thrown.
The `match` option looks through the pages collection for a URL with containing the provided substring.
`Match` implies `follow` and `notarget`.

```text
{% href match url="page6.html" %}
```


### `notarget`

To suppress the `target` attribute, preface the link with the word `notarget`.
The `blank` and `notarget` parameters are mutually exclusive.
If both are specified, `blank` prevails.


### `page_title`

For local pages, use the linked page title as the link text.
This value overrides any provided link text.


### `shy`

The `shy` keyword option is only applicable for syntax 3 (implicit URL).
This option causes displayed urls to have an
[`&amp;shy;`](https://developer.mozilla.org/en-US/docs/Web/CSS/hyphens)
inserted after each slash (/).
If both `shy` and `wbr` are specified, `wbr` prevails.

For example:

```html
{% href shy mslinn.com/path/to/page.html %}
```

Expands to:

```html
<a href="https://mslinn.com/path/to/page.html" rel="nofollow" target="_blank">mslinn.com/&shy;path/&shy;to/&shy;page.html</a>
```


### `style`

This option allows CSS styling to be added to the HTML generated by the `href` tag.
It has no effect on the `href_summary` tag output.

For example:

```html
{% href style='color: red; font-weight: bold;' https://mslinn.com click here %}
```

Expands to:

```html
<a href="https://mslinn.com" rel="nofollow" style="color: ref; font-weight: bold" target="_blank">click here</a>
```


### `summary`

The `summary` name/value option provides an override for the linked text in the **References** section
generated by the `{% href_summary %}` tag.
If the value is the empty string, or no value is provided, the `href` tag is not included in the page summary.


### `summary_exclude`

The `summary_exclude` keyword option prevents this `href` tag from appearing in the summary
 produced by the [`href_summary` tag](#href_summary).
You probably want all of your menu items (whose links are generated by the `href` tag) to have this keyword option.

`mailto:` links are always excluded, so there is no need to use this keyword option for those types of links.


### `wbr`

The `wbr` keyword option is only applicable for syntax 3 (implicit URL).
It add [line break opportunites](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/wbr).
This option causes displayed urls to have an `&lt;wbr&gt;` inserted after each slash (/).
If both `shy` and `wbr` are specified, `wbr` prevails.

For example:

```html
{% href wbr mslinn.com/path/to/page.html %}
```

Expands to:

```html
<a href="https://mslinn.com/path/to/page.html" rel="nofollow" target="_blank">mslinn.com/<wbr>path/<wbr>to/<wbr>page.html</a>
```


## Usage Examples

1. Generates `nofollow` and `target` attributes:

   ```html
   {% href https://mslinn.com The Awesome %}
   ```

2. Does not generate `nofollow` or `target` attributes.

   ```html
   {% href follow notarget https://mslinn.com The Awesome %}
   ```

3. Does not generate `nofollow` attribute.

   ```html
   {% href follow https://mslinn.com The Awesome %}
   ```

4. Does not generate `target` attribute.

   ```html
   {% href notarget https://mslinn.com The Awesome %}
   ```

5. Matches page with URL containing abc.

   ```html
   {% href match abc The Awesome %}
   ```

6. Matches page with URL containing abc.

   ```html
   {% href match abc.html#tag The Awesome %}
   ```

7. Substitute name/value pair for the `django-github` variable defined above:

   ```html
   {% href {{django-github}}/django/core/management/__init__.py#L398-L401
     <code>django.core.management.execute_from_command_line</code> %}
   ```

   Substitutions are only made to the URL, not to the linked text.

8. Dollar signs

   If the URL has a dollar sign in it, jekyll_href will attempt to replace an environment variable with its value.
   That will likely fail silently. To work around the problem, replace dollar signs in URLs with &amp;dollar;.

   For example, given this URL:
   https://ammonite.io/#import$ivy
   rewrite as:
   https://ammonite.io/#import&amp;dollar;ivy.

   Here is a complete invocation:

   ```text
   {% href url="https://ammonite.io/#import&dollar;ivy"
           label="<code>import &dollar;ivy</code>" %}
   ```

## References Generation

The `href` usages on each page can be summarized at the bottom of the pages in a **References** section.
Links are presented in the summary in the order they appear in the page.

The summary is produced by the `href_summary` tag.
Usage is:

```html
{% href_summary [options] %}
```

`Href` tag options are used to generate the summary links,
just as they were in the text above the **References** summary section.
The only exception is the `summary` option, which overrides the linked text.

If more than one `href` tag specifies a URL,
the first one that appears in the page sets the value of the linked text.

If a URL appears in more than one `href` with different `follow` values, a warning is logged.


### Included `href` Tags

The following `href` tags are included in the summary:

- Those with links that start with `http` are always included.
- Those with [relative links](https://www.w3.org/TR/WD-html40-970917/htmlweb.html#h-5.1.2),
  and have the `include_local` keyword option.

### Excluded `href` Tags

The following `href` tags are excluded from the summary:

- Those with links that start with `mailto:`.
- Those having the `summary_exclude` keyword option.


### Example

Given these `href` and `href_summary` usages in a web page:

```html
{% href https://rubygems.org RubyGems.org %}
{% href summary="Mothership" https://jekyllrb.com/ Jekyll %}
{% href summary="Mike Slinn" mslinn.com %}
{% href https://mslinn.com Mike Slinn %}
{% href summary="Front page of this website" / Front page %}

{% href_summary attribution include_local %}
```

The generated HTML looks like the following:

```html
<h2 id="reference">References</h2>
<ol>
  <li><a href='https://rubygems.org' rel='nofollow' target='_blank'>RubyGems.org</a></li>
  <li><a href='https://jekyllrb.com/' rel='nofollow' target='_blank'>Mothership</a></li>
  <li><a href='https://mslinn.com/' rel='nofollow' target='_blank'><code>mslinn.com</code></a></li>
</ol>

<h2 id="local_reference">Local References</h2>
<ol>
  <li><a href='/'>Front page of this website</a></li>
</ol>

<div id="jps_attribute_735866" class="jps_attribute">
  <div>
    <a href="https://www.mslinn.com/jekyll/3000-jekyll-plugins.html#href" target="_blank" rel="nofollow">
      Generated by the jekyll_href v1.2.2 Jekyll plugin, written by Mike Slinn 2023-04-13.
    </a>
  </div>
</div>
```

You can read about the `attribution` option [here](https://www.mslinn.com/jekyll/10200-jekyll-plugin-support.html#attribution).


## Additional Information

More information is available on my website about
[my Jekyll plugins](https://www.mslinn.com/blog/2020/10/03/jekyll-plugins.html).


## Generated HTML

### Without Keywords

```html
{% href https://mslinn.com The Awesome %}
```

Expands to this:

```html
<a href='https://mslinn.com' target='_blank' rel='nofollow'>The Awesome</a>
```

Which renders as this: <a href='https://mslinn.com' target='_blank' rel='nofollow'>The Awesome</a>

### With `follow`

```html
{% href follow https://mslinn.com The Awesome %}
```

Expands to this:

```html
<a href='https://mslinn.com' target='_blank'>The Awesome</a>
```


### With `notarget`

```html
 {% href notarget https://mslinn.com The Awesome %}
```

Expands to this:

```html
<a href='https://mslinn.com' rel='nofollow'>The Awesome</a>
```


### With `follow notarget`

```html
{% href follow notarget https://mslinn.com The Awesome %}
```

Expands to this:

```html
<a href='https://mslinn.com'>The Awesome</a>
```

### With `match`

Looks for a post with a matching URL.

```html
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

After checking out the repo, run `bin/setup` to install dependencies.
You can also run `bin/console` for an interactive prompt that will allow you to experiment.

Install development dependencies like this:

```shell
$ BUNDLE_WITH="development" bundle
```

To install this gem onto your local machine, run:

```shell
$ bundle exec rake install
```

## Test

A test website is provided in the `demo` directory.

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
