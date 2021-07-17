# 指定された値を検証する
# 年は1-9999、かつ月は1-12の範囲内の整数であるかどうかを検証
# 文字列や少数など整数でなさそうな場合などはメッセージを表示する
def is_valid_year(year)
  n_year = year.to_i
  str_year = year.to_s
  
  if (9999 >= n_year) && (n_year >= 1)
    @opt_year = n_year
  else
    print "cal: year `#{str_year}' not in range 1..9999\n"
  end
end

def is_valid_mon(mon)
  n_mon = mon.to_i
  str_mon = mon.to_s

  if (str_mon =~ /^[0-9]+$/) && (12 >= n_mon) && (n_mon >= 1)
    @opt_mon = n_mon
  else
    print "cal: #{str_mon} is neither a month number (1..12) nor a name\n"
  end
end
