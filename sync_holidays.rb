#!/usr/bin/env ruby
# sync_holidays.rb
#
# Reads _config.yml and creates/updates holiday placeholder files in _lectures/.
# Files are named lect{N}a.md (or b, c, ...) where N is the count of actual
# lectures that occur *before* the holiday in the schedule.
#
# Usage:
#   ruby sync_holidays.rb           # apply changes
#   ruby sync_holidays.rb --dry-run # preview without writing

require 'yaml'
require 'date'

DRY_RUN      = ARGV.include?('--dry-run')
SCRIPT_DIR   = File.dirname(File.expand_path(__FILE__))
LECTURES_DIR = File.join(SCRIPT_DIR, '_lectures')
CONFIG_PATH  = File.join(SCRIPT_DIR, '_config.yml')

config = YAML.load_file(CONFIG_PATH, permitted_classes: [Date, Symbol])

start_date    = Date.parse(config['start_date'].to_s)
lecture_days  = config['lecture_days']               # [1,3] → Mon=1, Wed=3 (ISO cwday)
num_weeks     = (config['num_weeks'] || 10).to_i
extra_week    = config['extra_exam_week'] ? 1 : 0
holidays_cfg  = config['holidays'] || []

# Build a hash of  Date → description  for quick lookup
holidays = holidays_cfg.each_with_object({}) do |h, acc|
  acc[Date.parse(h['date'].to_s)] = h['desc']
end

# Walk every calendar day from start_date through the end of the term.
# For each Mon/Wed slot, either increment the lecture counter (real lecture)
# or record a holiday entry.
lecture_count  = 0
suffix_counts  = Hash.new(0)   # lecture_count → how many holidays already seen after it
computed       = []            # [{date:, desc:, file_name:}]

end_date = start_date + (num_weeks + extra_week + 1) * 7
current  = start_date

while current <= end_date
  if lecture_days.include?(current.cwday)
    if holidays.key?(current)
      suffix    = ('a'.ord + suffix_counts[lecture_count]).chr
      file_name = format('lect%02d%s.md', lecture_count, suffix)
      suffix_counts[lecture_count] += 1
      computed << { date: current, desc: holidays[current], file_name: file_name }
    else
      lecture_count += 1
    end
  end
  current += 1
end

# Find holiday files already present in _lectures/ (pattern: lect##x.md)
existing = Dir.glob(File.join(LECTURES_DIR, 'lect[0-9][0-9][a-z].md'))
              .map { |f| File.basename(f) }

quarter = config['quarter'] || config['qtr'] || 'course'
puts "=== Holiday sync — #{quarter} ==="
puts "(dry run)\n\n" if DRY_RUN
puts "Holidays from _config.yml:"
computed.each { |h| puts "  %-18s %s  (%s)" % [h[:file_name], h[:date], h[:desc]] }
puts ""

# Stale files: exist on disk but not in the computed list
stale = existing - computed.map { |h| h[:file_name] }
if stale.any?
  puts "Stale holiday files (no longer in _config.yml holidays):"
  stale.each { |f| puts "  _lectures/#{f}" }
  puts "  → Remove these manually if they are no longer needed.\n\n"
end

# Create or update each computed holiday file
puts "Actions:"
computed.each do |h|
  path    = File.join(LECTURES_DIR, h[:file_name])
  content = <<~FRONT
    ---
    num: ""
    lecture_date: #{h[:date]}
    desc: "No lecture - #{h[:desc]}"
    ready: false
    pre-reading: ""
    ---
  FRONT

  if File.exist?(path)
    if File.read(path) == content
      puts "  #{h[:file_name]}  (no change)"
    else
      puts "  #{h[:file_name]}  (updated)"
      File.write(path, content) unless DRY_RUN
    end
  else
    puts "  #{h[:file_name]}  (created)"
    File.write(path, content) unless DRY_RUN
  end
end

puts "\nDone#{DRY_RUN ? ' (dry run — no files written)' : ''}."
