# 010: Eliminate remaining `public_send` usage in part-copy mappings

## Status: DONE

## Problem

`PackageDefaults::ClassMethods#copy_document_parts_to_package` and
`DocumentFactory#copy_package_parts_to_document` both use `public_send` to
iterate over a mapping hash and copy attributes between objects:

```ruby
# package_defaults.rb:44
DOCUMENT_TO_PACKAGE_MAPPINGS.each do |doc_attr, pkg_attr|
  value = document.public_send(doc_attr)
  package.public_send(:"#{pkg_attr}=", value) if value
end

# document_factory.rb:202
PACKAGE_PART_MAPPINGS.each do |pkg_attr, doc_attr|
  value = package.public_send(pkg_attr)
  document.public_send(:"#{doc_attr}=", value) if value
end
```

`public_send` breaks encapsulation — it calls arbitrary methods by name,
defeating type checking and making it impossible to trace call sites with
static analysis. The user's explicit requirement: "Never use private send
methods (breaks encapsulation)."

## Fix

Replace the mapping-hash + `public_send` pattern with explicit assignment
methods. Two options:

**Option A (preferred)**: Explicit methods with direct attribute access.

```ruby
def copy_document_parts_to_package(document, package)
  package.styles = document.styles_configuration if document.styles_configuration
  package.settings = document.settings if document.settings
  package.font_table = document.font_table if document.font_table
  # ... etc
end
```

This is more verbose but explicit, type-safe, and grep-friendly. New parts
are added by appending a line — the mapping hash already enumerates every
part, so the verbosity difference is zero.

**Option B**: Use a dedicated copier class with typed methods.

## Why explicit is better
- Grep-friendly: `grep "package.styles ="` finds the call site
- Type errors caught at load time (typo in method name raises NoMethodError)
- No dynamic dispatch — the mapping is visible in code
- Easier to add per-attribute validation logic later

## Files
- `lib/uniword/docx/package_defaults.rb` (lines 40-53)
- `lib/uniword/document_factory.rb` (lines 198-205)
