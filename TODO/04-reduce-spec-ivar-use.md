# 19 — Reduce spec `instance_variable_set`/`get` (30 sites)

**Priority:** Medium (spec quality)
**Files:** Multiple spec files:
- `spec/uniword/wordprocessingml/comments_part_spec.rb` (4)
- `spec/uniword/wordprocessingml/tracked_changes_spec.rb` (4)
- `spec/uniword/wordprocessingml/comment_spec.rb` (1)
- `spec/uniword/wordprocessingml/comment_range_spec.rb` (2)
- `spec/uniword/validators/paragraph_validator_spec.rb` (4)
- `spec/uniword/validators/element_validator_spec.rb` (1)
- `spec/uniword/validators/table_validator_spec.rb` (1)
- `spec/uniword/infrastructure/zip_extractor_spec.rb` (5)
- `spec/uniword/builder/run_builder_spec.rb` (1)
- `spec/uniword/builder/image_embedding_spec.rb` (3)
- `spec/uniword/validation/rules/document_context_spec.rb` (1)
- `spec/uniword/validation/link_validator_spec.rb` (3)

## Problem

Project rule: never use `instance_variable_set`/`get`. Breaks
encapsulation.

30 sites in specs use these to:
1. Force-clear an attribute after construction (to test nil handling)
2. Inspect internal state (when no public reader exists)
3. Inject test doubles into private state

## Fix per pattern

### Pattern 1: Force-clear an attribute
```ruby
# Before
comment = Comment.new(comment_id: "1")
comment.instance_variable_set(:@comment_id, nil)

# After — construct without the attribute
comment = Comment.new
```

### Pattern 2: Inspect internal state
Add a public reader to the model, then assert through it:
```ruby
# Before
drawings = builder.model.instance_variable_get(:@drawings)

# After — expose on the model
class Model
  def drawings = @drawings
end
drawings = builder.model.drawings
```

### Pattern 3: Inject test doubles
Refactor to constructor injection:
```ruby
# Before
tf = TempZip.new
tf.instance_variable_set(:@finalizer, proc {})

# After — pass via constructor or a public writer
tf = TempZip.new(finalizer: proc {})
```

## Verification

`grep -rn "instance_variable_set\|instance_variable_get" spec/uniword/ | wc -l`
should trend toward 0. All affected specs pass.
