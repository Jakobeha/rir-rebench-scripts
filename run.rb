#!/usr/bin/env ruby

BENCHMARKS_PATH = "rbenchmarking/Benchmarks"
RIR_PATH = "/Users/Jakob/Desktop/Projects/rir"
override = (ENV['OVERRIDE'] || "0") != "0"

puts "setting up branches"
Dir.chdir("#{RIR_PATH}/build/benchmarks") do
  ARGV.each do |branch|
    print "- #{branch} ... "
    if File.exist?("#{branch}/bin/R") && !override then
      print "(already setup, set OVERRIDE=1 to remove) "
    else
      if !File.exist?(branch) then
        Dir.mkdir branch
      end
      Dir.chdir("#{RIR_PATH}/build/benchmarks/#{branch}") do
        puts ""
        res = system "git checkout #{branch} > /dev/null"
        if !res then
          abort "ERROR could not checkout"
        end
        res = system "cmake ../../../ -DCMAKE_BUILD_TYPE=release -GNinja -DFORCE_COLORED_OUTPUT=true > /dev/null && ninja"
        if !res then
          abort "ERROR could not build"
        end
        res = system "FAST_TESTS=1 ./bin/tests"
        if !res then
          abort "ERROR branch failed basic tests"
        end
        print "> #{branch} "
      end
    end
    puts "done"
  end
end

puts "setting up rebench scripts"
ARGV.each do |branch|
  print "- #{branch} ... "
  data = File.read("template.conf")
  data = data.gsub("%BENCHMARKS_PATH%", BENCHMARKS_PATH).gsub("%RIR_PATH%", RIR_PATH).gsub("%BRANCH%", branch)
  File.open("#{branch}.conf", "w") do |file|
    file.write(data)
  end
  if File.exist?("#{branch}.data") then
    File.delete("#{branch}.data")
  end
  puts "done"
end

puts "running benchmarks"
ARGV.each do |branch|
  puts "- #{branch} ... "
  res = system "rebench #{branch}.conf -c"
  if !res then
    abort "ERROR rebench failed"
  end
  puts "> #{branch} done"
end

puts "RESULTS"
ARGV.each_with_index do |branch1, idx1|
  ARGV.each_with_index do |branch2, idx2|
    if (idx1 < idx2) then
      puts "- #{branch1} vs #{branch2}"
      system "./diff.rb #{branch1}.data #{branch2}.data"
    end
  end
end
puts "run './diff.rb {branch1}.data {branch2}.data' to view specific results"
