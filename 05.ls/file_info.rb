# frozen_string_literal: true

require 'date'
require_relative 'fomat_files'

class FileInfo
  def output(path, opts)
    sorted_files = sorted_files(path, opts)
    path = nil if path.instance_of?(Array)
    paths = sorted_files.map { |file| File.expand_path(file, path) }

    output_total_blocks(paths) if path.instance_of?(String)

    finfo_ary(paths)
    finfo_len
    paths.each_with_index do |file, i|
      file_info(file)

      print "#{@type}#{@mode}"
      print "#{@nlink[i].rjust(@nlink_len, ' ')} "
      print "#{@uid[i].ljust(@uid_len, ' ')}　"
      print "#{@gid[i].ljust(@gid_len, ' ')}　"
      print "#{@size[i].rjust(@size_len, ' ')} "
      print "#{@time} "
      print "#{sorted_files[i]}\n"
    end
  end

  private

  def fstat(file)
    # ファイルタイプによってlstatかstatでファイル情報を取得する
    File.ftype(file) == 'link' ? File.lstat(file) : File.stat(file)
  end

  # -lの総合ブロック数
  def output_total_blocks(paths)
    blocks = 0
    paths.each { |file| blocks += fstat(file).blocks }
    puts "total #{blocks}"
  end

  # ファイルタイプ
  def str_type(file)
    type = File.ftype(file)

    type == 'file' ? '-' : type[0]
  end

  # ファイル権限
  def str_role(num)
    {
      '0' => '---',
      '1' => '--x',
      '2' => '-w-',
      '3' => '-wx',
      '4' => 'r--',
      '5' => 'r-x',
      '6' => 'rw-',
      '7' => 'rwx'
    }[num]
  end

  # sticky bitありの場合
  def sticky_bit(role)
    role[2] = role[2] == 'x' ? 't' : 'T'
  end

  # SUID,SGIDありの場合
  def sid(role)
    role[2] = role[2] == 'x' ? 's' : 'S'
  end

  # ファイルの権限を検証
  def str_mode(nmode)
    mode = nmode.chars

    user = str_role(mode[1])
    group = str_role(mode[2])
    other = str_role(mode[3])

    case mode[0]
    when '1'
      other = sticky_bit(othr)
    when '2'
      user = sid(user)
    when '4'
      group = sid(group)
    end

    role = user + group + other
    role.ljust(11, ' ')
  end

  # 作成時間
  def ftime(time)
    # 6ヶ月以内のファイル/ディレクトリは月日時分
    # 6ヶ月以上前のファイル/ディレクトリは月日年
    mon = time.strftime('%-m').ljust(2, ' ')

    date = (Date.today - time.to_date).abs > 181 ? "#{mon} %e  %Y" : "#{mon} %e %R"
    time.strftime(date)
  end

  def finfo_ary(files)
    @nlink = []
    @uid = []
    @gid = []
    @size = []

    files.map do |f|
      stat = fstat(f)

      @nlink << stat.nlink.to_s
      @uid << Etc.getpwuid(stat.uid).name
      @gid << Etc.getgrgid(stat.gid).name
      @size << stat.size.to_s
    end
  end

  def max_len(target)
    target.max_by(&:length).length
  end

  def finfo_len
    @nlink_len = max_len(@nlink)
    @uid_len = max_len(@uid)
    @gid_len = max_len(@gid)
    @size_len = max_len(@size)
  end

  def file_info(file)
    stat = fstat(file)

    @type = str_type(file)
    @mode = str_mode(stat.mode.to_s(8)[-4, 4])
    @time = ftime(stat.mtime)
  end
end
