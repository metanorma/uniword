# 16 — Redesign LazyLoader without instance_variable_get/set

**Priority:** High (forbidden pattern)
**Files:** `lib/uniword/lazy_loader.rb`

## Problem

`LazyLoader` uses `instance_variable_get`, `instance_variable_set`,
and `public_send` to memoize values dynamically:

```ruby
def lazy_load(instance_variable, ...)
  return instance_variable_get(instance_variable) if instance_variable_defined?(instance_variable)
  value = yield
  instance_variable_set(instance_variable, value)
  value
end
```

Project rule: never use `instance_variable_get`/`set` (breaks
encapsulation); never use `public_send` to call methods dynamically.

## Root cause

LazyLoader predates the project rules. It uses metaprogramming to
provide a generic lazy-loading facility, but the cost is that all
callsites are coupled to ivar naming conventions and method-name
strings.

## Fix

Replace the ivar-backed cache with a Hash-backed cache:

```ruby
module LazyLoader
  def lazy_load(cache_key, &block)
    @lazy_cache ||= {}
    return @lazy_cache[cache_key] if @lazy_cache.key?(cache_key)

    @lazy_cache[cache_key] = yield
  end
end
```

Callsites pass a Symbol cache_key instead of an ivar name.

For the `lazy_collection` variant, the same Hash can be used (with
Array default).

For the `lazy_size` method that checks size without forcing load,
expose a separate `cached_size(cache_key)` that returns nil if the
key isn't in the cache.

## Verification

- All callsites updated (grep `lazy_load`, `lazy_collection`)
- `bundle exec rubocop lib/uniword/lazy_loader.rb` reports 0
  instance_variable offenses
- Existing specs that exercise lazy loading still pass
