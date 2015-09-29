module CustomDiffy
  class Diff < Diffy::Diff

    def to_s(format = nil)
      format ||= self.class.default_format
      formats = CustomDiffy::Format.instance_methods(false).map{|x| x.to_s}
      if formats.include? format.to_s
        enum = self
        enum.extend Format
        enum.send format
      else
        raise ArgumentError,
          "Format #{format.inspect} not found in #{formats.inspect}"
      end
    end

  end
end

