module GoogleCharts
  Infinity = 1.0/0

  class Sparkline
    include ActionView::Helpers::TextHelper

    attr_reader :background_color, :chart_background, :data, :data_max,
      :fill, :line_color, :marker_color, :marker_size, :size

    def initialize(data, args={})
      args ||= {} #guard against nil being passed for args
      options = args.dup.symbolize_keys!

      @background_color = options.fetch(:bg_color){ 'CCCCCC' }
      @chart_background = options.fetch(:chart_bg_color){ 'FFFFFF' }
      @data             = data

      @data_max         = options.fetch(:max){ data.max }
      if @data_max.is_a?(String)
        @data_max = @data_max.to_f
      end

      @fill             = options.fetch(:fill){ true }
      if @fill.is_a?(String)
        @fill = @fill == 'true'
      end

      @line_color       = options.fetch(:line_color){ '000000' }
      @marker_color     = options.fetch(:marker_color){ 'FA6900' }
      @marker_size      = options.fetch(:marker_size){ 3.0 }

      height            = options.fetch(:height){ 25 }
      width             = options.fetch(:width){ 135 }
      @size             = [width.to_i, height.to_i]
    end

    def url
      url = 'https://chart.googleapis.com/chart'
      url << "?cht=ls"
      url << "&chd=t:#{text_encode(data)}"

      # chart background color
      url << "&chf=bg,s,#{chart_background}"

      # fill area & chart markers
      if @fill
        url << "&chm=B,#{background_color},0,0,0#{build_chart_markers}"
      end

      #line style
      url << "&chls=1,1,0"
      url << "&chco=#{line_color}"

      #chart size
      url << "&chs=#{size.join('x')}"

      #chart legend margin - used to create padding for min and max dots
      url << "&chma=5,5,5,5"

      url
    end

    private

    def text_encode(data)
      begin
        encoded_data = []
        data.each do |point|
          @point = point #set value for debugging if needed
          encoded_data << (point > 0 ? (100 * (point.to_f / data_max.to_f)).to_i : point)
        end
        data = encoded_data
        data.join(',')
      rescue FloatDomainError
        raise "#{@point.inspect}--#{@data.inspect}"
      end
    end

    def build_chart_markers
      return '' if data.min == 0 && data.min == data.max

      markers = []
      min_marked = false
      max_marked = false

      data.each_with_index do |point, index|
        if point == data.max && !max_marked
          markers << "o,#{marker_color},0,#{index},#{marker_size},1"
          max_marked = true
        elsif point == data.min && !min_marked
          markers << "o,#{marker_color},0,#{index},#{marker_size},1"
          min_marked = true
        end
      end

      return "|" + markers.join('|')
    end
  end
end
