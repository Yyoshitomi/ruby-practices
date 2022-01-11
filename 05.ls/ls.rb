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
    print_files_or_directory_information(Dir.pwd, option)
  else
    directories, files = separate_directories_or_files(ARGV)

    print_files_or_directory_information(files, option) unless files.empty?
    print "\n" unless files.empty? || directories.empty?

    unless directories.empty?
      sorted_directories = option[:r] ? directories.sort.reverse : directories.sort
      sorted_directories.each_with_index do |dir, i|
        puts "#{dir}:" if !files.empty? || sorted_directories.count > 1
        print_files_or_directory_information(dir, option)

        break if i == sorted_directories.length - 1

        print "\n"
      end
    end
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

def print_files_or_directory_information(files_or_directory, opts)
  if FileTest.directory?(files_or_directory[0])
    directory = "#{File.expand_path(files_or_directory)}/*"
    files = opts[:a] ? Dir.glob(directory, File::FNM_DOTMATCH) : Dir.glob(directory)
  else
    files = files_or_directory
    files.reject! { |file| File.basename(file).start_with?('.') } if opts[:a].nil?
  end

  return if files.empty?

  sorted_files = opts[:r] ? files.sort.reverse : files.sort

  if opts[:l]
    file_info = DetailedFormatter.new
    file_info.output(sorted_files, directory.nil?)
  else
    sorted_files.map! { |file| File.basename(file) } if directory
    file_info = SimpleFormatter.new
    file_info.output(sorted_files)
  end
end

main
