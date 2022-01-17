# frozen_string_literal: true

require 'io/console'

class SimpleFormatter
  COL = 3

  def output(file_groups, option)
    max_length = build_max_length(file_groups)
    file_groups.each do |file_group|
      print_dirname(file_group[:directory], file_groups) do
        next if file_group[:files].empty?

        file_group[:files].map! { |file| File.basename(file) } unless file_group[:directory].nil?

        max_size_divider = (IO.console.winsize[1] / max_length)
        col_count = max_size_divider > COL ? COL : max_size_divider

        sorted_files = option[:r] ? file_group[:files].sort.reverse : file_group[:files].sort
        display_rows(sorted_files, max_length, col_count)
      end
    end
  end

  private

  def build_max_length(file_groups)
    max_length = 0
    file_groups.each do |file_group|
      next if file_group[:files].empty?

      fname_list = file_group[:directory].nil? ? file_group[:files] : file_group[:files].map { |file| File.basename(file) }
      fname_max_length = fname_list.max_by(&:length).length + 2
      max_length = max_length > fname_max_length ? max_length : fname_max_length
    end

    max_length
  end

  def print_dirname(dirname, file_groups)
    puts dirname if file_groups.count > 1 && !dirname.nil?

    yield

    print "\n" unless dirname == file_groups.last[:directory]
  end

  def display_row(files, length)
    files.each do |file|
      file_name = file&.ljust(length, ' ')
      print file_name
    end

    print "\n"
  end

  def display_rows(files, max_length, col_count)
    row_count = (files.count.to_f / col_count).ceil

    if row_count == 1
      exported_files = files
    else
      exported_files = []

      cols = make_cols(col_count, files)
      row_count.times do |row_idx|
        cols.each { |col| exported_files.push(col[row_idx]) }
      end
    end

    file_table = exported_files.each_slice(col_count).to_a
    file_table.each { |line| display_row(line, max_length) }
  end

  # in_groupsメソッドを参考
  # https://github.com/rails/rails/blob/fbe2433be6e052a1acac63c7faf287c52ed3c5ba/activesupport/lib/active_support/core_ext/array/grouping.rb#L62-L86
  # in_groupsメソッドでは指定数分に配列をできるだけ均等に分割するが、
  # 1 4 6
  # 2 5 7
  # 3
  # lsコマンドでは右側から敷き詰めてファイル名を表示するのでファイルの残数を考慮して配列のサイズを計算する
  # 1 4 7
  # 2 5
  # 3 6
  def make_cols(col_count, files)
    files_count = files.count
    division = files_count / col_count
    modulo = files_count % col_count

    col_array = []
    start = 0

    pre_length = 0
    left_over = 0

    col_count.times do |i|
      length = division + (modulo.positive? && modulo > i ? 1 : 0)
      length += pre_length > length && left_over > pre_length ? 1 : 0

      col_array << files.slice(start, length)

      start += length
      pre_length = length
      left_over = files_count - start
    end

    col_array
  end
end
