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

  def output(sorted_files, directory_nil)
    file_info = build_finfo_hash(sorted_files, directory_nil)

    puts "total #{file_info.sum { |hash| hash[:block] }}"

    max_len_nlinks, max_len_uids, max_len_gids, max_len_size = build_max_length_array(file_info)

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

  def select_fstat(file)
    File.ftype(file) == 'link' ? File.lstat(file) : File.stat(file)
  end

  def select_ftype(file)
    type = File.ftype(file)
    type == 'file' ? '-' : type[0]
  end

  def format_frole(nmode)
    mode = nmode.chars

    user = FILE_ROLE[mode[1]]
    group = FILE_ROLE[mode[2]]
    other = FILE_ROLE[mode[3]]

    role = user + group + other
    role.ljust(11, ' ')
  end

  def format_ftime(time)
    # 6ヶ月以内のファイル/ディレクトリは月日時分
    # 6ヶ月以上前のファイル/ディレクトリは月日年
    date = (Date.today - time.to_date).abs > 181 ? '%_2m %e  %Y' : '%_2m %e %R'
    time.strftime(date)
  end

  def build_max_length_array(file_info)
    %i[nlink uid gid size].map do |target|
      target_list = file_info.map { |file| file[target] }
      target_list.max_by(&:length).length
    end
  end

  def build_finfo_hash(sorted_files, directory_nil)
    sorted_files.map do |file|
      stat = select_fstat(file)

      {
        name: directory_nil ? file : File.basename(file),
        type: select_ftype(file),
        mode: format_frole(stat.mode.to_s(8)[-4, 4]),
        nlink: select_fstat(file).nlink.to_s,
        uid: Etc.getpwuid(select_fstat(file).uid).name,
        gid: Etc.getgrgid(select_fstat(file).gid).name,
        size: select_fstat(file).size.to_s,
        time: format_ftime(stat.mtime),
        block: select_fstat(file).blocks
      }
    end
  end
end
