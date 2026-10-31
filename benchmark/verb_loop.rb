# frozen_string_literal: true

# Verb-loop benchmark: what does one `uniword` CLI invocation cost?
#
# Issue #81: every CLI invocation pays full model hydration on open.
# This benchmark measures that cost on a realistic fixture and breaks
# the cold start down per part, so the lazy-loading / server-mode
# decision is made on numbers.
#
# Cases (fixture: word-template-apa-style-paper.docx, 640 KB real
# Word output — 21 paragraphs, 78 KB styles.xml, 44 KB document.xml,
# headers/footnotes/glossary):
#
#   Verb loop (N sequential full verbs, uninstrumented):
#     * open             — Uniword::DocumentFactory.from_file only
#     * read_verb        — open + body run-text scan (`info` shape)
#     * find_replace     — open + FindReplace(:all) + save to temp
#
#   Cold-start decomposition (phases of one open, uninstrumented):
#     * zip_extract      — Infrastructure::ZipExtractor#extract
#     * package_open     — Docx::Package.from_file
#     * document_copy    — copy_package_parts_to_document
#     * factory_open     — Uniword::DocumentFactory.from_file (total)
#     * engine_parse_all — raw engine parse of every XML entry (floor)
#
#   Per-part hydration (instrumented loader wrappers, report table):
#     CPU per part key + hit count, and which parts dominate
#     Package.from_file. Plus a document.xml / +settings+styles /
#     all-parts ladder from the extracted entries.
#
# Recorded results (2026-10-31, ruby 3.4.8, lutaml-model 0.8.149,
# uniword 1.7.1, N=20, CPU medians):
#
#   open 0.473s | read_verb 0.451s | find_replace 1.138s
#   zip_extract 0.003s | package_open 0.438s | factory_open 0.479s
#   engine_parse_all 0.003s  (hydration ≈ 160x the raw parse floor)
#
#   per part: document 225ms (49%) | styles 163ms (36%) |
#   header 18ms | numbering 15ms | web_settings 11ms |
#   theme 9ms | 22 further keys < 9ms each
#
#   ladder: document only 0.204s | +settings+styles 0.365s |
#   all parts 0.395s
#
# Conclusion that drove issue #81's decision: all 28 part kinds are
# hydrated but a body-only read verb needs document.xml alone
# (ladder 0.204s vs 0.473s — up to ~53% off a read verb). The win is
# unreachable within the project constraints, though: save drops any
# part whose model is absent (28 -> 11 entries measured; settings/
# fontTable/webSettings are replaced with empty stubs), and the
# Reconciler touches every support-part model on every save — so for
# any verb that writes, lazy loading only moves the parse from open
# to save (0% net). And for #81's flagship case (a 600 KB
# document.xml, 4.4s CPU to hydrate) the win is 0% because
# document.xml stays eager. ruby-prof puts the cost in lutaml-model's
# per-element attribute machinery (~46k cast calls per open), flat
# across parts. Recommendation: server mode (amortizes the ~1.1s
# boot+require and the hydration of resident documents), plus
# upstream lutaml-model parse work. See benchmark/performance.rb for
# the synthetic-corpus numbers.
#
# Usage:
#   bundle exec ruby benchmark/verb_loop.rb [--iterations N] [--json PATH]

require "fileutils"
require "json"
require "nokogiri"
require "optparse"
require "tmpdir"

require "uniword"

FIXTURE =
  File.expand_path("../spec/fixtures/word-template-apa-style-paper/" \
                   "word-template-apa-style-paper.docx", __dir__)

def rss_mb
  `ps -o rss= -p #{$$}`.to_i / 1024.0
end

def median(values)
  sorted = values.sort
  n = sorted.size
  return sorted[n / 2] if n.odd?

  (sorted[(n / 2) - 1] + sorted[n / 2]) / 2.0
end

# rubocop:disable-next Metrics/AbcSize
def summary_entry(times, cpus, allocs_total, rss_delta)
  {
    median_s: median(times).round(4),
    mean_s: (times.sum / times.size).round(4),
    min_s: times.min.round(4),
    max_s: times.max.round(4),
    cpu_median_s: median(cpus).round(4),
    cpu_mean_s: (cpus.sum / cpus.size).round(4),
    allocs_m: (allocs_total.to_f / times.size / 1_000_000).round(2),
    rss_delta_mb: rss_delta.round(1),
  }
end

def report_line(name, entry)
  format("  %-<name>16s wall=%<wall>.3fs cpu=%<cpu>.3fs " \
         "allocs=%<allocs>.2fM rss=%<rss>+.1fMB\n",
         name: name, wall: entry[:median_s], cpu: entry[:cpu_median_s],
         allocs: entry[:allocs_m], rss: entry[:rss_delta_mb])
