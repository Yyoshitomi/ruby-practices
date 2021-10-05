# frozen_string_literal: true

require_relative 'print_file'
require_relative 'print_file_detail'


def exists_opt_long(files, opts)
  if opts[:l]
    file_info = PrintFileInfo.new
    file_info.output(files, opts)
  else
    file = PrintFile.new
    file.output(files, opts)
  end
end

def sorted_files(files, opts)
  files = Dir.entries(files) if files.instance_of?(String)
  # ファイルを並べ替え
  files.sort!

  # オプションaの場合はドットファイルを除外する
  sorted_files = if opts[:a]
                   files
                 else
                   files.reject { |file| file.start_with?('.') unless file.include?('/') }
                 end

  # オプションrの場合はファイルの順序をひっくり返す
  sorted_files.reverse! if opts[:r]

  sorted_files
end
