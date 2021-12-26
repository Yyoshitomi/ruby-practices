# frozen_string_literal: true

module FileSortable
  def sort_files(files_or_path, opts)
    files = if files_or_path.instance_of?(String)
              Dir.entries(files_or_path)
            else
              files_or_path
            end

    files.sort!

    sort_files = if opts[:a]
                     files
                   else
                     files.reject { |file| file.start_with?('.') unless file.include?('/') }
                   end

    opts[:r] ? sort_files.reverse : sort_files
  end
end
