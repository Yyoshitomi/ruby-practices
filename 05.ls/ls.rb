#!/usr/bin/env ruby

# frozen_string_literal: true

require 'optparse'
require 'etc'
require_relative 'format_files'

def exists_opt_long(files, opts)
  if opts[:l]
    file_info = PrintFileInfo.new
    file_info.output(files, opts)
  else
    file = PrintFile.new
    file.output(files, opts)
  end
end

# オプション
option = {}
optparse = OptionParser.new do |opts|
  opts.on('-a', '--all', 'output all files') { option[:a] = true }
  opts.on('-l', '--long', 'also outputs file information') { option[:l] = true }
  opts.on('-r', '--reverse', 'output files in reverse order') { option[:r] = true }
end

optparse.parse!(ARGV)

# 指定されたディレクトリを呼ぶ
# ディレクトリの指定がなければカレントディレクトリを呼ぶ
if ARGV == []
  exists_opt_long(Dir.pwd, option)
else
  directories = []
  files = []

  ARGV.map do |arg|
    if FileTest.directory?(arg)
      directories << arg
    elsif FileTest.file?(arg)
      files << arg
    else
      puts "ls: #{arg}: No such file or directory"
    end
  end

  exists_opt_long(files, option) if files != []

  if directories != []
    directories.sort.each_with_index do |dir, i|
      print "\n" if files != []

      if (i >= 1) || (files != [])
        print "\n" if i >= 1
        puts "#{dir}:"
      end

      exists_opt_long(dir, option)
    end
  end
end
