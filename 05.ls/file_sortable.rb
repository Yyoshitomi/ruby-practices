# frozen_string_literal: true

module FileSortable
  def sorted_files(files_or_path, opts)
    files = if files_or_path.instance_of?(String)
              Dir.entries(files_or_path)
            else
              files_or_path
            end

    files.sort!

    sorted_files = if opts[:a]
                     files
                   else
                     files.reject { |file| file.start_with?('.') unless file.include?('/') }
                   end

    sorted_files.reverse! if opts[:r]

    sorted_files
  end
end
