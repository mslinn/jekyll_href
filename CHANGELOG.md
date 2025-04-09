# Change Log

## 3.0.1 / 2025-04-09

* Embedded spaces in URLs are translated to `%20`.


## 3.0.0 / 2025-03-06

* Numbered as v3.0.0 to match the `jekyll_plugin_support` version number.
* Now requires [Jekyll 4.4.1](https://jekyllrb.com/news/2025/01/29/jekyll-4-4-1-released/) or later,
  and Ruby 3.2.0 or later


## 1.3.0 / 2025-02-07

* The `match` option now searches all files, not just pages in collections.
* A binary search is now used.
* Launch configurations are now provided for `production` and `development` modes of the demo website.
* Renamed `HRef_error` to `HrefError`.


## 1.2.13 / 2024-12-23

* Fixed reference to undefined `url_matches`.
* References that point to draft pages are rendered differently in production mode,
  and an info-level log message is generated


## 1.2.12 / 2024-08-17

* Enhanced `match` so that if no label parameter is provided, the title of the matched web page is used.
* Now dependent on jekyll_plugin_support v1.0.2+ for better error handling.


## 1.2.11 / 2024-07-27

* Fixed an unqualified reference to `JekyllPluginHelper`.
* Shortened the very long stack dump for an error condition.


## 1.2.10 / 2024-07-23

* Make compatible with `jekyll_plugin_support` 1.0.0


## 1.2.9 / 2024-07-17

* Fixed missing ` target="_blank"` for links without labels, when `blank` was specified.


## 1.2.8 / 2023-12-31

* Fixed missing ` rel="nofollow"` for links without labels.


## 1.2.7 / 2023-12-09

* Implements the `page_title` option.
* Renamed the `nomatch` key in `_config.yml` to `die_on_nomatch`.
* Defines `@die_on_href_error` if the `die_on_href_error` key is present in `_config.yml`.
* Defines `@pry_on_href_error` if the `pry_on_href_error` key is present in `_config.yml`.
* Now uses the `StandardError` handler introduced in `jekyll_plugin_support` v0.8.0.


## 1.2.6 / 2023-06-18

* No longer blows up on error.


## 1.2.5 / 2023-05-26

* Added `style` and `class` options.


## 1.2.4 / 2023-05-18

* When only a URI is provided, the plugin now generates the `http` scheme for IP4 & IP6 loopback addresses like
  `localhost`, and `127.0.0.0`, as well as private IP4 addresses like 192.168.0.0 and 172.16.0.0;
  otherwise it generates the `https` scheme.


## 1.2.3 / 2023-05-16

* Added `label` option.


## 1.2.2 / 2023-03-25

* Added **References** capability:
  * Added `summary_exclude` keyword option to `href` tag.
  * Added `href_summary` tag.
* If a URL appears in more than one `href` with different `follow` values a warning is logged.


## 1.2.1 / 2023-03-21

* Added `shy` and `wbr` options.


## 1.2.0 / 2023-02-16

* Updated to `jekyll_plugin_support` v1.5.0


## 1.1.1 / 2023-02-14

* Now dependent on `jekyll_plugin_support`


## 1.1.0 / 2023-02-03

* Updated to `jekyll_all_collections` plugin v0.2.0.
* Fixed insidious bug where a valid link was not used properly.


## 1.0.14 / 2023-01-09

* Added `blank` parameter.


## 1.0.13 / 2022-12-14

* Links with embedded spaces are now supported when the new 'url' named parameter is used. For example, instead of specifying:

  ```html
  {% href http://link.com with space.html some text %}
  ```

  Instead specify (single and double quotes are equally valid):

  ```html
  {% href url="http://link.com with space.html" some text %}
  ```

* URLs can now contain environment variable references. For example, if $domain and $uri are environment variables:

  ```html
  {% href url="http://$domain.html" some text %}
  {% href url="$uri" some text %}
  ```


## 1.0.12 / 2022-08-09

* No longer abends if `plugin-vars` is not present in `_config.yml`


## 1.0.11 / 2022-04-27

* Suppresses target and rel=nofollow attributes for mailto: links.


## 1.0.10 / 2022-04-27

* Works from pre-computed `site['all_collections']` provided by a new dependency called `jekyll_all_collections`.


## 1.0.9 / 2022-04-25

* Match now looks at all collections, not just posts


## 1.0.8 / 2022-04-11

* Fixed match text


## 1.0.7 / 2022-04-11

* Fixed bad reference when more than one URL matches


## 1.0.6 / 2022-04-05

* Updated to `jekyll_plugin_logger` v2.1.0


## 1.0.5 / 2022-03-28

* Fixed problem with URI rendering


## 1.0.4 / 2022-03-28

* Fixed problem with `match` option


## 1.0.0 / 2022-03-11

* Made into a Ruby gem and published on RubyGems.org as [jekyll_href](https://rubygems.org/gems/jekyll_href).
* `bin/attach` script added for debugging
* Rubocop standards added
* Proper versioning and CHANGELOG.md added


## 0.1.0 / 2020-12-29

* Initial version published
