#!/usr/bin/env ruby
# sync_dates.rb
#
# Shifts all assignment assigned/due dates in _lab/, _pa/, and _lp/ by the
# difference between start_date and dates_based_on in _config.yml.
#
# Usage:
#   ruby sync_dates.rb           # apply changes
#   ruby sync_dates.rb --dry-run # preview without writing
#
# After running, dates_based_on in _config.yml is updated to equal start_date,
# so re-running is safe (offset becomes zero and nothing changes).

require 'yaml'
require 'date'

DRY_RUN    = ARGV.include?('--dry-run')
SCRIPT_DIR = File.dirname(File.expand_path(__FILE__))
CONFIG_PATH = File.join(SCRIPT_DIR, '_config.yml')

config = YAML.load_file(CONFIG_PATH, permitted_classes: [Date, Symbol])

target_start = Date.parse(config['start_date'].to_s)
source_start = Date.parse(config['dates_based_on'].to_s)
offset = target_start - source_start   # days to shift (Rational, treated as integer)

quarter = config['quarter'] || config['qtr'] || 'course'
puts "=== Date sync — #{quarter} ==="
puts "(dry run)\n\n" if DRY_RUN
puts "  dates_based_on : #{source_start}"
puts "  start_date     : #{target_start}"
puts "  offset         : #{offset.to_i} days\n\n"

if offset == 0
  puts "Offset is zero — dates are already aligned with start_date. Nothing to do."
  exit 0
end

# Regex to capture the full date field with time and timezone, e.g.:
#   assigned: 2026-01-05 09:00:00.00-08:00
DATE_FIELD_RE = /^(assigned|due): (\d{4}-\d{2}-\d{2})( .+)?$/

dirs = %w[_lab _pa _lp].map { |d| File.join(SCRIPT_DIR, d) }
files = dirs.flat_map { |d| Dir.glob(File.join(d, '*.md')) }.sort

changed = 0
files.each do |path|
  content = File.read(path)

  # Only process front matter (between the first two --- markers)
  parts = content.split(/^---\s*$/, 3)
  next if parts.size < 3  # no valid front matter

  _, fm, body = parts
  new_fm = fm.gsub(DATE_FIELD_RE) do
    field    = $1
    old_date = Date.parse($2)
    rest     = $3 || ''
    new_date = old_date + offset.to_i
    "#{field}: #{new_date}#{rest}"
  end

  next if new_fm == fm   # nothing changed in this file

  new_content = "---\n#{new_fm}---\n#{body}"
  rel = path.sub(SCRIPT_DIR + '/', '')

  # Show what changed
  fm.scan(DATE_FIELD_RE).each do |field, date_str, rest|
    new_date = Date.parse(date_str) + offset.to_i
    puts "  #{File.basename(path)}  #{field}: #{date_str} → #{new_date}"
  end

  File.write(path, new_content) unless DRY_RUN
  changed += 1
end

puts ""
if changed == 0
  puts "No date fields found to update."
else
  puts "#{DRY_RUN ? 'Would update' : 'Updated'} #{changed} file(s)."
end

# Update dates_based_on in _config.yml to reflect new state
unless DRY_RUN
  config_text = File.read(CONFIG_PATH)
  new_config_text = config_text.sub(
    /^dates_based_on:.*$/,
    "dates_based_on: #{target_start}   # Assignment dates currently use this quarter's start; updated by sync_dates.rb"
  )
  if new_config_text != config_text
    File.write(CONFIG_PATH, new_config_text)
    puts "Updated dates_based_on in _config.yml to #{target_start}."
  end
end

puts "\nDone#{DRY_RUN ? ' (dry run — no files written)' : ''}."
