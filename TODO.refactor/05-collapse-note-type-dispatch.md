# 05 — Collapse note-type dispatch via lookup helpers

**Priority:** High (architecture / OCP)
**Files:** `lib/uniword/docx/reconciler/notes.rb`,
`lib/uniword/docx/reconciler/referential_integrity.rb`,
`lib/uniword/docx/reconciler/helpers.rb`

## Problem

The dispatch

```ruby
case type
when :footnote then package.footnotes
when :endnote then package.endnotes
end
```

appears **10 times in `notes.rb`** and **4 times in
`referential_integrity.rb`** — 14 sites total. Each dispatches on the
same `:footnote | :endnote` discriminator to access parallel attributes
on Package and on the notes container.

This violates OCP: adding a third note type (e.g., `:annotation`)
requires editing all 14 sites in lockstep.

## Root cause

Ruby's attribute model doesn't expose "the footnotes for this package"
as a single concept — there are two parallel attributes. Without an
abstraction layer, callers fall back to `case`.

## Fix

Add two helpers in `Helpers`:

```ruby
def notes_collection_for(type)
  case type
  when :footnote then package.footnotes
  when :endnote  then package.endnotes
  end
end

def note_entries_for(notes, type)
  return [] unless notes

  case type
  when :footnote then notes.footnote_entries
  when :endnote  then notes.endnote_entries
  end
end

def note_reference_from_run(run, type)
  case type
  when :footnote then run.footnote_reference
  when :endnote  then run.endnote_reference
  end
end
```

Then every `case type when ...` in notes.rb and referential_integrity.rb
calls these helpers instead. Adding a third note type becomes **one
edit per helper**, not 14.

### Optional further improvement

For full OCP, register a per-type adapter:

```ruby
NOTE_ADAPTERS = {
  footnote: NoteAdapter.new(
    collection_reader: :footnotes,
    entries_reader: :footnote_entries,
    ref_reader: :footnote_reference,
  ),
  endnote: NoteAdapter.new(...)
}.freeze
```

This is more work; the helper approach is sufficient for now.

### Verification

Spec: assert the helpers return correct values for `:footnote` and
`:endnote`. Existing reconciler specs should continue to pass.
