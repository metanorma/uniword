# frozen_string_literal: true

# Deterministic performance benchmark for the uniword model stack.
#
# Generates a fixed synthetic corpus (~650 KB word/document.xml), then
# measures three cases on the current bundle:
#
#   * engine_parse    — raw Nokogiri parse of the corpus (reference floor)
#   * model_parse     — end-to-end hydration (DocumentRoot.from_xml);
#                       this is the number that matters for consumers
#   * model_serialize — DocumentRoot#to_xml
#
# Usage:
#   bundle exec ruby benchmark/performance.rb [--iterations N] [--json PATH]
#
# Output: per-case wall-time median / mean / min / max, RSS delta, and
# gem versions. Numbers are comparable across runs of the same runner
# class (CI: ubuntu-latest, pinned Ruby); absolute values are meaningless
# on a contended development machine.

require "json"
require "nokogiri"
require "optparse"

W_NS = "http://schemas.openxmlformats.org/wordprocessingml/2006/main"
W14_NS = "http://schemas.microsoft.com/office/word/2010/wordml"

def rss_mb
  `ps -o rss= -p #{$$}`.to_i / 1024.0
end

def median(values)
  sorted = values.sort
  n = sorted.size
  return sorted[n / 2] if n.odd?

  (sorted[(n / 2) - 1] + sorted[n / 2]) / 2.0
end

# Deterministic corpus in the shape of a WordprocessingML body:
# paragraphs with runs and properties, a table every 200 paragraphs,
# bookmark pairs every 50 paragraphs. Same content on every run.
def build_corpus(paragraphs: 4000)
  xml = "<w:document xmlns:w=\"#{W_NS}\" xmlns:w14=\"#{W14_NS}\">"
  xml << "<w:body>"
  paragraphs.times do |i|
    xml << "<w:p><w:pPr><w:pStyle w:val=\"Heading1\"/></w:pPr>" \
           "<w:r><w:rPr><w:b/><w:sz w:val=\"24\"/></w:rPr>" \
           "<w:t>Paragraph #{i} body text for the corpus</w:t></w:r></w:p>"
    if (i % 200).zero?
      xml << "<w:tbl><w:tr><w:tc><w:p><w:r><w:t>cell #{i}</w:t>" \
             "</w:r></w:p></w:tc></w:tr></w:tbl>"
    end
    if (i % 50).zero?
      xml << "<w:bookmarkStart w:id=\"#{i}\" w:name=\"_b#{i}\"/>"
      xml << "<w:bookmarkEnd w:id=\"#{i}\"/>"
    end
  end
  xml << "</w:body></w:document>"
  xml.freeze
end

def summary_entry(times, rss_delta)
  {
    median_s: median(times).round(4),
    mean_s: (times.sum / times.size).round(4),
    min_s: times.min.round(4),
    max_s: times.max.round(4),
    rss_delta_mb: rss_delta.round(1),
  }
end

def report_line(name, entry)
  format("  %-<name>16s median=%<median>.3fs mean=%<mean>.3fs " \
         "min=%<min>.3fs rss=%<rss>+.1fMB\n",
         name: name, median: entry[:median_s], mean: entry[:mean_s],
         min: entry[:min_s], rss: entry[:rss_delta_mb])
end

# rubocop:disable Metrics/AbcSize
def run_case(results, name, iterations)
  times = []
  rss_before = rss_mb
  iterations.times do
    t0 = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    result = yield
    times << (Process.clock_gettime(Process::CLOCK_MONOTONIC) - t0)
    raise "case #{name}: nil result" if result.nil?
  end
  entry = summary_entry(times, rss_mb - rss_before)
  results[:cases][name.to_s] = entry
  puts report_line(name, entry)
end
# rubocop:enable Metrics/AbcSize

iterations = 5
json_path = nil
OptionParser.new do |opts|
  opts.on("--iterations N", Integer) { |v| iterations = v }
  opts.on("--json PATH") { |v| json_path = v }
end.parse!

corpus = build_corpus
puts format("corpus: %<size>.1f KB, iterations: %<iters>d\n",
            size: corpus.bytesize / 1024.0, iters: iterations)
puts "versions: #{RUBY_DESCRIPTION}"

results = {
  ruby: RUBY_VERSION,
  corpus_bytes: corpus.bytesize,
  iterations: iterations,
  cases: {},
}

GC.start
run_case(results, :engine_parse, iterations) { Nokogiri::XML(corpus) }

require "uniword"
results[:lutaml_model] = Lutaml::Model::VERSION
GC.start
parsed = nil
run_case(results, :model_parse, iterations) do
  parsed = Uniword::Wordprocessingml::DocumentRoot.from_xml(corpus)
end

GC.start
run_case(results, :model_serialize, iterations) { parsed.to_xml }

File.write(json_path, JSON.pretty_generate(results)) if json_path
