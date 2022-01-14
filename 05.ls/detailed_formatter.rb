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

  def output(files, directory_exists)
    finfo_hash = build_finfo_hash(files, directory_exists)

    puts "total #{finfo_hash.sum { |finfo| finfo[:block] }}" if directory_exists

    max_len_nlinks, max_len_uids, max_len_gids, max_len_size = build_max_length_array(finfo_hash)

    finfo_hash.each do |finfo|
      print "#{finfo[:type]}#{finfo[:mode]}"
      print "#{finfo[:nlink].rjust(max_len_nlinks, ' ')} "
      print "#{finfo[:uid].ljust(max_len_uids, ' ')}　"
      print "#{finfo[:gid].ljust(max_len_gids, ' ')}　"
      print "#{finfo[:size].rjust(max_len_size, ' ')} "
      print "#{finfo[:time]} "
      puts finfo[:name]
    end
  end

  private

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
    format = (Date.today - time.to_date).abs > 181 ? '%_2m %e  %Y' : '%_2m %e %R'
    time.strftime(format)
  end

  def build_max_length_array(finfo_hash)
    %i[nlink uid gid size].map do |target|
      target_list = finfo_hash.map { |finfo| finfo[target] }
      target_list.max_by(&:length).length
    end
  end

  def build_finfo_hash(files, directory_exists)
    files.map do |file|
      stat = File.stat(file)

      {
        name: directory_exists ? File.basename(file) : file,
        type: select_ftype(file),
        mode: format_frole(stat.mode.to_s(8)[-4, 4]),
        nlink: stat.nlink.to_s,
        uid: Etc.getpwuid(stat.uid).name,
        gid: Etc.getgrgid(stat.gid).name,
        size: stat.size.to_s,
        time: format_ftime(stat.mtime),
        block: stat.blocks
      }
    end
  end
end
