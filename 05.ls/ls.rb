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
    show_file_information(Dir.pwd, option)
  else
    directories, files = separate_directories_or_files(ARGV)

    show_file_information(files, option) unless files.empty?

    unless directories.empty?
      print "\n" unless files.empty?
      print_directories_detail(directories, option, files.empty?)
    end
  end
end

def show_file_information(files_or_directories, opts)
  if opts[:l]
    file_detail = DetailedFormatter.new
    file_detail.output(files_or_directories, opts)
  else
    file = SimpleFormatter.new
    file.output(files_or_directories, opts)
  end
end

def separate_directories_or_files(argv)
  directories = []
  files = []

  argv.each do |arg|
    if FileTest.directory?(arg)
      directories << arg
    elsif FileTest.file?(arg)
      files << arg
    else
      puts "ls: #{arg}: No such file or directory"
    end
  end

  [directories, files]
end

def print_directories_detail(directories, option, files_empty)
  directories.sort.each_with_index do |dir, i|
    print "\n" unless i.zero?
    puts "#{dir}:" if directories.count > 1 || files_empty == false
    show_file_information(dir, option)
  end
end

main
