# 20: Update gemspec Ruby version, gem groups, optional dependencies

**Priority:** P1
**Effort:** Small (~1 hour)
**Files:**
- `uniword.gemspec`
- `Gemfile`

## Problem

### 1. Minimum Ruby version is 2.7 (EOL since March 2023)

```ruby
# gemspec line 41
spec.required_ruby_version = ">= 2.7.0"
```

The codebase uses patterns that assume 3.0+:
- `frozen_string_literal: true` in all 1307 files
- Pattern matching (Ruby 3.0+)
- `endless` method syntax in some places

Should be `>= 3.0` (or `>= 3.2` to match CI).

### 2. Gemspec says `lutaml-model ~> 0.8` but Gemfile uses GitHub main

```ruby
# gemspec line 44
spec.add_dependency "lutaml-model", "~> 0.8"

# Gemfile line 10
gem 'lutaml-model', github: 'lutaml/lutaml-model', branch: 'main'
```

If uniword uses features from main that aren't in 0.8.x, released gems will
break. Either:
- Pin to the minimum compatible version in gemspec
- Or ensure CI tests against the released version

### 3. `mail ~> 2.8` is a core dependency but only used for MHTML

```ruby
# gemspec line 45
spec.add_dependency "mail", "~> 2.8"
```

The `mail` gem is heavy (many dependencies). It's only used by the MHTML
pipeline. Consider making it optional:

```ruby
# gemspec
spec.add_development_dependency "mail", "~> 2.8"

# Or use a runtime dependency group
# Or lazy-require it only when MHTML features are used
```

### 4. Dev gems not in a group

```ruby
# Gemfile lines 13-26
gem "canon"
gem "rake"
gem "rspec"
gem "rubocop"
# ...
gem "ruby-prof"
```

None are in a `group :development, :test do` block. This means:
- Production installs get dev dependencies
- Can't use `bundle install --without development`
- Increases install surface for gem users

## Fix

```ruby
# Gemfile
gem "lutaml-model", github: "lutaml/lutaml-model", branch: "main"

group :development, :test do
  gem "canon"
  gem "rake"
  gem "rspec"
  gem "rubocop"
  gem "rubocop-performance"
  gem "rubocop-rake"
  gem "rubocop-rspec"
  gem "yard"
end

group :profiling, optional: true do
  gem "benchmark"
  gem "benchmark-ips"
  gem "benchmark-memory"
  gem "get_process_mem"
  gem "ruby-prof"
end
```

```ruby
# uniword.gemspec
spec.required_ruby_version = ">= 3.0"
spec.add_dependency "lutaml-model", "~> 0.8"
# Remove or make optional:
# spec.add_dependency "mail", "~> 2.8"
```

## Verification

```bash
bundle install
bundle exec rspec
# Verify production install works without dev gems:
bundle config set without development test profiling && bundle install
```