end

# Wall time swings with neighbor load; CPU time is the primary
# comparison metric (see benchmark/performance.rb for rationale).
# rubocop:disable-next Metrics/AbcSize
def run_case(results, name, iterations)
  times = []
  cpus = []
  allocs_total = 0
  rss_before = rss_mb
  iterations.times do
    a0 = GC.stat(:total_allocated_objects)
    t0 = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    c0 = Process.clock_gettime(Process::CLOCK_PROCESS_CPUTIME_ID)
    result = yield
    c1 = Process.clock_gettime(Process::CLOCK_PROCESS_CPUTIME_ID)
    t1 = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    allocs_total += GC.stat(:total_allocated_objects) - a0
    times << (t1 - t0)
    cpus << (c1 - c0)
    raise "case #{name}: nil result" if result.nil?
  end
  entry = summary_entry(times, cpus, allocs_total, rss_mb - rss_before)
  results[:cases][name.to_s] = entry
  puts report_line(name, entry)
end

# The verb body of a typical read verb: walk body run texts (the
# `uniword info` / find-scan shape) and return a match count.
def body_text_scan(doc)
  needle = "the"
  count = 0
  doc.paragraphs.each do |paragraph|
    paragraph.runs.each do |run|
      text = run.text_string
      count += 1 if text&.downcase&.include?(needle)
    end
  end
  count
end

# The verb body of find-replace + save (CLI default scope :all).
def find_replace_verb(doc, out_path)
  matcher = Uniword::FindReplace::StringMatcher.new(pattern: "the",
                                                    replacement: "THE")
  Uniword::FindReplace::Engine.new(document: doc, matcher: matcher,
                                   scopes: :all).run
  doc.save(out_path)
end

# --- Instrumentation -------------------------------------------------

# Loader wrapper that accumulates per-part CPU + hit counts while
# delegating to the real strategy. Registered via
# PartLoader.register_loader for the breakdown phase only.
class TimedLoader
  def initialize(inner, ledger)
    @inner = inner
    @ledger = ledger
  end

  def load(context, definition)
    c0 = Process.clock_gettime(Process::CLOCK_PROCESS_CPUTIME_ID)
    @inner.load(context, definition)
    c1 = Process.clock_gettime(Process::CLOCK_PROCESS_CPUTIME_ID)
    row = (@ledger[definition.key] ||=
             { loader: definition.loader, cpu: 0.0, hits: 0 })
    row[:cpu] += c1 - c0
    row[:hits] += 1
  end
end

# Loader strategy keys registered by Docx::PartLoader.
LOADER_KEYS = %i[xml_model custom_xml header_footer chart image
                 embedding theme_media raw].freeze

def loader_strategies
  LOADER_KEYS.to_h { |key| [key, Uniword::Docx::PartLoader.loader_for(key)] }
end

def instrument_loaders!
  ledger = {}
  loader_strategies.each do |key, inner|
    Uniword::Docx::PartLoader.register_loader(key,
                                              TimedLoader.new(inner, ledger))
  end
  ledger
end

def restore_loaders!(originals)
  originals.each do |key, strategy|
    Uniword::Docx::PartLoader.register_loader(key, strategy)
  end
end

# --- Cold-start ladder -----------------------------------------------

# Hydrate only the named parts from extracted ZIP entries, in the
# registry load order, via each definition's own loader_model.
def hydrate_parts(zip_content, keys)
  keys.each do |key|
    definition = Uniword::Ooxml::PartRegistry.find_by_key(key)
    content = zip_content[definition.path]
    definition.loader_model.from_xml(content) if content
  end
  :ok
end

# Hydrate every registry-loadable part from extracted ZIP entries.
def hydrate_all_parts(zip_content)
  Uniword::Ooxml::PartRegistry.loadable.each_key do |definition|
    content = zip_content[definition.path]
    definition.loader_model.from_xml(content) if content
  end
  :ok
end

# --- Breakdown report -------------------------------------------------

