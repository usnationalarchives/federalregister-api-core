module FileIoSpecHelperMethods

  def create_file(path_and_filename, contents)
    FileUtils.makedirs(File.dirname(path_and_filename))
    File.open(path_and_filename, "w") { |file| file.write(contents) }
  end

  def delete_file(path_and_filename)
    FileUtils.rm_f(path_and_filename)
  end

end
