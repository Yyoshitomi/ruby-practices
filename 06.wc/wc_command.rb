require_relative 'word_count'

def wc_command(texts, options)
  t_lines = []
  t_words = []
  t_bytes = []

  wc = WordCount.new

  texts = 

  texts.each do |t|
    text = t[0]
    name = t[1]
    error = t[2]

    lines = wc.line_count(text)
    words = wc.word_count(text)
    bytes = wc.byte_count(text)

    if error.nil?
      if options[:l]
        wc.print_count lines
      else
        [lines, words, bytes].each { |count| wc.print_count(count) }
      end

      wc.print_name(name)
    end

    if texts.size > 1
      t_lines.push(lines)
      t_words.push(words)
      t_bytes.push(bytes)
    end
  end

  if texts.size > 1
    wc.print_total_count(t_lines, t_words, t_bytes, options)
  end
end
