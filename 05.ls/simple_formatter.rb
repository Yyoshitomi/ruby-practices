# frozen_string_literal: true

require 'io/console'

class SimpleFormatter
  COL = 3

  def output(files)
    max_length = files.max_by(&:length).length + 2
    max_size_divider = (IO.console.winsize[1] / max_length)
    col_count = max_size_divider > COL ? COL : max_size_divider

    display_rows(files, max_length, col_count)
  end

  private

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
  def make_cols(col_count, files)
    division = files.count / col_count
    modulo = files.count % col_count

    col_array = []
    start = 0
    pre_length = 0
    left_over = 0
    col_count.times do |i|
      length = division + (modulo.positive? && modulo > i ? 1 : 0)
      length += (left_over > pre_length && pre_length > length ? 1 : 0)

      col_array << files.slice(start, length)

      start += length
      pre_length = length
      left_over = (files.count - start)
    end

    col_array
  end
end
