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
    count_word(readlines.join, ' ', options)
  else
    display_count(ARGV, options)
  end
end

def display_count(argv, options)
  total_lines = 0
  total_words = 0
  total_bytes = 0

  argv.map do |arg|
    if FileTest.file?(arg)
      lines, words, bytes = count_word(File.read(arg), arg, options)

      total_lines += lines
      total_words += words
      total_bytes += bytes
    else
      print_error_message(arg)

      next
    end
  end

  return unless argv.any? { |arg| FileTest.file?(arg) }

  total_count = options[:l] ? [total_lines] : [total_lines, total_words, total_bytes]
  print_total_count(total_count)
end

def count_word(text, file_name, options)
  lines = text.split(/\R/).size
  words = text.split(/\s+/).size
  bytes = text.bytesize

  text_count = options[:l] ? [lines] : [lines, words, bytes]
  print_count(text_count)
  print_name(file_name)

  [lines, words, bytes]
end

def print_count(text_count)
  text_count.each { |count| print count.to_s.rjust(8, ' ') }
end

def print_name(name)
  print " #{name}\n"
end

def print_total_count(total_count)
  print_count(total_count)
  print_name('total')
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
