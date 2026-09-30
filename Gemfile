source "https://rubygems.org"

gem "github-pages", group: :jekyll_plugins

# octokit (pulled in by jekyll-github-metadata) calls JSON.parse with an
# arity json 3.x removed, breaking the Jekyll build. Pin below 3.0 until
# octokit fixes it upstream.
gem "json", "< 3.0"

gem "tzinfo-data"
gem "wdm", "~> 0.1.0" if Gem.win_platform?

# If you have any plugins, put them here!
group :jekyll_plugins do
  gem "jekyll-paginate"
  gem "jekyll-sitemap"
  gem "jekyll-gist"
  gem "jekyll-feed"
  gem "jemoji"
  gem "jekyll-include-cache"
  gem "jekyll-mermaid"
  gem "faraday-retry"
end

gem "webrick", "~> 1.7"