# rubocop:disable-next Metrics/AbcSize, Metrics/MethodLength
def part_breakdown(ledger, package_cpu, iterations)
  rows = ledger.map do |key, row|
    { key: key, loader: row[:loader], hits: row[:hits],
      cpu_per_open_ms: (row[:cpu] / iterations * 1000).round(2) }
  end.sort_by { |r| -r[:cpu_per_open_ms] }
  total = rows.sum { |r| r[:cpu_per_open_ms] }
  puts format("  %-<key>22s %-<loader>14s %<hits>6s %<cpu>10s " \
              "%<share>7s",
              key: "part key", loader: "loader", hits: "hits",
              cpu: "cpu/open(ms)", share: "share")
  rows.each do |row|
    share = total.positive? ? 100.0 * row[:cpu_per_open_ms] / total : 0.0
    puts format("  %-<key>22s %-<loader>14s %<hits>6d %<cpu>10.2f " \
                "%<share>6.1f%%",
                key: row[:key], loader: row[:loader], hits: row[:hits],
                cpu: row[:cpu_per_open_ms], share: share)
  end
  puts format("  %-<key>22s %-<loader>14s %<hits>6s %<cpu>10.2f " \
              "%<share>5.1f%%  (Package.from_file %<pkg>.0fms)",
              key: "TOTAL", loader: "", hits: "", cpu: total, share: 100.0,
              pkg: package_cpu * 1000)
  rows
end

# ---------------------------------------------------------------------

iterations = 20
json_path = nil
OptionParser.new do |opts|
  opts.on("--iterations N", Integer) { |v| iterations = v }
  opts.on("--json PATH") { |v| json_path = v }
end.parse!

raise "fixture missing: #{FIXTURE}" unless File.exist?(FIXTURE)

puts format("fixture: %<size>.0f KB, iterations: %<iters>d",
            size: File.size(FIXTURE) / 1024.0, iters: iterations)
puts "versions: #{RUBY_DESCRIPTION}"
puts "lutaml-model #{Lutaml::Model::VERSION}, " \
     "uniword #{Uniword::VERSION}"

results = {
  ruby: RUBY_VERSION,
  yjit: defined?(RubyVM::YJIT) ? RubyVM::YJIT.enabled? : false,
  fixture: File.basename(FIXTURE),
  fixture_bytes: File.size(FIXTURE),
  iterations: iterations,
  cases: {},
}

# Warm-up (autoloads, method caches, gem loads are not the target).
Uniword::DocumentFactory.from_file(FIXTURE)

puts "\n== verb loop (N=#{iterations}) =="
run_case(results, :open, iterations) do
  Uniword::DocumentFactory.from_file(FIXTURE)
  :ok
end

run_case(results, :read_verb, iterations) do
  body_text_scan(Uniword::DocumentFactory.from_file(FIXTURE))
end

Dir.mktmpdir("uniword_verb_loop") do |dir|
  out_path = File.join(dir, "out.docx")
  run_case(results, :find_replace, iterations) do
    find_replace_verb(Uniword::DocumentFactory.from_file(FIXTURE), out_path)
  end
end

puts "\n== cold-start decomposition =="
run_case(results, :zip_extract, iterations) do
  Uniword::Infrastructure::ZipExtractor.new.extract(FIXTURE)
end

extracted = Uniword::Infrastructure::ZipExtractor.new.extract(FIXTURE)
run_case(results, :package_open, iterations) do
  Uniword::Docx::Package.from_zip_content(extracted)
  :ok
end

run_case(results, :document_copy, iterations) do
  package = Uniword::Docx::Package.from_zip_content(extracted)
  doc = package.document
  Uniword::DocumentFactory.copy_package_parts_to_document(package, doc)
  doc
end

run_case(results, :factory_open, iterations) do
  Uniword::DocumentFactory.from_file(FIXTURE)
  :ok
end

run_case(results, :engine_parse_all, iterations) do
  extracted.each_value { |content| Nokogiri::XML(content) if content.is_a?(String) }
  :ok
end

puts "\n== per-part hydration (instrumented, N=#{iterations}) =="
originals = loader_strategies
ledger = instrument_loaders!
package_cpu = 0.0
iterations.times do
  c0 = Process.clock_gettime(Process::CLOCK_PROCESS_CPUTIME_ID)
  Uniword::Docx::Package.from_zip_content(extracted)
  package_cpu += Process.clock_gettime(Process::CLOCK_PROCESS_CPUTIME_ID) - c0
end
restore_loaders!(originals)
package_cpu /= iterations
rows = part_breakdown(ledger, package_cpu, iterations)
results[:part_breakdown] = rows
results[:package_open_cpu_s] = package_cpu.round(4)

puts "\n== hydration ladder (which parts are needed?) =="
ladder = {
  document_only: -> { hydrate_parts(extracted, [:document]) },
  plus_settings_styles:
    -> { hydrate_parts(extracted, %i[document settings styles]) },
  all_parts: -> { hydrate_all_parts(extracted) },
}
ladder.each do |label, hydrate|
  results[:ladder_parts] ||= {}
  results[:ladder_parts][label.to_s] = true
  run_case(results, :"ladder_#{label}", iterations) { hydrate.call }
end

File.write(json_path, JSON.pretty_generate(results)) if json_path
