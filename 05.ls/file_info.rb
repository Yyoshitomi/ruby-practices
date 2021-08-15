require "date"
require_relative "fomat_files"

class FileInfo
  def output(path, opts)
    sorted_files = sorted_files(path, opts)
    path = nil if path.class == Array
    paths = sorted_files.map { |file| File.expand_path(file, path) }
    
    output_total_blocks(paths) if path.class == String

    finfo_ary(paths)
    finfo_len
    paths.each_with_index do |file, i|
      file_info(file)

      print "#{@type}#{@mode}"
      print "#{fomat_finfo_int(@nlink[i], @nlink_len)} "
      print "#{fomat_finfo_string(@uid[i], @uid_len)}　"
      print "#{fomat_finfo_string(@gid[i], @gid_len)}　"
      print "#{fomat_finfo_int(@size[i], @size_len)} "
      print "#{@time} "
      print "#{sorted_files[i]}\n"
    end
  end

  private

  def fstat(file)
    # ファイルタイプのよってlstatかstatでファイル情報を取得する
    if (File.ftype(file) == "link")
      stat = File.lstat(file)
    else
      stat = File.stat(file)
    end
  end

  def output_total_blocks(paths)
    blocks = 0
    paths.each { |file| blocks += fstat(file).blocks }
    puts "total #{blocks}"
  end

  # ファイルタイプ
  def str_type(file)
    type = File.ftype(file)
    type_char = type == "file" ? "-" : type[0]
  end

  def to_str_role(mode, n)
    
  end

  def str_role(i)
    role = {
      "0" => "---",
      "1" => "--x",
      "2" => "-w-",
      "3" => "-wx",
      "4" => "r--",
      "5" => "r-x",
      "6" => "rw-",
      "7" => "rwx"
    }[i]
  end

  def sticky_bit(role)
    role[2] = role[2] == "x" ? "t" : "T"
  end

  def set_id(role)
    role[2] = role[2] == "x" ? "s" : "S"
  end

  # ファイルの権限を検証
  def str_mode(nmode)
    mode = nmode.chars

    user = str_role(mode[1])
    group = str_role(mode[2])
    other = str_role(mode[3])

    case mode[0]
    when "1"
      other = sticky_bit(othr)
    when "2"
      user = set_id(user)
    when "4"
      group = set_id(group)
    end

    role = user + group + other
    
    fomat_finfo_string(role, 11)
  end

  def ftime(time)
    # 6ヶ月以内のファイル/ディレクトリは月日時分
    # 6ヶ月以上前のファイル/ディレクトリは月日年
    mon = fomat_finfo_int(time.strftime("%-m"), 2)

    date = ((Date.today - time.to_date).abs > 181) ? "#{mon} %e  %Y" : "#{mon} %e %R"
    time.strftime(date)
  end

  def fomat_finfo_string(target, len)
    target.ljust(len, " ")
  end

  def fomat_finfo_int(target, len)
    target.rjust(len, " ")
  end

  # 長さが異なるので一旦配列化
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
    target.sort_by(&:length).last.length
  end

  # 最長のファイル名を求める
  def finfo_len
    @nlink_len = max_len(@nlink)
    @uid_len = max_len(@uid)
    @gid_len = max_len(@gid)
    @size_len = max_len(@size)
  end

  # 字詰めをあまり考えなくて良さそうなのでそのまま使う
  def file_info(file)
    stat = fstat(file)

    @type = str_type(file)
    @mode = str_mode(stat.mode.to_s(8)[-4, 4])
    @time = ftime(stat.mtime)
  end
end
