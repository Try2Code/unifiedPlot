$:.unshift File.join(File.dirname(__FILE__),"..","lib")
require 'minitest/autorun'
require "unifiedPlot"
require 'narray'
require 'gsl'
require "pp"

class TestPlotter < Minitest::Test
  def test_single_plot
    x = (0...10).to_a.map(&:to_f)
    y = [1,2,3,4,5,4,3,2,4,0].map(&:to_f)
    data = {
      :x => NArray[*x],
      :y => NArray[*y],
    }
    UnifiedPlot.linePlot([data])
  end
  def test_single_plot_noX
    y = [1,2,3,4,5,4,3,2,4,0].map(&:to_f)
    data = {
      :y => NArray[*y],
      :title => 'noX',
    }
    UnifiedPlot.linePlot([data],title: 'noX')
  end
  def test_multi_plot_with_title
    x = (0...10).to_a.map(&:to_f)
    y = [1,2,3,4,5,4,3,2,4,0].map(&:to_f)
    data = [{
      :x => NArray[*x],
      :y => NArray[*y],
      :title => 'a',
    },{
      :x => NArray[*x],
      :y => NMath.sin(NArray[*y]),
      :title => 'sin(a)',
    }]
    UnifiedPlot.linePlot(data)
  end
  def test_multi_plot_with_axes
    x = (0...10).to_a.map(&:to_f)
    y = [1,2,3,4,5,4,3,2,4,0].map(&:to_f)
    data = [{
      :x => NArray[*x],
      :y => NArray[*y],
      :axes => 'x1y2',
      :title => 'x1y2',
    },{
      :x => NArray[*x],
      :y => NMath.sin(NArray[*y]),
      :axes => 'x2y2',
      :title => 'x2y2',

    }]
    UnifiedPlot.linePlot(data)
  end
  def test_multi_plot_with_labels
    x = (0...10).to_a.map(&:to_f)
    y = [1,2,3,4,5,4,3,2,4,0].map(&:to_f)
    data = [{
      :x => NArray[*x],
      :y => NArray[*y],
      :axes => 'x1y2',
      :title => 'x1y2',
    },{
      :x => NMath.cos(NArray[*x]),
      :y => NMath.sin(NArray[*y]),
      :axes => 'x2y2',
      :title => 'x2y2',

    }]
    plotConf = {:y2label => 'y2label',:x2label => 'x2label'}
    UnifiedPlot.linePlot(data,plotConf)
  end
  def test_multi_plot_with_label_pos
    x = (0...10).to_a.map(&:to_f)
    y = [1,2,3,4,5,4,3,2,4,0].map(&:to_f)
    data = [{
      :x => NArray[*x],
      :y => NArray[*y],
      :axes => 'x1y2',
      :title => 'x1y2',
    },{
      :y => NMath.sin(NArray[*y]),
      :title => 'sin',

    }]
    UnifiedPlot.linePlot(data,plotConf:  {:label_position => 'out left'})
    UnifiedPlot.linePlot(data,plotConf:  {:label_position => 'out right bottom'})
    UnifiedPlot.linePlot(data,plotConf:  {:label_position => 'out center bottom'})
    UnifiedPlot.linePlot(data,plotConf:  {:label_position => 'out center bottom horizontal'})
  end
end
