#!/usr/bin/env ruby
require 'optparse'
require 'date'

require_relative './set_date'
require_relative './is_valid_date'
require_relative './set_calender'

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

set_td_date

if @opt_year == nil && @opt_mon == nil
  set_calendar(@tdy, @tdm)
elsif @opt_year && @opt_mon
  isValid_year(@opt_year, @opt_mon)
elsif @opt_year
  isValid_year(@opt_year, @tdm)
else
  isValid_mon(@tdy, @opt_mon)
end
