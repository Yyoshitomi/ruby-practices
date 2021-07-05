def fizz_buzz(n)
  require 'byebug'; byebug
  
  if n % 3 == 0 && n % 5 == 0
    "Fizz Buzz"
  elsif n % 3 == 0
    "Fizz"
  elsif n % 5 == 0
    "Buzz"
  else
    n.to_s
  end
end
