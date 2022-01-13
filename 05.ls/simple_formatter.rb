# frozen_string_literal: true

require 'io/console'

class SimpleFormatter
  COL = 3

  def output(files)
    max_length = files.max_by(&:length).length + 2
    file_count = files.count
    max_size_divider = (IO.console.winsize[1] / max_length)
    col_count = max_size_divider > COL ? COL : max_size_divider

    display_rows(files, max_length, file_count, col_count)
  end

  private

  def display_row(files, length)
    files.each do |file|
      file_name = file&.ljust(length, ' ')
      print file_name
    end

    print "\n"
  end

  def display_rows(files, max_length, file_count, col_count)
    row_count = (file_count.to_f / col_count).ceil
    rows = files.each_slice(row_count).to_a
    status_display_just_for_line = files.count >= COL && COL > rows[0].size && COL > rows.size

    if status_display_just_for_line
      file = rows[0].pop
      exported_files = rows.flatten
      exported_files.push(file)
    else
      exported_files = []
      row_count.times do |row_idx|
        col_count.times do |col_idx|
          file = rows[col_idx][row_idx]
          exported_files.push(file)

          break if rows[col_idx + 1].nil?
        end
      end
    end

    file_table = exported_files.each_slice(col_count).to_a
    file_table.each { |line| display_row(line, max_length) }
  end
end
