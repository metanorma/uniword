# Contributing to Uniword

Thank you for your interest in contributing to Uniword! This document provides guidelines and instructions for contributing to the project.

## Code of Conduct

By participating in this project, you agree to maintain a respectful and inclusive environment for all contributors.

## Development Setup

### Prerequisites

- Ruby 3.0 or higher
- Bundler

### Setup Steps

1. Fork the repository on GitHub
2. Clone your fork locally:
   ```shell
   git clone https://github.com/YOUR-USERNAME/uniword.git
   cd uniword
   ```

3. Install dependencies:
   ```shell
   bundle install
   ```

4. Run tests to ensure everything is working:
   ```shell
   bundle exec rspec
   ```

5. Create a feature branch:
   ```shell
   git checkout -b feature/my-new-feature
   ```

## Running Tests

### All Tests

Run the complete test suite:

```shell
bundle exec rspec
```

### Specific Test Files

Run tests for a specific file:

```shell
bundle exec rspec spec/uniword/document_spec.rb
```

### Test Categories

Run specific categories of tests:

```shell
# Unit tests
bundle exec rspec spec/uniword/

# Integration tests
bundle exec rspec spec/integration/

# Performance tests
bundle exec rspec spec/performance/
```

### Test Coverage

The project aims for high test coverage. New features should include comprehensive tests covering:

- Happy path scenarios
- Edge cases
- Error conditions
- Round-trip conversions

## Code Style

### RuboCop

The project uses RuboCop for code style enforcement. Run RuboCop before committing:

```shell
bundle exec rubocop
```

Auto-fix issues where possible:

```shell
bundle exec rubocop -A --auto-gen-config
```

### Code Style Guidelines

- Use 2 spaces for indentation (no tabs)
- Maximum line length of 80 characters
- Use `require_relative` for files in the same codebase
- Remove unused `require` or `require_relative` statements
- Use `attr_reader`, `attr_writer`, and `attr_accessor` for attributes
- Follow SOLID principles and object-oriented design
- Keep files under 700 lines of code
- Keep methods focused and under 50 lines

### Documentation

- Document all public classes and methods with YARD
- Include `@param`, `@return`, and `@raise` tags
- Provide code examples in documentation
- Use clear, descriptive names for classes and methods

Example YARD documentation:

```ruby
# Calculate the sum of two numbers
#
# @param a [Integer] The first number
# @param b [Integer] The second number
# @return [Integer] The sum of a and b
# @raise [ArgumentError] if inputs are not integers
#
# @example
#   add(2, 3)  # => 5
def add(a, b)
  raise ArgumentError unless a.is_a?(Integer) && b.is_a?(Integer)
  a + b
end
```

## Architecture Guidelines

### SOLID Principles

Follow SOLID principles throughout the codebase:

- **Single Responsibility** - Each class should have one reason to change
- **Open/Closed** - Open for extension, closed for modification
- **Liskov Substitution** - Subtypes must be substitutable for their base types
- **Interface Segregation** - Many specific interfaces better than one general
- **Dependency Inversion** - Depend on abstractions, not concretions

### MECE Principle

Ensure code is **Mutually Exclusive, Collectively Exhaustive**:

- Classes should not overlap in responsibility
- All functionality should be covered without gaps
- Clear separation of concerns

### Design Patterns

The project uses several design patterns:

- **Strategy Pattern** - Format handlers (DOCX, MHTML)
- **Factory Pattern** - Document creation
- **Builder Pattern** - Fluent document construction
- **Visitor Pattern** - Document traversal
- **Registry Pattern** - Element and handler discovery

When adding new features, consider which patterns apply.

## Adding New Classes

When adding new classes to Uniword, follow these guidelines to maintain our autoload architecture:

### Default Approach: Use Autoload

For most new classes, use autoload for lazy loading:

```ruby
# In lib/uniword.rb
autoload :YourNewClass, 'uniword/your_new_class'
```

Place the autoload statement in the appropriate category section:
- Document structure and components
- Table components
- Formatting and styling
- Infrastructure and utilities
- Office ML variants

### When to Use require_relative

Only use `require_relative` if your class meets ALL these criteria:

1. **Has side effects at load time**
   - Self-registration with registries
   - Module-level code execution
   - Class-level method calls

2. **Is referenced in module-level constants**
   ```ruby
   Document = Wordprocessingml::DocumentRoot  # Requires immediate loading
   ```

3. **Has deep cross-dependencies with eagerly loaded modules**
   - Format handlers
   - Core namespace modules

### Documentation Requirements

If using `require_relative`, you MUST add clear documentation:

```ruby
# NOTE: This class MUST use require_relative because:
# - Specific architectural reason
# - Impact if autoload were used instead
require_relative 'uniword/special_class'
```

### Testing Requirements

After adding any class (autoload or require_relative):

1. Run full test suite: `bundle exec rspec`
2. Verify autoload works: `ruby -e "require './lib/uniword'; Uniword::YourNewClass"`
3. Check API compatibility: Ensure existing code still works
4. Update documentation: Add to README.adoc if public API

