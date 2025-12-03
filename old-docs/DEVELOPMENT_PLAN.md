# Developing the new Uniword gem

Use the ~/src/mn/edoxen gem as a template.

Use these two resources for guidance:

- reference/docx-js - (most important reference) Easily generate and modify .docx files with JS/TS with a nice declarative API. Works for Node and on the Browser.
- reference/docx - (good starting point) which is a folder containing a DOCX parsing library (far from being fully complete or supports all features)
- reference/html2doc - (important reference for MHTML) the Metanorma "HTML to DOC MHTML" converter
- reference/word-to-markdown - Word to Markdown converter that uses LibreOffice under the hood
- reference/docxjs - JS library that render/convert DOCX document into HTML document with keeping HTML semantic as much as possible
- /Users/mulgogi/src/mn/sts-ruby which has code for parsing STS XML documents, demonstrating how to use lutaml-model for XML parsing and model representation for mixed content documents

Libraries to use:

- lutaml-model (~/src/lutaml/lutaml-model) for XML parsing and model representation

Our goal is to develop from scratch a new gem that can read and write DOC MHTML and read DOCX documents.
