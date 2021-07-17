#!/usr/bin/env ruby
require 'optparse'

require_relative 'set_date'
require_relative 'is_valid_date'
require_relative 'set_calender'

# オプション定義
# オプションの引数を渡されたら、その値をto_iで数字にする
option = {}
OptionParser.new do |opt|
  opt.on('-y [value]', '--year', 'gets year') {|v| option[:y] = v}
  opt.on('-m [value]', '--month', 'gets month') {|v| option[:m] = v}
  opt.parse!(ARGV)
end

# オプションで指定された値を変数に入れる
@opt_year = option[:y]
@opt_mon = option[:m]

# 今日の日付を呼んでおく
set_td_date

if @opt_year
  is_valid_year @opt_year
else @opt_year == nil
  @opt_year = @tdy
end

if @opt_mon
  is_valid_mon @opt_mon
else @opt_mon == nil
  @opt_mon = @tdm
end

set_calendar(@opt_year, @opt_mon)
