# frozen_string_literal: true

require 'date'
require_relative 'file_sortable'

class DetailedFormatter
  include FileSortable

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

  def output(files_or_path, opts)
    paths = sort_files(files_or_path, opts)
    if files_or_path.instance_of?(String)
      paths.map! { |file| File.expand_path(file, files_or_path) }
      output_total_blocks(paths)
    end

    fnlinks = file_nlinks(paths)
    fuids = file_uids(paths)
    fgids = file_gids(paths)
    fsize = file_size(paths)

    paths.each_with_index do |file, i|
      stat = fstat(file)

      print "#{str_type(file)}#{str_mode(stat.mode.to_s(8)[-4, 4])}"
      print "#{fnlinks[i].rjust(max_len(fnlinks), ' ')} "
      print "#{fuids[i].ljust(max_len(fuids), ' ')}　"
      print "#{fgids[i].ljust(max_len(fgids), ' ')}　"
      print "#{fsize[i].rjust(max_len(fsize), ' ')} "
      print "#{ftime(stat.mtime)} "
      print "#{sort_files(files_or_path, opts)[i]}\n"
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

  # ファイル権限
  def str_role(num)
    STR_ROLE[num]
  end

  # ファイルの権限を検証
  def str_mode(nmode)
    mode = nmode.chars

    user = str_role(mode[1])
    group = str_role(mode[2])
    other = str_role(mode[3])

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

  def file_nlinks(files)
    files.map { |file| fstat(file).nlink.to_s }
  end

  def file_uids(files)
    files.map { |file| Etc.getpwuid(fstat(file).uid).name }
  end

  def file_gids(files)
    files.map { |file| Etc.getgrgid(fstat(file).gid).name }
  end

  def file_size(files)
    files.map { |file| fstat(file).size.to_s }
  end

  def max_len(target)
    target.max_by(&:length).length
  end
end
