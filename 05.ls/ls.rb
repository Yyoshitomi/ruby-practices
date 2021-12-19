#!/usr/bin/env ruby

# frozen_string_literal: true

require 'optparse'
require 'etc'
require_relative 'simple_formatter'
require_relative 'detailed_formatter'

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

    exists_opt_long(files, option)

    unless directories.empty?
      print "\n" unless files.empty?
      print_directories_detail(directories, option)
    end
  end
end

def exists_opt_long(files, opts)
  if opts[:l]
    file_detail = DetailedFormatter.new
    file_detail.output(files, opts)
  else
    file = SimpleFormatter.new
    file.output(files, opts)
  end
end

def separate_directories_or_files(argv, directories, files)
  argv.each do |arg|
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
    print "\n" unless i.zero?
    puts "#{dir}:"
    exists_opt_long(dir, option)
  end
end

main
