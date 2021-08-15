require_relative "fomat_files"

class Files
  def output(files, opts)
    sorted_files = sorted_files(files, opts)

    # ファイル名が一番長いファイル名の長さ確認 & 整形
    max_length = sorted_files.sort_by(&:length).last.length + 2
    # ファイル数を計算
    count = sorted_files.count
    # ターミナル画面のサイズを一番長いファイル名で割って列を計算
    col = (`tput cols`).to_i / max_length

    if col >= count
      one_row(sorted_files, max_length)
    else
      split_screen = [max_length, count, col]
      multi_rows(sorted_files, split_screen)
    end
  end

  private

  def one_row(files, len)
    files.each_with_index do |file, i|
      # ファイル名を出力
      print file.ljust(len, " ")
    end

    print "\n"
  end

  def multi_rows(files, split_screen)
    max_length = split_screen[0]
    count = split_screen[1]
    col = split_screen[2]

    # ファイル数を列で割って行数を計算
    row = (count.to_f / col).ceil

    # 行頭が[1,4,7,10]にするための配列を作成
    export_files = Array.new
    # ary.firstが[1,4,7,10]になるようにスライス
    ary_row = files.each_slice(row).to_a

    # ary_row内の各配列を先頭から並び替える
    row.times do |n|
      ary_row.each_with_index do |ary, i|
        file = ary[n]
        export_files.push(file) if (file != nil) # nilは省く
      end
    end

    # 一行ずつ並べる
    rows = export_files.each_slice(ary_row.count).to_a
    rows.each {|row| one_row(row, max_length) }
  end
end
