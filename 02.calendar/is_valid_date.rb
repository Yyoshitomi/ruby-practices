require_relative './set_date'

def isValid_year(year, mon)
  n_year = year.to_i

  if 9999 >= n_year && n_year >= 1
    isValid_mon(n_year, mon)
  elsif n_year == 0
    print "cal: year `#{year.to_s}' not in range 1..9999\n"
  else
    print "cal: year `#{n_year}' anot in range 1..9999\n"
  end
end

def isValid_mon(year, mon)
  n_mon = mon.to_i
  p n_mon

  if 12 >= n_mon && n_mon >= 1
    set_calendar(year, n_mon)
  elsif n_mon == 0
    print "cal: #{mon.to_s} is neither a month number (1..12) nor a name\n"
  else
    print "cal: #{n_mon} is neither a month number (1..12) nor a name\n"
  end
end
