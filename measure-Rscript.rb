#!/usr/bin/env ruby

require 'fileutils'

BASE_PATH = "/home/jakob/Desktop/"
STATISTICS_PATH = "#{BASE_PATH}/rir-rebench-scripts/statistics"
RSCRIPT_PATH = "#{BASE_PATH}/rir/build/measure/bin/Rscript"

name = ARGV[0]
command = "#{RSCRIPT_PATH} #{ARGV.join(" ")} > /dev/null"
outPath = "#{STATISTICS_PATH}/#{name}"

print "running #{name} - #{command} ... "
system({"ENABLE_EVENT_COUNTERS" => "1"}, command)

print "moving output ... "
if File.exist?(outPath) then
  FileUtils.rm_rf(outPath)
end
Dir.mkdir(outPath)
File.rename("./events.csv", "#{outPath}/events.csv")
File.rename("./code_events.csv", "#{outPath}/code_events.csv")
File.rename("./num_closures_per_table.csv", "#{outPath}/num_closures_per_table.csv")

puts "done"
