# frozen_string_literal: true

require 'io/console'

class SimpleFormatter
  COL = 3

  def output(file_group)
    max_length = file_group[:files].max_by(&:length).length + 2

    max_size_divider = IO.console.winsize[1] / max_length
    col_count = max_size_divider > COL ? COL : max_size_divider
    row_count = (file_group[:files].count.to_f / col_count).ceil

    cols = file_group[:files].each_slice(row_count).to_a
    cols[0].zip(*cols[1..-1]).each do |row|
      row.each { |file| print file&.ljust(max_length, ' ') }
      print "\n"
    end
  end
end
