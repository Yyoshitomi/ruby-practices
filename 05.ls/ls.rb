#!/usr/bin/env ruby

# frozen_string_literal: true

require 'optparse'
require 'etc'
require_relative 'format_files'

def main
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
  if ARGV.empty?
    exists_opt_long(Dir.pwd, option)
  else
    directories = []
    files = []
    separate_directories_or_files(ARGV, directories, files)

    exists_opt_long(files, option) if files != []

    unless directories == []
      print "\n" unless files == []
      print_directories_detail(directories, option)
    end
  end
end

def exists_opt_long(files, opts)
  if opts[:l]
    file_detail = PrintFileDetail.new
    file_detail.output(files, opts)
  else
    file = PrintFile.new
    file.output(files, opts)
  end
end

def separate_directories_or_files(argv, directories, files)
  argv.map do |arg|
    if FileTest.directory?(arg)
      directories << arg
    elsif FileTest.file?(arg)
      files << arg
    else
      puts "ls: #{arg}: No such file or directory"
    end
  end
end

def print_directories_detail(directories, option)
  directories.sort.each_with_index do |dir, i|
    print_directories_name(dir) if i >= 1
    exists_opt_long(dir, option)
  end
end

def print_directories_name(dir)
  print "\n"
  puts "#{dir}:"
end

main
