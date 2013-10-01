require 'gnuplot'

module UnifiedPlot

  #
  # input: data = {
  #   :x => [...],     (optional)
  #   :y => [...],     (required)
  #   :axes => 'x2y1', (optional)
  #   :title => '...',
  #   :style => 'lines',
  # }
  def UnifiedPlot.linePlot(data, oType='x11',oName='test')
    Gnuplot.open do |gp|
      Gnuplot::Plot.new( gp ) do |plot|
        unless 'x11' == oType
          plot.terminal oType
          plot.output "#{oName}.#{oType}"
        end
        if ENV['TITLE'].nil?
          plot.title 'vertDiff'
        else
          plot.title ENV['TITLE']
        end
        plot.grid

        plot.yrange  "[0:#{ENV['YMAX']}]"  unless ENV['YMAX'].nil?
        plot.y2range "[0:#{ENV['Y2MAX']}]" unless ENV['Y2MAX'].nil?

        plot.y2tics  'in'
        plot.key     'out horiz bot'
        plot.ylabel  'Temperture'
        plot.y2label 'Temperture'
        data.each {|v|
          plot.data << Gnuplot::DataSet.new( v ) do |ds|
            ds.with = "lines"
          end
        }
      end
    end
  end
end
