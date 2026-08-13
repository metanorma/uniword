# 19 — Reduce spec `instance_variable_set`/`get`

**Status:** Implemented, pending Windows CI. 30 claimed → 6 real → 0. The 6
were dead code: they set an ivar (`@finalizer`) that `Tempfile` never reads.
Local runs are green, but the workaround existed for a Windows-only `EACCES`
flake, so Windows CI is the gate that closes this out.
**Priority:** Low (the remaining sites are dead code, not encapsulation
breaks)
**Files:** `spec/uniword/infrastructure/zip_extractor_spec.rb`

## Status of the original note

Stale. It claimed **30 sites across 12 files**. Actual today: **7
matches**, **6** of them real, all in one file:

Before this change:

```
spec/uniword/infrastructure/zip_extractor_spec.rb:37,63,84,136,191,226
spec/uniword/builder/run_builder_drawing_spec.rb:7   # a test NAME, not a use
```

After it, the only remaining match in `spec/` is that test name — no real
uses are left.

The 11 other files listed in the original note were already clean. The
work happened incrementally and nobody updated the note. The three
patterns it describes no longer occur.

## Problem

The six remaining sites are all the same line:

```ruby
temp_zip.instance_variable_set(:@finalizer, proc {})
# "Suppress finalizer - we handle cleanup manually via ensure block"
```

**`Tempfile` has no `@finalizer` ivar.** The installed version
(`tempfile-0.3.1`) uses `@finalizer_manager`:

```
instance ivars: [:@unlinked, :@mode, :@opts, :@delegate_dc_obj, :@finalizer_manager]
after set:      [..., :@finalizer_manager, :@finalizer]
```

The assignment creates a brand-new ivar that nothing ever reads. It
suppresses nothing. The comment describes behavior the code does not
have.

The variant inside the `create_temp_zip` helper (line 20 before this
change) is broken differently — it calls `remove_instance_variable` on
the `Tempfile` **class object** rather than on a tempfile instance, then
rescues the resulting `NameError`. Also a no-op.

So whatever fixed the original Windows `EACCES` flake, it was not this.
The `close` + `safe_delete` calls above it are doing the actual work.

This inverts the obvious fix. Consolidating the six copies behind one
well-named helper, or documenting a sanctioned exception, would enshrine
dead code and teach the next reader that the project needs an ivar
exception it does not need.

## Fix

Single PR. Small.

What was done:

1. Deleted all six `instance_variable_set(:@finalizer, proc {})` calls
   along with the comments claiming they suppress finalization.
2. Deleted `create_temp_zip` in full — its own `Tempfile.new`, `close`
   and `safe_delete` included. It had no callers on either ref, so
   nothing lost coverage.
3. Kept `Tempfile.new` and the existing cleanup at all six remaining
   sites. That was the minimal correct change; nothing else moved.

`Tempfile.create` or `Dir.mktmpdir` is **optional and not drop-in**:
`Tempfile.create` returns a plain `File`, which has no `unlink` instance
method, so any existing `temp_zip.unlink` cleanup breaks. A valid
conversion closes and deletes the created file before rubyzip opens the
path, then uses `safe_delete(file.path)` in the `ensure` block. Only do
this if it genuinely simplifies the fixture.

## Risk

The `create_temp_zip` comment this change deletes attributed the
workaround to a **Windows** `EACCES` flake, and there is a recent commit
hardening a different Windows save-gate test (`facd8fb`). Development
machines here are macOS, so the flake cannot be reproduced locally
either way.

The evidence says the ivar cannot be load-bearing — it targets a name
Tempfile does not use. But "cannot possibly matter" is exactly the
reasoning that precedes a surprise, and the surprise here lands on a
platform we cannot test on.

**Land this alone, on its own branch, and let Windows CI vote.** Do not
bundle it with other work. If CI goes red, the fallback is
`Tempfile.create`, not restoring the no-op.

## Verification

- `bundle exec rspec spec/uniword/infrastructure/zip_extractor_spec.rb`
  green, run repeatedly to check for a resurfaced flake.
- `grep -rn "instance_variable_set\|instance_variable_get" spec/` returns
  only the unrelated test name in `run_builder_drawing_spec.rb`.
- **Windows CI green.** This is the gate that matters; local green proves
  little for a Windows-only workaround.
- `bundle exec rubocop spec/uniword/infrastructure/zip_extractor_spec.rb`

## Out of scope

- Renaming the `run_builder_drawing_spec.rb` example. Its name
  accurately describes what it asserts; it is only a grep false positive.
- `Uniword::Infrastructure::ZipExtractor` itself. Nothing here touches
  library code.
- `send`/`__send__` in specs. Different rule, different TODO.
