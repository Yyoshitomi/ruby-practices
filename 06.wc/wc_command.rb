# frozen_string_literal: true

require_relative 'word_count'

def wc_command(texts, options)
  t_lines = []
  t_words = []
  t_bytes = []

  wc = WordCount.new

  texts.each do |t|
    text = t[0]

    lines = wc.line_count(text)
    words = wc.word_count(text)
    bytes = wc.byte_count(text)

    t_lines.push(lines)
    t_words.push(words)
    t_bytes.push(bytes)

    next if t[2]

    ary = [lines, words, bytes]

    wc.print_count(ary, options)
    wc.print_name(t[1])
  end

  wc.print_total_count(t_lines, t_words, t_bytes, options) if texts.size > 1
end
