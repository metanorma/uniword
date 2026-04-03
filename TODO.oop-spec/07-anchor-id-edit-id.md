# 07-anchor-id-edit-id.md

# Fix: Add anchorId and editId attributes to Anchor class

## Problem
The `Anchor` class in `wp_drawing` is missing `anchorId` and `editId` attributes.
These are in the `w14:` (Word2010) namespace and appear on anchor elements.

## Fix

### File: `lib/uniword/wp_drawing/anchor.rb`

Add to `Anchor` class:
```ruby
attribute :anchor_id, :string
attribute :edit_id, :string

# In xml block:
map_attribute 'anchorId', to: :anchor_id, render_nil: false
map_attribute 'editId', to: :edit_id, render_nil: false

# Add namespace_scope for w14: attributes:
namespace_scope [
  { namespace: Uniword::Ooxml::Namespaces::Word2010, declare: :auto },
]
```

## Verification
```bash
bundle exec rspec spec/integration/docx_roundtrip_spec.rb:138
```
