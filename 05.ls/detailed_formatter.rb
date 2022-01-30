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

  def output(file_group)
    total_block = file_group[:files].sum { |file| File.stat(file).blocks }
    puts "total #{total_block}" unless file_group[:directory].nil?

    finfo_hash = build_finfo_hash(file_group[:files], file_group[:directory])
    max_length = build_max_length_array(finfo_hash)
    finfo_hash.each { |finfo| print_finfo(finfo, max_length) }
  end

  private

  def build_finfo_hash(files, directory)
    files.map do |file|
      stat = File.stat(file)

      {
        type: FileTest.file?(file) ? '-' : File.ftype(file)[0],
        mode: stat.mode.to_s(8)[-3, 3].chars.map(&FILE_ROLE).join,
        nlink: stat.nlink.to_s,
        uid: Etc.getpwuid(stat.uid).name,
        gid: Etc.getgrgid(stat.gid).name,
        size: stat.size.to_s,
        time: format_ftime(stat.mtime),
        name: directory.nil? ? file : File.basename(file)
      }
    end
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

  def print_finfo(finfo, max_length)
    print "#{finfo[:type]}#{finfo[:mode].ljust(11, ' ')}"
    print "#{finfo[:nlink].rjust(max_length[0], ' ')} "
    print "#{finfo[:uid].ljust(max_length[1], ' ')}  "
    print "#{finfo[:gid].ljust(max_length[2], ' ')}  "
    print "#{finfo[:size].rjust(max_length[3], ' ')} "
    print "#{finfo[:time]} "
    puts finfo[:name]
  end
end
