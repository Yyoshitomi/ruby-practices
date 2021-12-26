# frozen_string_literal: true

module FileSortable
  def sort_files(files_or_path, opts)
    files = if files_or_path.instance_of?(String)
              Dir.entries(files_or_path)
            else
              files_or_path
            end

    sorted_files = files.sort!

    if opts[:a]
      sorted_files
    else
      sorted_files.reject { |file| file.start_with?('.') unless file.include?('/') }
    end

    opts[:r] ? sorted_files.reverse : sorted_files
  end
end
