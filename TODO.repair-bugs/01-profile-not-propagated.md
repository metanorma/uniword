# Bug 01: Profile not propagated through save API

## Severity: FIXED

## Summary

~~When saving a document via `DocumentRoot#save` or `DocumentWriter#save`, the `Docx::Profile` is never passed to `Docx::Package`.~~

**Status: Fixed in commit `e48c309`.** The profile is now properly propagated through the entire save chain with `Profile.defaults` as fallback.

## Verification

```ruby
doc = Uniword.load("test.docx")
doc.save("output.docx")
# → Package.to_file now defaults to Profile.defaults
# → Reconciler Group 2 now runs with profile
```

## What was fixed

- `DocumentRoot#save(path, format: :auto, profile: nil)` — accepts profile kwarg
- `DocumentWriter#save(path, format: :auto, profile: nil)` — forwards profile
- `Package.to_file(document, path, profile: nil)` — defaults to `Profile.defaults`
- Reconciler Group 2 now always executes
