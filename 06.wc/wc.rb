#!/usr/bin/env ruby

# frozen_string_literal: true

require 'optparse'

def main
  options = {}
  optparse = OptionParser.new { |opts| opts.on('-l', '--lines', 'count text’s lines') { options[:l] = true } }

  optparse.parse!(ARGV)

  ARGV == [] ? print_count(count(readlines.join, options)) : display_count_file(ARGV, options)
end

def display_count_file(argv, options)
  total_count = Array.new(options[:l] ? 1 : 3, 0)
  argv.each do |arg|
    if FileTest.file?(arg)
      current_count = total_count
      text_count = count(File.read(arg), options)
      print_count(text_count, arg)
      total_count = current_count.zip(text_count).map(&:sum) if argv.count > 1
    else
      print_error_message(arg)
    end
  end

  print_count(total_count, 'total') if argv.count > 1
end

def count(text, options)
  text_count = [text.split(/\R/).size]
  text_count += [text.split(/\s+/).size, text.bytesize] unless options[:l]

  text_count
end

def print_count(text_count, name = nil)
  puts "#{text_count.map { |c| c.to_s.rjust(8, ' ') }.join} #{name}"
end

def print_error_message(arg)
  messege = FileTest.directory?(arg) ? 'read: Is a directory' : 'open: No such file or directory'
  puts "wc: #{arg}: #{messege}"
end

main
