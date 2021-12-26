# frozen_string_literal: true

require_relative 'file_sortable'

class SimpleFormatter
  include FileSortable

  def output(files, opts)
    files = sort_files(files, opts)
    max_length = files.max_by(&:length).length + 2
    file_count = files.count
    col = 3
    max_size_divider = (`tput cols`.to_i / max_length)
    col_count = max_size_divider > col ? col : max_size_divider

    display_rows(files, max_length, file_count, col_count, col)
  end

  private

  def display_row(files, len)
    files.each do |file|
      file_name = file&.ljust(len, ' ')
      print file_name
    end

    print "\n"
  end

  def display_rows(files, max_length, file_count, col_count, col)
    row_count = (file_count.to_f / col_count).ceil
    rows = files.each_slice(row_count).to_a

    if col > rows[0].size && col > rows.size
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
