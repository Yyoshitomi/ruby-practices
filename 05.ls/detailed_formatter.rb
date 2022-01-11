# frozen_string_literal: true

require 'date'

class DetailedFormatter
  FILE_ROLE = {
    '0' => '---',
    '1' => '--x',
    '2' => '-w-',
    '3' => '-wx',
    '4' => 'r--',
    '5' => 'r-x',
    '6' => 'rw-',
    '7' => 'rwx'
  }.freeze

  def output(files, directory = nil)
    file_path_list = files.map { |file| File.expand_path(file, directory) }.zip(files).to_h
    file_info = get_finfo(file_path_list)

    puts "total #{file_info.sum { |hash| hash[:block] }}"

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

  def get_str_ftype(file)
    type = File.ftype(file)
    type == 'file' ? '-' : type[0]
  end

  def get_frole(nmode)
    mode = nmode.chars

    user = FILE_ROLE[mode[1]]
    group = FILE_ROLE[mode[2]]
    other = FILE_ROLE[mode[3]]

    role = user + group + other
    role.ljust(11, ' ')
  end

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

  def get_finfo(file_path_list)
    file_info = []
    file_path_list.map do |path, file_name|
      stat = get_fstat(path)

      file_info << {
        name: file_name,
        type: get_str_ftype(path),
        mode: get_frole(stat.mode.to_s(8)[-4, 4]),
        nlink: get_fstat(path).nlink.to_s,
        uid: Etc.getpwuid(get_fstat(path).uid).name,
        gid: Etc.getgrgid(get_fstat(path).gid).name,
        size: get_fstat(path).size.to_s,
        time: get_ftime(stat.mtime),
        block: get_fstat(path).blocks
      }
    end

    file_info
  end
end
