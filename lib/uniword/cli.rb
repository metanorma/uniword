# frozen_string_literal: true

# CLI entry point — loads decomposed classes from lib/uniword/cli/.
# Uniword::CLI is the main Thor class. Subcommands are in separate files.

require_relative "cli/helpers"
require_relative "cli/styleset_cli"
require_relative "cli/resources_cli"
require_relative "cli/theme_cli"
require_relative "cli/generate_cli"
require_relative "cli/review_cli"
require_relative "cli/diff_cli"
require_relative "cli/toc_cli"
require_relative "cli/images_cli"
require_relative "cli/spellcheck_cli"
require_relative "cli/template_cli"
require_relative "cli/headers_cli"
require_relative "cli/watermark_cli"
require_relative "cli/protect_cli"
require_relative "cli/main"
