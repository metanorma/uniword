# 09: Deduplicate from_html / html_to_doc

**Priority:** P1
**Effort:** Small (~30 min)
**File:** `lib/uniword.rb:266-299`

## Problem

`from_html` and `html_to_doc` have identical implementations — both create a
new `DocumentRoot`, call `HtmlImporter.import(html)`, and append paragraphs.
Only `html_to_docx` calls `html_to_doc`; `from_html` is not called internally.

```ruby
# Line 266: Identical to html_to_doc
def from_html(html)
  doc = Wordprocessingml::DocumentRoot.new
  paragraphs = HtmlImporter.import(html)
  paragraphs.each { |para| doc.body.paragraphs << para }
  doc
end

# Line 279: Identical to from_html
def html_to_doc(html)
  doc = Wordprocessingml::DocumentRoot.new
  paragraphs = HtmlImporter.import(html)
  paragraphs.each { |para| doc.body.paragraphs << para }
  doc
end

# Line 293: Only caller of html_to_doc
def html_to_docx(html, path)
  doc = html_to_doc(html)
  doc.to_file(path)
end
```

## Fix

Keep `from_html` as the canonical method (more idiomatic name). Make
`html_to_doc` an alias for backward compatibility.

```ruby
def from_html(html)
  doc = Wordprocessingml::DocumentRoot.new
  paragraphs = HtmlImporter.import(html)
  paragraphs.each { |para| doc.body.paragraphs << para }
  doc
end

alias_method :html_to_doc, :from_html

def html_to_docx(html, path)
  from_html(html).to_file(path)
end
```

Check for external callers of `html_to_doc`:

```bash
grep -rn 'html_to_doc\b' lib/ spec/ --include='*.rb'
```

## Verification

```bash
bundle exec rspec
```
