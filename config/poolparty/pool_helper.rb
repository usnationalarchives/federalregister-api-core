def eval_file(path)
  eval File.read(path), nil, path
end
