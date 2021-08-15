# frozen_string_literal: true

require_relative 'fomat_files'

class Files
  def output(files, opts)
    sorted_files = sorted_files(files, opts)

    # ファイル名が一番長いファイル名の長さ確認 & 整形
    max_length = sorted_files.max_by(&:length).length + 2
    # ファイル数を計算
    count = sorted_files.count
    col = 3
    # ターミナル画面のサイズを一番長いファイル名で割って列を計算
    # col_count = `tput cols`.to_i / max_length
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
    # files.each { |f| print f.ljust(len, ' ') }
    space = ' ' * 11

    files.each do |f|
      file = f.nil? ? space : f.ljust(len, ' ')
      print file
    end

    print "\n"
  end

  def multi_rows(files, split_screen)
    max_length = split_screen[0]
    count = split_screen[1]
    col_count = split_screen[2]

    # ファイル数を列で割って行数を計算
    row = (count.to_f / col_count).ceil

    # 行頭が[1,4,7,10]にするための配列を作成
    export_files = []
    # ary.firstが[1,4,7,10]になるようにスライス
    ary_row = files.each_slice(row).to_a

    # ary_row内の各配列を先頭から並び替える
    row.times do |n|
      # ary_row.each do |ary|
      #   file = ary[n]
      #   export_files.push(file) unless file.nil? # nilは省く
      col_count.times do |i|
        file = ary_row[i][n]
        export_files.push(file)
      end
    end

    # 一行ずつ並べる
    # rows = export_files.each_slice(ary_row.count).to_a
    rows = export_files.each_slice(col_count).to_a
    rows.each { |line| one_row(line, max_length) }
  end
end
