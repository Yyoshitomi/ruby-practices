# frozen_string_literal: true

require_relative 'format_files'

class PrintFile
  def output(files, opts)
    max_length = sorted_files(files, opts).max_by(&:length).length + 2
    count = sorted_files(files, opts).count
    col = 3
    col_count = (`tput cols`.to_i / max_length) > col ? col : (`tput cols`.to_i / max_length)

    if col_count >= count
      display_row(sorted_files(files, opts), max_length)
    else
      count_info = [max_length, count, col_count]
      display_rows(sorted_files(files, opts), count_info)
    end
  end

  private

  def display_row(files, len)
    space = ' ' * 11

    files.each do |file|
      file_name = file.nil? ? space : file.ljust(len, ' ')
      print file_name
    end

    print "\n"
  end

  def display_rows(files, count_info)
    max_length = count_info[0]
    count = count_info[1]
    col_count = count_info[2]

    row_count = (count.to_f / col_count).ceil

    exported_files = []
    rows = files.each_slice(row_count).to_a

    # row内の各配列を先頭から並び替える
    row_count.times do |n|
      col_count.times do |i|
        file = rows[i][n]
        exported_files.push(file)

        break if rows[i + 1].nil?
      end
    end

    file_table = exported_files.each_slice(col_count).to_a
    file_table.each { |line| display_row(line, max_length) }
  end
end
