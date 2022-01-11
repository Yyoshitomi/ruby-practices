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

  if ARGV.empty?
    # ディレクトリやファイルの指定がなければカレントディレクトリからファイル一覧を取得する
    show_file_information(Dir.entries('.'), option)
  else
    directories, files = separate_directories_or_files(ARGV)

    show_file_information(files, option) unless files.empty?
    print "\n" unless files.empty? || directories.empty?
    print_directories_detail(directories, option, files.empty?) unless directories.empty?
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
  sorted_directories = option[:r] ? directories.sort.reverse : directories.sort
  sorted_directories.each_with_index do |dir, i|
    puts "#{dir}:" if !files_empty || sorted_directories.count > 1
    show_file_information(Dir.entries(dir), option, dir)

    break if i == sorted_directories.length - 1

    print "\n"
  end
end

def show_file_information(files, opts, dirname = nil)
  sorted_files = sort_files(files, opts)

  # 表示するファイルが存在しない場合は表示しない
  return if sorted_files.empty?

  if opts[:l]
    file_detail = DetailedFormatter.new
    file_detail.output(sorted_files, dirname)
  else
    file = SimpleFormatter.new
    file.output(sorted_files)
  end
end

def sort_files(files, opts)
  sorted_files = files.sort

  sorted_files.reject! { |file| File.basename(file).start_with?('.') } if opts[:a].nil?

  opts[:r] ? sorted_files.reverse : sorted_files
end

main
