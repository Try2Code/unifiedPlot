require 'gnuplot'
require 'rubypython'
require 'fileutils'
require 'tempfile'

module UnifiedPlot

  PLOT_DEFAULTS = {
    :grid    => true,
    :ylabel  => nil,
    :y2label => nil,
    :xlabel  => nil,
    :x2label => nil,
    :key => 'bottom out',
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

        plot.title   title

	UnifiedPlot.applyConf(plot,plotConf)

        plot.xtics
        plot.ytics

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
    return ('x11' != oType) ? [oName,oType].join('.') : nil
  end
  def UnifiedPlot.pm3d(inputs,plotConf: PLOT_DEFAULTS,title: '',oType: 'x11',oName: 'test')
    tfs = []
    Gnuplot.open do |gp|
      Gnuplot::SPlot.new( gp ) do |plot|
        unless 'x11' == oType
          plot.terminal oType
          plot.output "#{oName}.#{oType}"
        end

        plotConf = PLOT_DEFAULTS.merge(plotConf)
        plot.title   title

	UnifiedPlot.applyConf(plot,plotConf)

        plot.xtics
        plot.ytics

        # write stuff to a file
        tf = Tempfile.new('unifiedPlot')
        tfs << tf
        filename = tf.path
        File.open(filename,'w') {|f|
          inputs.each {|data|
            f << data.join(' ')
            f << "\n"
          }
        }

        plot.view "map"
        plot.data << Gnuplot::DataSet.new("'"+filename+"'") do |ds|
          ds.with = "image"
          ds.matrix = true
        end
      end
    end
    return ('x11' != oType) ? [oName,oType].join('.') : nil
  end
  def UnifiedPlot.heatMap(inputs,plotConf: PLOT_DEFAULTS,title: '',oType: 'x11',oName: 'test')
    plotConf = PLOT_DEFAULTS.merge(plotConf)
    Gnuplot.open do |gp|
      Gnuplot::Plot.new( gp ) do |plot|
        unless 'x11' == oType
          plot.terminal oType
          plot.output "#{oName}.#{oType}"
        end

        plot.title   title

	UnifiedPlot.applyConf(plot,plotConf)

        plot.xtics
        plot.ytics

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
    return ('x11' != oType) ? [oName,oType].join('.') : nil
  end
  def UnifiedPlot.fieldPlot(inputs)
    RubyPython.start
    pl = RubyPython.import('pylab')
    pl.imshow(inputs.to_a.reverse)
    pl.show()
  end
  private
  def UnifiedPlot.applyConf(plot,config)
    config.each {|k,v| 
      # avoid image settings
      next if [:font,:fontsize,:xsize,:ysize,:label_position].include?(k)
      unless [true,false].include?(v) then
	plot.send(k,v)
      else
	plot.send(k)
      end
    }
  end
end
