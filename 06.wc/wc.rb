#!/usr/bin/env ruby

# frozen_string_literal: true

require 'optparse'
require_relative 'wc_command'

# オプション
options = {}
optparse = OptionParser.new do |opts|
  opts.on('-l', '--lines', 'count text’s lines') { options[:l] = true }
end

optparse.parse!(ARGV)

texts = []

if ARGV == []
  input = readlines.join
  texts << [input, ' ']
else
  ARGV.map do |arg|
    if FileTest.file?(arg)
      texts << [File.read(arg), arg]
    else
      wc = WordCount.new
      wc.print_error_message(arg)

      texts << ['', '', '']
    end
  end
end

wc_command(texts, options)
