#!/usr/bin/env ruby

# frozen_string_literal: true

require 'optparse'

def main
  options = {}
  optparse = OptionParser.new do |opts|
    opts.on('-l', '--lines', 'count text’s lines') { options[:l] = true }
  end

  optparse.parse!(ARGV)

  if ARGV == []
    print_count count(readlines.join, options)
  else
    display_count_file(ARGV, options)
  end
end

def display_count_file(argv, options)
  total_count = []
  argv.each do |arg|
    if FileTest.file?(arg)
      count = count(File.read(arg), options)
      print_count(count, arg)
      total_count << count
    else
      print_error_message(arg)
    end
  end

  return if total_count.empty?

  print_count total_count.transpose.map { |c| c.inject(:+) }, 'total'
end

def count(text, options)
  lines = text.split(/\R/).size
  words = text.split(/\s+/).size
  bytes = text.bytesize

  options[:l] ? [lines] : [lines, words, bytes]
end

def print_count(text_count, name = nil)
  text_count.each { |count| print count.to_s.rjust(8, ' ') }
  puts " #{name}"
end

def print_error_message(arg)
  error_messege = if FileTest.directory?(arg)
                    'read: Is a directory'
                  else
                    'open: No such file or directory'
                  end
  puts "wc: #{arg}: #{error_messege}"
end

main
