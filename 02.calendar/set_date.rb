require 'date'

# today, year, month
def set_td_date
  @td = Date.today
  @tdy = @td.year.to_i
  @tdm = @td.month.to_i
  @tdd = @td.day
end
