require_relative 'file'
require_relative 'file_info'

def multi_dir(path, i)
  print "\n" if i >= 1
  puts "#{path}:"
end

def open_files(path)
  Dir::entries(path)
end

def exists_opt_long?(files, opts)
  if opts[:l]
    file_info = FileInfo.new
    file_info.output(files, opts)
  else
    file = Files.new
    file.output(files, opts)
  end
end

def sorted_files(files, opts)
  files = open_files(files) if files.class == String
  # ファイルを並べ替え
  files.sort!

  # オプションaの場合はドットファイルを除外する
  sorted_files = if opts[:a]
                   files
                 else
                   files.reject { |file| file.start_with?(".") unless file.include?('/') }
                 end

  # オプションrの場合はファイルの順序をひっくり返す
  sorted_files = sorted_files.reverse! if opts[:r]

  sorted_files
end
