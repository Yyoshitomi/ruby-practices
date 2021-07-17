# 指定された値を検証する
# 年は1-9999、かつ月は1-12の範囲内の整数であるかどうかを検証
# 文字列や少数など整数でなさそうな場合などはメッセージを表示する
def is_valid_year(year)
  n_year = year.to_i
  str_year = year.to_s
  
  @input_year = if (9999 >= n_year) && (n_year >= 1)
                  n_year
                else
                  "cal: year `#{str_year}' not in range 1..9999"
                end
end

def is_valid_mon(mon)
  n_mon = mon.to_i
  str_mon = mon.to_s

  @input_mon = if (str_mon =~ /^[0-9]+$/) && (12 >= n_mon) && (n_mon >= 1)
                 n_mon
               else
                 "cal: #{str_mon} is neither a month number (1..12) nor a name"
               end
end

def is_valid_calendar(year, mon)
  if year.to_i == 0
    puts year
  elsif mon.to_i == 0
    puts mon
  else
    set_calendar(year, mon)
  end
end
