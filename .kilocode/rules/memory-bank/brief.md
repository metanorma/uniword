Uniword is an open-source Ruby library for creating and manipulating Word
documents in the DOCX format.

In the DOCX format, documents are stored as ZIP packages containing multiple XML
files that define the document structure, styles, properties, and media. Uniword
provides a high-level API to build and modify these documents programmatically.

Uniword provides a Builder DSL to create document elements such as paragraphs,
headings, tables, and styles. It also supports applying themes and StyleSets to
control the visual appearance of the document.

Uniword focuses on round-trip fidelity, ensuring that documents loaded and saved
preserve all formatting and structure. It includes comprehensive modelling to
handle the DOCX XML format and packaging of DOCX.
