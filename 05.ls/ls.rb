#!/usr/bin/env ruby

# frozen_string_literal: true

require 'optparse'
require 'etc'
require_relative 'simple_formatter'
require_relative 'detailed_formatter'

def main
  option = {}
  optparse = OptionParser.new do |opts|
    opts.on('-a', '--all', 'output all files') { option[:a] = true }
    opts.on('-l', '--long', 'also outputs file information') { option[:l] = true }
    opts.on('-r', '--reverse', 'output files in reverse order') { option[:r] = true }
  end

  optparse.parse!(ARGV)

  files_list = []
  if ARGV.empty?
    # ディレクトリやファイルの指定がなければカレントディレクトリからファイル一覧を取得する
    sort_directories([Dir.pwd], option, files_list)
  else
    error_argv, files, directories = separate_directories_or_files(ARGV)

    error_argv.sort.each { |arg| puts "ls: #{arg}: No such file or directory" } unless error_argv.empty?

    files_list << { directory: nil, files: files } unless files.empty?
    sort_directories(directories, option, files_list)
  end

  formatter = option[:l] ? DetailedFormatter.new : SimpleFormatter.new
  formatter.output(files_list, option)
end

def separate_directories_or_files(argv)
  directories = []
  files = []
  error_argv = []

  argv.each do |arg|
    if FileTest.directory?(arg)
      directories << arg
    elsif FileTest.file?(arg)
      files << arg
    else
      error_argv << arg
    end
  end

  [error_argv, files, directories]
end

def sort_directories(directories, option, files_list)
  sorted_directories = option[:r] ? directories.sort.reverse : directories.sort
  sorted_directories.each do |dir|
    pattern = "#{File.expand_path(dir)}/*"
    opened_files = option[:a] ? Dir.glob(pattern, File::FNM_DOTMATCH) : Dir.glob(pattern)

    files_list << { directory: "#{dir}:\n", files: opened_files }
  end
end

main
