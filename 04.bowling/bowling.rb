#!/usr/bin/env ruby

score = ARGV[0]
scores = score.split(',')
shots = []
scores.each do |s|
  if s == 'X'
    shots << 10
    shots << 0
  else
    shots << s.to_i
  end
end

frames = shots.each_slice(2).to_a

point = 0
frames.each_with_index do |frame, s|
  next_frame = frames[s + 1]

  def bonus_count(point)
    point + 10
  end

  if frame[0] == 10 # strike
    point += bonus_count(next_frame.sum)
    point += frames[s + 2][0] if next_frame[0] == 10
  elsif frame.sum == 10 # spare
    point += bonus_count(next_frame[0])
  else
    point += frame.sum
  end

  break if s == 9
end

puts point
