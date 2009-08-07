module CustomChartHelper
  class Pie3D
    include ActionView::Helpers::TextHelper
    
    def initialize(args={})
      options = args.dup
      @title           = options.delete(:title)
      @color_range     = options.delete(:color_range)
      @transparent_bg  = options.delete(:transparent_bg)
      @legend          = options.delete(:legend)
      @legend_location = options.delete(:legend_location) || :right
      @truncate_legend = options.delete(:truncate_legend)
      @labels          = options.delete(:labels)
      @size            = options.delete(:size) || [500,200]
      @data            = options.delete(:data)
      @counts          = options.delete(:counts) || false
    end

    def to_s
      url = 'http://chart.apis.google.com/chart'
      url << "?chd=t:#{text_encode(@data)}"
      
      if @title
        url << "&chtt=#{@title}"
      end
      
      url << '&chxr=0,0,1'
      
      if @color_range
        url << "&chco=#{@color_range.join(',')}"
      end
      
      if @transparent_bg
        url << "&chf=bg,s,efefef00"
      end
      
      if @legend
        url << "&chdl=#{prep_legend(@legend)}"
      end
      
      if @legend_location
        url << "#{legend_location(@legend_location)}"
      end
      
      if @labels
        url << "&chl=#{CGI::escape( @labels.join('|') )}"
      end
      
      url << "&chs=#{@size.join('x')}"
      url << '&cht=p3'
      
      url
    end
    
    def prep_legend(legend)
      if @truncate_legend
        legend = legend.map{|l| truncate(l, :length => @truncate_legend.to_i)}
      end
      if @counts
        legend_count = legend.zip(@data)
        legend = legend_count.map{|lc| "#{lc[0]} (#{lc[1]})"}
      end
      CGI::escape( legend.join('|') )
    end
    
    def legend_location(location)
      case location.to_sym
      when :bottom
        '&chdlp=bv'
      when :top
        'chdlp=tv'
      when :left
        '&chdlp=l'
      when :right
        '&chdlp=r'
      end
    end
    
    def text_encode(data)
      max = @data.max
      encoded_data = []
      @data.each do |point|
        encoded_data << sprintf("%.1f", (point.to_f / max))
      end
      encoded_data.join(',')
    end
  end
  
  def pie_3d_chart(options={})
    image_tag( Pie3D.new(options).to_s, :alt => options[:title] || options[:alt], :class => 'chart pie3d')
  end
end

