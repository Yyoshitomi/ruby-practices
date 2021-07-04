require_relative './set_date'

def isValid_year(year, mon)
  n_year = year.to_i
  str_year = year.to_s
  
  if (str_year =~ /^[0-9]+$/) && (9999 >= n_year) && (n_year >= 1)
    isValid_mon(n_year, mon)
  elsif
    print "cal: year `#{str_year}' not in range 1..9999\n"
  end
end

def isValid_mon(year, mon)
  n_mon = mon.to_i
  str_mon = mon.to_s

  if (str_mon =~ /^[0-9]+$/) && (12 >= n_mon) && (n_mon >= 1)
    set_calendar(year, n_mon)
  elsif
    print "cal: #{str_mon} is neither a month number (1..12) nor a name\n"
  end
end
