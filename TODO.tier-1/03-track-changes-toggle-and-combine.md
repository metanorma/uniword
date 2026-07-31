# 03 — track-changes toggle + combine

**Status:** PARTIALLY COMPLETE (toggle yes, combine deferred)
**Priority:** Medium-High (review workflow completeness)
**Depends on:** nothing

## Two related review features

### 3a. track-changes toggle

Word's Review → Track Changes toggle. OOXML represents this as
`<w:trackChanges/>` inside `<w:settings>`.

#### What's needed

- `Wordprocessingml::Settings#track_changes` boolean attribute
- `Settings#track_changes=`
- `DocumentRoot#track_changes=` (delegates to settings)
- CLI: `uniword review track-changes on FILE` / `off FILE` /
  `status FILE`

#### Ruby API

```ruby
doc.track_changes = true
doc.save("tracked.docx")

doc.track_changes_enabled?  # => true
```

#### CLI

```
uniword review track-changes on INPUT OUTPUT
uniword review track-changes off INPUT OUTPUT
uniword review track-changes status FILE
```

#### Verification

- Spec: `spec/uniword/wordprocessingml/settings/track_changes_spec.rb`
- Spec: `spec/uniword/cli/review_cli_spec.rb` (extend)

### 3b. combine (3-way merge)

Word's Review → Combine. Three-way merge of two revisions against a
common base.

#### Why deferred

3-way merge is genuinely hard. Element-level diff at paragraph/run
level + conflict detection + conflict rendering (as SDT blocks
showing both versions) is a ~500 LOC feature with subtle correctness
requirements. Better as a standalone Tier 1 item than folded into the
toggle PR.

#### Design sketch (for next session)

```
Uniword::Review::Combiner
  ├── Diff3               # 3-way paragraph diff
  ├── ConflictDetector    # classify changes (M-only, T-only, both-same, conflict)
  ├── ConflictRenderer    # emit SDT showing both sides
  └── MergeResult         # merged doc + conflict count + per-conflict details
```

Algorithm (paragraph-level for v1):
1. Build BASE paragraph list (by index + fingerprint).
2. Diff MINE vs BASE → changes M.
3. Diff THEIRS vs BASE → changes T.
4. For each paragraph:
   - Only in M: take M.
   - Only in T: take T.
   - Same change in both: take once.
   - Conflicting changes: emit SDT with both versions, mark conflict.
5. Output merged document.

Ruby API:
```ruby
merged = doc.combine(base: base_doc, theirs: theirs_doc)
merged.conflicts.count  # => Integer
merged.has_conflicts?   # => Boolean
merged.save("merged.docx")
```

CLI:
```
uniword review combine BASE MINE THEIRS OUTPUT
```

#### Tier

Promote to its own Tier 1 item: `TODO.tier-1/04-combine-3-way-merge.md`
when picked up.
