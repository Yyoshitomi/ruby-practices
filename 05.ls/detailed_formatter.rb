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

  def output(files_or_directories, file_list)
    if FileTest.directory?(files_or_directories[0])
      paths = file_list.map { |file| File.expand_path(file, files_or_directories) }
      output_total_blocks(paths)
    else
      paths = file_list
    end

    file_info = get_finfo(paths)

    max_len_nlinks, max_len_uids, max_len_gids, max_len_size = get_max_len(file_info)

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

  def get_fstat(file)
    File.ftype(file) == 'link' ? File.lstat(file) : File.stat(file)
  end

  # -lの総合ブロック数
  def output_total_blocks(paths)
    blocks = paths.map { |file| get_fstat(file).blocks }.sum
    puts "total #{blocks}" unless blocks.zero?
  end

  # ファイルタイプ
  def get_str_ftype(file)
    type = File.ftype(file)
    type == 'file' ? '-' : type[0]
  end

  # ファイルの権限を検証
  def get_frole(nmode)
    mode = nmode.chars

    user = STR_ROLE[mode[1]]
    group = STR_ROLE[mode[2]]
    other = STR_ROLE[mode[3]]

    role = user + group + other
    role.ljust(11, ' ')
  end

  # 作成時間
  def get_ftime(time)
    # 6ヶ月以内のファイル/ディレクトリは月日時分
    # 6ヶ月以上前のファイル/ディレクトリは月日年
    mon = time.strftime('%-m').rjust(2, ' ')

    date = (Date.today - time.to_date).abs > 181 ? "#{mon} %e  %Y" : "#{mon} %e %R"
    time.strftime(date)
  end

  def get_max_len(file_info)
    %i[nlink uid gid size].map do |target|
      target_list = file_info.map { |file| file[target] }
      target_list.max_by(&:length).length
    end
  end

  def get_finfo(paths)
    file_info = []
    paths.map do |file|
      stat = get_fstat(file)

      file_info << {
        name: File.basename(file),
        type: get_str_ftype(file),
        mode: get_frole(stat.mode.to_s(8)[-4, 4]),
        nlink: get_fstat(file).nlink.to_s,
        uid: Etc.getpwuid(get_fstat(file).uid).name,
        gid: Etc.getgrgid(get_fstat(file).gid).name,
        size: get_fstat(file).size.to_s,
        time: get_ftime(stat.mtime)
      }
    end

    file_info
  end
end
