require 'gnuplot'
require 'rubypython'
require 'fileutils'

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
  def UnifiedPlot.setPlotDefaults(plot,plotConf,title,oType,oName)
    plotConf = PLOT_DEFAULTS.merge(plotConf)
    unless 'x11' == oType
      plot.terminal "#{oType} size #{plotConf[:xsize]},#{plotConf[:ysize]} font #{plotConf[:font]} #{plotConf[:fontsize]}"
      plot.output "#{oName}.#{oType}"
    end
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
  end

  def UnifiedPlot.linePlot(inputs, plotConf: PLOT_DEFAULTS, title: '', oType: 'x11',oName: 'test')
    # allow hash input
    inputs = [inputs] if inputs.kind_of? Hash

    Gnuplot.open do |gp|
      Gnuplot::Plot.new( gp ) do |plot|
        setPlotDefaults(plot,plotConf,title,oType,oName)

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
  def UnifiedPlot.pm3d(inputs,plotConf: PLOT_DEFAULTS,title: '',oType: 'x11',oName: 'test')
    # allow hash input
    inputs = [inputs] if inputs.kind_of? Hash

    # tempfile for holding the data (ugly, but works)
    filename = `tempfile`.chomp
    Gnuplot.open do |gp|
      Gnuplot::SPlot.new( gp ) do |plot|
        setPlotDefaults(plot,plotConf,title,oType,oName)


        plot.nokey
        # write stuff to a file
        File.open(filename,'w') {|f|
          inputs.each {|data|
            f << data.join(' ')
            f << "\n"
          }
        }

        plot.view "map"
        plot.data << Gnuplot::DataSet.new("'"+filename+"'") do |ds|
          ds.with   = "image"
          ds.matrix = true
        end
      end
    end
    FileUtils.rm(filename)
  end
  def UnifiedPlot.fieldPlot(inputs)
    RubyPython.start
    pl = RubyPython.import('pylab')
    pl.imshow(inputs.to_a.reverse)
    pl.show()
  end
end
