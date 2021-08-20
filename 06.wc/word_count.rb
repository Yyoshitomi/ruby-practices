# frozen_string_literal: true

class WordCount
  def line_count(text)
    text.split(/\R/).size
  end

  def word_count(text)
    text.split(/\s+/).size
  end

  def byte_count(text)
    text.bytesize
  end

  def print_count(ary, options)
    ary = [ary[0]] if options[:l]

    ary.each { |count| print count.to_s.rjust(8, ' ') }
  end

  def print_name(name)
    print " #{name}\n"
  end

  def print_total_count(line, word, byte, options)
    ary = [line, word, byte].map(&:sum)
    print_count(ary, options)
    print_name('total')
  end

  def print_error_message(arg)
    if FileTest.directory?(arg)
      puts "wc: #{arg}: read: Is a directory"
    else
      puts "wc: #{arg}: open: No such file or directory"
    end
  end
end
