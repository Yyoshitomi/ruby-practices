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
    files = []
    directories = [Dir.pwd]
  else
    error_argv, files, directories = separate_directories_or_files(ARGV)
    error_argv.sort.each { |arg| puts "ls: #{arg}: No such file or directory" }
  end

  file_groups = []
  file_groups << { directory: nil, files: sort(files, option) } unless files.empty?
  sort(directories, option).each { |dir| file_groups << open_directory(dir, option) }

  output_files(file_groups, option[:l] ? DetailedFormatter.new : SimpleFormatter.new)
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

def sort(target, option)
  option[:r] ? target.sort.reverse : target.sort
end

def open_directory(dir, option)
  pattern = "#{File.expand_path(dir)}/*"
  flags = option[:a] ? File::FNM_DOTMATCH : 0
  opened_directory = Dir.glob(pattern, flags).map { |file| option[:l] ? file : File.basename(file) }

  { directory: dir, files: sort(opened_directory, option) }
end

def output_files(file_groups, formatter)
  count = file_groups.count
  file_groups.each_with_index do |file_group, i|
    print "#{file_group[:directory]}:\n" if count > 1 && !file_group[:directory].nil?

    formatter.output(file_group) unless file_group[:files].nil?

    print "\n" unless i == count - 1
  end
end

main
