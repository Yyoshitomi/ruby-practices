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

  if ARGV.empty?
    # ディレクトリやファイルの指定がなければカレントディレクトリからファイル一覧を取得する
    print_directories([Dir.pwd], option, true)
  else
    error_argv, files, directories = separate_directories_or_files(ARGV)

    error_argv.sort.each { |arg| puts "ls: #{arg}: No such file or directory" } unless error_argv.empty?
    print_files_information(files, false, option)
    print "\n" unless files.empty? || directories.empty?
    print_directories(directories, option, files.empty?)
  end
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

def print_directories(directories, option, files_empty)
  sorted_directories = option[:r] ? directories.sort.reverse : directories.sort
  sorted_directories.each do |dir|
    # ファイルとディレクトリ、ディレクトリ複数を指定された場合はディレクトリ名を表示する
    puts "#{dir}:" if !files_empty || sorted_directories.count > 1

    pattern = "#{File.expand_path(dir)}/*"
    opened_files = option[:a] ? Dir.glob(pattern, File::FNM_DOTMATCH) : Dir.glob(pattern)

    print_files_information(opened_files, true, option)
    # 複数ディレクトリが指定された場合は、次のディレクトリとの間に改行を挿入する
    print "\n" unless dir == sorted_directories.last
  end
end

def print_files_information(files, directory_exists, option)
  # ファイル一覧が空の場合は何もせず、
  # 複数ディレクトリ指定時はprint_directoriesでディレクトリ名のみ表示
  return if files.empty?

  sorted_files = option[:r] ? files.sort.reverse : files.sort

  if option[:l]
    formatter = DetailedFormatter.new
    formatter.output(sorted_files, directory_exists)
  else
    sorted_files.map! { |file| File.basename(file) } if directory_exists
    formatter = SimpleFormatter.new
    formatter.output(sorted_files)
  end
end

main
