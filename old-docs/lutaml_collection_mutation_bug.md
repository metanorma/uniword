# Lutaml-Model Bug: Collection Attribute Mutations Not Serialized

## Problem Description

When a collection attribute is mutated after object initialization (e.g., by calling methods like `push`, `<<`, or custom `add_*` methods), the mutations are not reflected in the XML serialization. The collection only serializes correctly if it's passed in the constructor.

## Minimal Reproduction Case

```ruby
require 'lutaml/model'

class WordProcessingML < Lutaml::Model::XmlNamespace
  uri 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'
  prefix_default 'w'
  element_form_default :qualified
  attribute_form_default :qualified
end

class TabStop < Lutaml::Model::Serializable
  xml do
    element 'tab'
    namespace WordProcessingML
    map_attribute 'pos', to: :position
    map_attribute 'val', to: :alignment
    map_attribute 'leader', to: :leader
  end

  attribute :position, :integer
  attribute :alignment, :string, default: -> { 'left' }
  attribute :leader, :string, default: -> { 'none' }
end

class TabStopCollection < Lutaml::Model::Serializable
  xml do
    element 'tabs'
    namespace WordProcessingML
    map_element 'tab', to: :tabs
  end

  attribute :tabs, TabStop, collection: true, default: -> { [] }

  def add_tab(position, alignment, leader)
    tab = TabStop.new(position: position, alignment: alignment, leader: leader)
    tabs << tab  # Mutation happens here
    tab
  end
end

# Test Case 1: Mutating collection after initialization
collection = TabStopCollection.new
collection.add_tab(1440, "center", "dot")

puts "Tabs array populated: #{collection.tabs.size}"  # => 1 ✓
puts collection.to_xml
# Output: <tabs xmlns="http://..."/>  ❌ Empty!

# Test Case 2: Passing collection in constructor
tab = TabStop.new(position: 1440, alignment: "center", leader: "dot")
collection2 = TabStopCollection.new(tabs: [tab])

puts collection2.to_xml
# Output: <tabs xmlns="http://...">
#           <tab w:pos="1440" w:val="center" w:leader="dot"/>
#         </tabs>  ✓ Works!
```

##Expected Behavior

When a collection attribute is mutated after initialization, those changes should be visible during serialization.

## Actual Behavior

- **Mutation via `<<`**: NOT serialized
- **Mutation via custom methods** (e.g., `add_tab`): NOT serialized  
- **Initialization via constructor**: Works correctly

## Impact

This bug affects any model that:
1. Has collection attributes with default values
2. Provides mutation methods to add items to the collection
3. Expects those mutations to be serialized

## Current Workaround

The workaround is to create a NEW parent object with the updated collection:

```ruby
class Paragraph
  def add_tab_stop(position:, alignment: 'left', leader: nil)
    ensure_properties
    
    current_tabs = properties.tab_stops || TabStopCollection.new
    current_tabs.add_tab(position, alignment, leader || 'none')
    
    # Workaround: Create new properties object with the updated collection
    update_properties(tab_stops: current_tabs)  # Re-initializes parent
    self
  end
  
  private def update_properties(**updates)
    current_attrs = extract_current_properties
    self.properties = ParagraphProperties.new(**current_attrs.merge(updates))
  end
end
```

This works because the collection is passed via the constructor, but it's **extremely inefficient** as it requires recreating the entire parent object chain.

## Root Cause (Hypothesis)

It appears that lutaml-model caches or snapshots collection attribute values during initialization and doesn't track subsequent mutations. The serialization logic may be reading from this initial snapshot rather than the live collection object.

## Proposed Fix

Lutaml-model should:
1. Track mutations to collection attributes
2. Serialize the current state of the collection, not a snapshot
3. Or, provide explicit guidance on immutability if collections are intended to be immutable after initialization

## Environment

- Lutaml-model version: 0.7.x
- Ruby version: 3.3.x
- Use case: OOXML (Office Open XML) document generation with dynamic content