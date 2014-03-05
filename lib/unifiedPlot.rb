require 'gnuplot'
require 'rubypython'

module UnifiedPlot

  PLOT_DEFAULTS = {
    :grid    => true,
    :ylabel  => nil,
    :y2label => nil,
    :xlabel  => nil,
    :x2label => nil,
    :label_position => 'bottom out',
    :xsize => 1200,
    :ysize => 800,
    :font => 'arial',
    :fontsize => 10,
  }
  DATA_DEFAULTS = {
    :title   => '',
    :style   => 'linespoints',
    :axes    => 'x1y1',
  }
  #
  # input elements: data = {
  #   :y => [...],     (required)
  #   :x => [...],     (optional)
  #   :axes => 'x2y1', (optional)
  #   :title => '...',
  #   :style => 'lines',
  # }
  #        plot = {
  #   :xlabel => '',
  #   :ylabel => '',
  #   :title  => '',
  #   :grid   => false,
  # }
  def UnifiedPlot.linePlot(inputs, plotConf: PLOT_DEFAULTS, title: '', oType: 'x11',oName: 'test')
    # allow hash input
    inputs = [inputs] if inputs.kind_of? Hash

    plotConf = PLOT_DEFAULTS.merge(plotConf) unless plotConf == PLOT_DEFAULTS 

    Gnuplot.open do |gp|
      Gnuplot::Plot.new( gp ) do |plot|
        unless 'x11' == oType
          plot.terminal "#{oType} size #{plotConf[:xsize]},#{plotConf[:ysize]} font #{plotConf[:font]} #{plotConf[:fontsize]}"
          plot.output "#{oName}.#{oType}"
        end

        plotConf = PLOT_DEFAULTS.merge(plotConf)
        plot.title   title
        plot.key     plotConf[:label_position]

        plot.xrange  plotConf[:xrange]  unless plotConf[:xrange].nil?
        plot.x2range plotConf[:x2range] unless plotConf[:x2range].nil?
        plot.yrange  plotConf[:yrange]  unless plotConf[:yrange].nil?
        plot.y2range plotConf[:y2range] unless plotConf[:y2range].nil?

        plot.xtics
        plot.ytics

        plot.xlabel  plotConf[:xlabel]
        plot.x2label plotConf[:x2label]
        plot.ylabel  plotConf[:ylabel]
        plot.y2label plotConf[:y2label]
        inputs.each {|data|
          data = DATA_DEFAULTS.merge(data)
          dataset = data.has_key?(:x) ? [data[:x].to_a,data[:y].to_a] : data[:y].to_a
          plot.data << Gnuplot::DataSet.new( dataset ) do |ds|
            ds.with  = data[:style]
            ds.axes  = data[:axes]
            plot.x2tics  'in' if data[:axes][0,2] == 'x2'
            plot.y2tics  'in' if data[:axes][-2..-1] == 'y2'
            ds.title = data[:title]
          end
        }
        plot.grid
      end
    end
  end
  def UnifiedPlot.heatMap(inputs,plotConf: PLOT_DEFAULTS,title: '',oType: 'x11',oName: 'test')
    Gnuplot.open do |gp|
      Gnuplot::Plot.new( gp ) do |plot|
        unless 'x11' == oType
          plot.terminal oType
          plot.output "#{oName}.#{oType}"
        end

        plotConf = PLOT_DEFAULTS.merge(plotConf)
        plot.title   title
        plot.key     plotConf[:label_position]

        plot.xrange  plotConf[:xrange]  unless plotConf[:xrange].nil?
        plot.x2range plotConf[:x2range] unless plotConf[:x2range].nil?
        plot.yrange  plotConf[:yrange]  unless plotConf[:yrange].nil?
        plot.y2range plotConf[:y2range] unless plotConf[:y2range].nil?

        plot.xtics
        plot.ytics

        plot.xlabel  plotConf[:xlabel]
        plot.x2label plotConf[:x2label]
        plot.ylabel  plotConf[:ylabel]
        plot.y2label plotConf[:y2label]
        inputs.each {|data|
          data = DATA_DEFAULTS.merge(data)
          dataset = [data[:x].to_a,data[:y].to_a,data[:z].to_a]
          plot.data << Gnuplot::DataSet.new( dataset ) do |ds|
            ds.with  = 'image'
            ds.axes  = data[:axes]
            ds.title = data[:title]
          end
        }
        plot.grid
      end
    end
  end
  def UnifiedPlot.fieldPlot(inputs)
    RubyPython.start
    pl = RubyPython.import('pylab')
    pl.imshow(inputs.to_a.reverse)
    pl.show()
  end
end
