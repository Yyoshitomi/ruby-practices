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

  def print_count(count)
    print count.to_s.rjust(8, ' ')
  end

  def print_name(name)
    print " #{name}\n"
  end

  def print_total_count(l, w, b, options)
    if options[:l]
      print_count l.sum
    else
      [l, w, b].each { |x| print_count x.sum }
    end

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
