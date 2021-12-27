# frozen_string_literal: true

require 'date'

class DetailedFormatter
  STR_ROLE = {
    '0' => '---',
    '1' => '--x',
    '2' => '-w-',
    '3' => '-wx',
    '4' => 'r--',
    '5' => 'r-x',
    '6' => 'rw-',
    '7' => 'rwx'
  }.freeze

  def output(files_or_directories, file_list, opts)
    if files_or_directories.instance_of?(String)
      paths = file_list.map { |file| File.expand_path(file, files_or_directories) }
      output_total_blocks(paths)
    else
      paths = file_list
    end

    file_info = []
    paths.each_with_index do |file, i|
      stat = fstat(file)

      file_info << {
        name: file_list[i],
        type: str_type(file),
        mode: str_mode(stat.mode.to_s(8)[-4, 4]),
        nlink: fstat(file).nlink.to_s,
        uid: Etc.getpwuid(fstat(file).uid).name,
        gid: Etc.getgrgid(fstat(file).gid).name,
        size: fstat(file).size.to_s,
        time: ftime(stat.mtime)
      }
    end

    max_len_nlinks = max_len(file_info.map { |file| file[:nlink] })
    max_len_uids = max_len(file_info.map { |file| file[:uid] })
    max_len_gids = max_len(file_info.map { |file| file[:gid] })
    max_len_size = max_len(file_info.map { |file| file[:size] })

    file_info.each do |file|
      print "#{file[:type]}#{file[:mode]}"
      print "#{file[:nlink].rjust(max_len_nlinks, ' ')} "
      print "#{file[:uid].ljust(max_len_uids, ' ')}　"
      print "#{file[:gid].ljust(max_len_gids, ' ')}　"
      print "#{file[:size].rjust(max_len_size, ' ')} "
      print "#{file[:time]} "
      print "#{file[:name]}\n"
    end
  end

  private

  def fstat(file)
    # ファイルタイプによってlstatかstatでファイル情報を取得する
    File.ftype(file) == 'link' ? File.lstat(file) : File.stat(file)
  end

  # -lの総合ブロック数
  def output_total_blocks(paths)
    blocks = paths.map { |file| fstat(file).blocks }.sum
    puts "total #{blocks}" unless blocks.zero?
  end

  # ファイルタイプ
  def str_type(file)
    type = File.ftype(file)
    type == 'file' ? '-' : type[0]
  end

  # ファイルの権限を検証
  def str_mode(nmode)
    mode = nmode.chars

    user = STR_ROLE[mode[1]]
    group = STR_ROLE[mode[2]]
    other = STR_ROLE[mode[3]]

    role = user + group + other
    role.ljust(11, ' ')
  end

  # 作成時間
  def ftime(time)
    # 6ヶ月以内のファイル/ディレクトリは月日時分
    # 6ヶ月以上前のファイル/ディレクトリは月日年
    mon = time.strftime('%-m').rjust(2, ' ')

    date = (Date.today - time.to_date).abs > 181 ? "#{mon} %e  %Y" : "#{mon} %e %R"
    time.strftime(date)
  end

  def max_len(target)
    target.max_by(&:length).length
  end
end
