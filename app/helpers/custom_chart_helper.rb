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
  
  class Sparkline
    include ActionView::Helpers::TextHelper
    
    def initialize(args={})
      options = args.dup
      @line_color       = options.delete(:line_color) || '000000'
      @background_color = options.delete(:bg_color) || 'CCCCCC'
      @marker_color     = options.delete(:marker_color) || 'FA6900'
      @marker_size      = options.delete(:marker_size) || 3.0
      @size             = options.delete(:size) || [135,25]
      @data             = options.delete(:data)
      @data_max         = @data.max
      @fill             = options.delete(:fill) || true
    end

    def to_s
      url = 'http://chart.apis.google.com/chart'
      url << "?cht=ls"
      url << "&chd=t:#{text_encode(@data)}"
      
      # fill area & chart markers
      if @fill
        url << "&chm=B,#{@background_color},0,0,0#{build_chart_markers}"
      end
      
      #line style
      url << "&chls=1,1,0"
      url << "&chco=#{@line_color}"
      
      #chart size
      url << "&chs=#{@size.join('x')}"
      
      #chart legend margin - used to create padding for min and max dots
      url << "&chma=5,5,5,5"
      
      url
    end
    
    
    def text_encode(data)
    begin
      encoded_data = []
      @data.each do |point|
        @foo = point
        encoded_data << (point > 0 ? (100 * (point.to_f / @data_max.to_f)).to_i : point)
      end
      @data = encoded_data
      @max  = @data.max
      @min  = @data.min
      @data.join(',')
    rescue FloatDomainError
      raise "#{@foo.inspect}--#{@data.inspect}"
    end
    end
    
    def build_chart_markers
      return '' if @min == 0 && @min == @max
      markers = []
      min_marked = false
      max_marked = false
      @data.each_with_index do |point, index|
        if point == @max && !max_marked
          markers << "o,#{@marker_color},0,#{index},#{@marker_size},1"
          max_marked = true
        elsif point == @min && !min_marked
          markers << "o,#{@marker_color},0,#{index},#{@marker_size},1"
          min_marked = true
        end
      end
      return "|" + markers.join('|')
    end
  end
  
  def sparkline(options={})
    image_tag( Sparkline.new(options).to_s, :alt => options[:alt], :class => 'chart sparkline')
  end
  
  def pie_3d_chart(options={})
    image_tag( Pie3D.new(options).to_s, :alt => options[:title] || options[:alt], :class => 'chart pie3d')
  end
end

