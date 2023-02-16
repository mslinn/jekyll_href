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
    ```
    {% href http://link.com with space.html some text %}
    ```
    Instead specify (single and double quotes are equally valid):
    ```
    {% href url="http://link.com with space.html" some text %}
    ```
  * URLs can now contain environment variable references. For example, if $domain and $uri are environment variables:
    ```
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
