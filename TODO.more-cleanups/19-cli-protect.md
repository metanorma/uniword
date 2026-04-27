# 19: CLI `protect` — encrypt/decrypt documents, set permissions

**Priority:** P3
**Effort:** Medium (~3 hours)
**Files:**
- `lib/uniword/cli.rb` (add `protect` command)
- `lib/uniword/security/document_protection.rb` (new)

## Use Case

Legal professionals need to prevent unauthorized editing of contracts. HR needs
to restrict who can edit performance reviews. Organizations need to password-
protect sensitive documents.

Note: Full OOXML encryption is complex (ECMA-376 encryption). Start with
document protection (read-only, form-filling, tracked-changes-only) which is
XML-level, not ZIP-level encryption.

## Proposed CLI Syntax

```bash
# Set read-only protection
uniword protect report.docx output.docx --readonly --password secret123

# Allow only comments
uniword protect report.docx output.docx --comments-only --password secret123

# Allow only form filling
uniword protect report.docx output.docx --forms-only --password secret123

# Allow only tracked changes
uniword protect report.docx output.docx --tracked-changes --password secret123

# Remove protection
uniword protect report.docx output.docx --remove --password secret123

# Check protection status
uniword protect status report.docx
```

## Implementation

### Document Protection

OOXML document protection is set via `w:documentProtection` element in
`word/settings.xml`. This controls editing restrictions at the XML level.

```ruby
module Uniword
  module Security
    class DocumentProtection
      PROTECTION_TYPES = {
        readonly: :readOnly,
        comments_only: :comments,
        forms_only: :forms,
        tracked_changes: :trackedChanges,
      }.freeze

      def initialize(document)
        @document = document
      end

      def protect(type:, password: nil)
        settings = @document.settings
        raise Error, "Document has no settings" unless settings

        protection = Wordprocessingml::DocumentProtection.new(
          edit: PROTECTION_TYPES[type],
          enforcement: true,
        )

        if password
          protection.hash = hash_password(password)
          protection.algorithm = "SHA-1"
          protection.spin_count = 100_000
        end

        settings.document_protection = protection
        @document
      end

      def unprotect(password: nil)
        settings = @document.settings
        return @document unless settings&.document_protection

        protection = settings.document_protection
        if protection.hash && password
          unless verify_password(password, protection)
            raise Error, "Incorrect password"
          end
        end

        settings.document_protection = nil
        @document
      end

      def status
        protection = @document.settings&.document_protection
        return { protected: false } unless protection&.enforcement

        {
          protected: true,
          type: PROTECTION_TYPES.key(protection.edit.to_sym),
          has_password: !protection.hash.nil?,
        }
      end

      private

      def hash_password(password)
        # OOXML password hashing: SHA-1 with spin_count iterations
        # See ECMA-376 Part 4, Section 14.2.3
        require "digest/sha1"
        hash = Digest::SHA1.digest(password.encode("UTF-16LE"))
        100_000.times { hash = Digest::SHA1.digest(hash) }
        Base64.strict_encode64(hash)
      end

      def verify_password(password, protection)
        hash_password(password) == protection.hash
      end
    end
  end
end
```

### CLI Integration

```ruby
desc "protect FILE OUTPUT", "Set document protection"
option :readonly, desc: "Read-only protection", type: :boolean
option :comments_only, desc: "Allow only comments", type: :boolean
option :forms_only, desc: "Allow only form filling", type: :boolean
option :tracked_changes, desc: "Allow only tracked changes", type: :boolean
option :remove, desc: "Remove protection", type: :boolean
option :password, desc: "Protection password"
def protect(input_path, output_path)
  doc = DocumentFactory.from_file(input_path)
  sec = Security::DocumentProtection.new(doc)

  if options[:remove]
    sec.unprotect(password: options[:password])
    say("Protection removed", :green)
  else
    type = [:readonly, :comments_only, :forms_only, :tracked_changes]
             .find { |t| options[t] } || :readonly
    sec.protect(type: type, password: options[:password])
    say("Protection set: #{type}", :green)
  end

  doc.save(output_path)
end
```

## Key Design Decisions

1. **XML-level protection first**: `w:documentProtection` controls editing
   restrictions. Full ZIP encryption is a future enhancement.
2. **SHA-1 password hashing**: OOXML specifies SHA-1 with configurable
   spin_count. We use 100K iterations.
3. **Protection types map to OOXML edit modes**: readOnly, comments, forms,
   trackedChanges.
4. **Password optional**: protection can be set without a password (user can
   toggle off in Word). Password makes it harder to remove.

## Future Enhancement

Full OOXML encryption (ECMA-376 encryption) would encrypt individual ZIP entries
with AES-256. This is significantly more complex and would require a separate
implementation.

## Verification

```bash
bundle exec rspec spec/uniword/security/document_protection_spec.rb
```
