require 'date'

def set_td_date
  # today, year, month
  @td = Date.today
  @tdy = @td.year.to_i
  @tdm = @td.month.to_i
  @tdd = @td.day
end
