#!/usr/bin/env ruby

# カレントディレクトリを呼ぶ
# files = Dir::entries(Dir.pwd)
# こいつはカレントディレクトリの代わり
files = [".", "..", "demo", ".gitkeep", "testjshehwfhoehofhehofnowfhoeihi", "ls.rb", "test4", "testx", "test3", "test2", "test00000000000000000000000000001"]

# 取得したファイルを一旦配列にする
file_list = []
files.each do |file|
  file_list << file
end

# 順番がよろしくないのでソートする
file_list.sort!

# ファイル名が一番でかいのをサイズ確認
max_length = file_list.sort_by(&:length).last.length
# ↑のをちょっと整形
format_length = max_length + 6
# ターミナル画面のサイズを取得
wide_size = (`tput cols`).to_i

# ターミナル画面のサイズを一番長いファイル名で割って列を計算
col = wide_size / format_length

# 今から出力する予定のファイル名いくつあるか計算
file_count = file_list.count
# ファイル数を列で割って、行数を計算
row = (file_count.to_f / col).ceil

# ターミナル画面でできるだけ均等に並ぶように一旦計算
col_space = wide_size / col

# 行頭が[1,4,7,10]になるように配列を作成
export_file_list = Array.new
# ary.firstが[1,4,7,10]になるようにスライス
ary_row = file_list.each_slice(row).to_a

file_count.times do |n|
  ary_row.each_with_index do |ary, i|
    file = ary[n]
    export_file_list << file unless file == nil
  end
end

export_file_list.each_with_index do |file, i|
  print file

  if ((i+1) % col == 0) || i == export_file_list.size - 1
    print "\n"
  elsif !(file == nil)
    print " "
    space = format_length - file.length
    print " " * space
  end
end
