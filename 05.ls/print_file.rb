# frozen_string_literal: true

require_relative 'format_files'

class PrintFile
  def output(files, opts)
    sorted_files = sorted_files(files, opts)

    max_length = sorted_files.max_by(&:length).length + 2
    count = sorted_files.count
    col = 3
    col_count = (`tput cols`.to_i / max_length) > col ? col : (`tput cols`.to_i / max_length)

    if col_count >= count
      one_row(sorted_files, max_length)
    else
      split_screen = [max_length, count, col_count]
      multi_rows(sorted_files, split_screen)
    end
  end

  private

  def one_row(files, len)
    space = ' ' * 11

    files.each do |file|
      file_name = file.nil? ? space : file.ljust(len, ' ')
      print file_name
    end

    print "\n"
  end

  def multi_rows(files, split_screen)
    max_length = split_screen[0]
    count = split_screen[1]
    col_count = split_screen[2]

    row = (count.to_f / col_count).ceil

    export_files = []
    ary_row = files.each_slice(row).to_a

    # ary_row内の各配列を先頭から並び替える
    row.times do |n|
      col_count.times do |i|
        file = ary_row[i][n]
        export_files.push(file)

        break if ary_row[i + 1].nil?
      end
    end

    rows = export_files.each_slice(col_count).to_a
    rows.each { |line| one_row(line, max_length) }
  end
end
