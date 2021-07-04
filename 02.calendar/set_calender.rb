#!/usr/bin/env ruby
require 'color_echo'
require_relative './set_date'

def set_calendar(year, mon)
  set_td_date

  # 上記の条件分岐を経て、カレンダー上部に表示する日付
  output_date = "#{mon}月 #{year}年"
  # カレンダー上部に表示する日付をなんか良い感じの位置に出力する
  puts output_date.center(18)

  specifed_date = Date.new(year, mon, @tdd)

  # 週の初めの曜日
  first_wday = Date.new(year, mon, 1).wday
  # 月末の日付
  last_date = Date.new(year, mon, -1).day
  # 曜日(day of the week)をスペース区切りで指定し、配列を生成する
  dow = %w(日 月 火 水 木 金 土)

  # 配列で生成したdowを空白で連結して出力
  # そのままだと改行で表示されてしまう
  # printでも["日", "月", "火", "水", "木", "金", "土"]と出力されてしまう
  puts dow.join(" ")

  # 月初の曜日をなんか良い感じの位置に出力する
  print "   " * first_wday

  # 初日から月末の日の間に繰り返す感じのeach文
  (1..last_date).each do |date|
    # (1..last_date)から順番に取り出した値(date)を右詰で出力していく
    if year == @tdy && mon == @tdm && date == @tdd
      CE.fg(:black).bg(:white)
    else
      CE.fg(:white).bg(:black)
    end

    print date.to_s.rjust(2) + " "

    # 次の日付を生成しておく
    first_wday += 1
    # 1週間経ったら改行する
    if first_wday % 7 == 0
      print "\n"
    end
  end

  # 月末が来たらまた改行
  if first_wday % 7 != 0
    print "\n"
  end
end