### Examples

**Good (autoload)**:
```ruby
# New utility class with no dependencies
autoload :DocumentValidator, 'uniword/document_validator'
```

**Good (require_relative with documentation)**:
```ruby
# New format handler that self-registers
# NOTE: MUST use require_relative because format handlers self-register
# with FormatHandlerRegistry at load time (side effect)
require_relative 'uniword/formats/pdf_handler'
```

**Bad (autoload without considering dependencies)**:
```ruby
# Don't do this if the class is used in module-level constants!
autoload :CoreNamespace, 'uniword/core_namespace'  # Will cause NameError
```

## Adding New Features

### Before You Start

1. Check existing issues and pull requests
2. Create an issue describing the feature
3. Discuss the approach with maintainers
4. Get approval before starting work

### Implementation Steps

1. **Design** - Plan the architecture and API
2. **Implement** - Write the code following style guidelines
3. **Test** - Add comprehensive tests
4. **Document** - Add YARD documentation and examples
5. **Examples** - Update or add examples demonstrating the feature
6. **Changelog** - Add entry to CHANGELOG.md

### File Organization

- Core models go in `lib/uniword/`
- Properties classes go in `lib/uniword/properties/`
- Format handlers go in `lib/uniword/formats/`
- Serializers go in `lib/uniword/serialization/`
- Infrastructure code goes in `lib/uniword/infrastructure/`
- Tests mirror the lib structure in `spec/`

## Commit Messages

Use semantic commit messages:

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types

- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Build process or auxiliary tool changes

### Examples

```
feat(tables): add cell merging support

Implement horizontal and vertical cell merging for tables.
Includes new TableCell#merge_horizontal and #merge_vertical methods.

Closes #123
```

```
fix(docx): correct paragraph spacing serialization

Fix issue where spacing_before was not properly serialized
to OOXML format.

Fixes #456
```

## Pull Request Process

### Before Submitting

1. Ensure all tests pass:
   ```shell
   bundle exec rspec
   ```

2. Ensure RuboCop compliance:
   ```shell
   bundle exec rubocop
   ```

3. Update documentation:
   - Add YARD docs for new methods
   - Update README.adoc if needed
   - Add examples if applicable

4. Update CHANGELOG.md:
   - Add entry under "Unreleased" section
   - Follow existing format

### Submitting a Pull Request

1. Push your branch to your fork
2. Create a pull request on GitHub
3. Fill out the pull request template
4. Link related issues
5. Wait for review

### Pull Request Guidelines

- **One feature per PR** - Keep PRs focused and manageable
- **Clear description** - Explain what and why
- **Tests included** - All new code must have tests
- **Documentation updated** - Keep docs in sync with code
- **Clean commit history** - Squash commits if needed
- **Responsive to feedback** - Address review comments promptly

## Reporting Bugs

### Before Reporting

1. Check if the issue already exists
2. Verify it's a bug and not expected behavior
3. Test with the latest version

### Bug Report Template

```markdown
**Description**
A clear description of the bug.

**To Reproduce**
Steps to reproduce:
1. ...
2. ...
3. ...

**Expected Behavior**
What you expected to happen.

**Actual Behavior**
What actually happened.

**Environment**
- Ruby version:
- Gem version:
- OS:

**Additional Context**
Any other relevant information.
```

## Feature Requests

### Before Requesting

1. Check if the feature already exists
2. Search for similar requests
3. Consider if it fits the project scope

### Feature Request Template

```markdown
**Problem**
What problem does this solve?

**Proposed Solution**
How should it work?

**Alternatives**
Other solutions considered?

**Additional Context**
Any other relevant information.
```

## Development Workflow

### Typical Workflow

1. Create issue or comment on existing issue
2. Fork and clone repository
3. Create feature branch
4. Implement feature with tests
5. Run tests and RuboCop
6. Update documentation
7. Commit with semantic message
8. Push and create pull request
9. Address review feedback
10. Merge when approved

### Branch Naming

Use descriptive branch names:

- `feature/add-table-borders`
- `fix/paragraph-spacing-bug`
- `docs/update-readme`
- `refactor/extract-serializer`

## Testing Guidelines

### Test Structure

```ruby
RSpec.describe MyClass do
  describe '#my_method' do
    context 'when condition is true' do
      it 'returns expected result' do
        # Test implementation
      end
    end

    context 'when condition is false' do
      it 'raises an error' do
        expect { subject.my_method }.to raise_error(ArgumentError)
      end
    end
  end
end
```

### Test Categories

- **Unit tests** - Test individual classes in isolation
- **Integration tests** - Test component interactions
- **Performance tests** - Benchmark critical operations
- **Round-trip tests** - Verify format conversion fidelity

## Questions?

- Open an issue for questions
- Check existing documentation
- Review code examples in `examples/` directory

## License

By contributing, you agree that your contributions will be licensed under the same license as the project (BSD 2-Clause License).

## Thank You!

Your contributions make Uniword better for everyone. Thank you for taking the time to contribute!