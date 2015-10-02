module FileIoSpecHelperMethods
  def create_file(file, contents)
    FileUtils.makedirs(File.dirname(file))
    File.open(file, "w") { |f| f.write(contents) }
  end

  def delete_file(file)
    FileUtils.rm_f(file)
  end
end
