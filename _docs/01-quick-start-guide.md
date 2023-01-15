---
title: "Quick-Start Guide"
permalink: /docs/quick-start-guide/
excerpt: "How to quickly install and setup Minimal Mistakes for use with GitHub Pages."
last_modified_at: 2021-06-07T08:48:05-04:00
redirect_from:
  - /theme-setup/
toc: true
---

## General

Minimal Mistakes has been developed as a [Gem-based theme](http://jekyllrb.com/docs/themes/) for easier use, and 100% compatible with GitHub Pages when used as a remote theme.

**If you enjoy this theme, please consider [sponsoring me](https://github.com/sponsors/mmistakes) to continue developing and maintaining it.**

[!["Buy Me A Coffee"](https://user-images.githubusercontent.com/1376749/120938564-50c59780-c6e1-11eb-814f-22a0399623c5.png)](https://www.buymeacoffee.com/mmistakes)

[![Support via PayPal](https://cdn.jsdelivr.net/gh/twolfson/paypal-github-button@1.0.0/dist/button.svg)](https://www.paypal.me/mmistakes)
{: style="margin-top: 0.5em;"}

## Update Gemfile

Replace `gem "github-pages` or `gem "jekyll"` with `gem "jekyll", "~> 3.5"`. You'll need the latest version of Jekyll[^update-jekyll] for Minimal Mistakes to work and load all of the theme's assets properly, this line forces Bundler to do that.

[^update-jekyll]: You could also run `bundle update jekyll` to update Jekyll.

Add the Minimal Mistakes theme gem:

```ruby
gem "minimal-mistakes-jekyll"
```

When finished your `Gemfile` should look something like this:

```ruby
source "https://rubygems.org"

gem "jekyll", "~> 3.7"
gem "minimal-mistakes-jekyll"
```

---

That's it! If all goes well running `bundle exec jekyll serve` should spin-up your site.
