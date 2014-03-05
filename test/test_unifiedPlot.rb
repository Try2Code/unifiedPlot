$:.unshift File.join(File.dirname(__FILE__),"..","lib")
require 'minitest/autorun'
require "unifiedPlot"
require 'narray'
require 'gsl'
require 'cdo'
require 'pp'

class TestPlotter < Minitest::Test
  def setup
    size = ENV.has_key?('SIZE') ? ENV['SIZE'] : 10
    x = (0...size).to_a.map(&:to_f)
    y = [1,2,3,4,5,4,3,2,4,0].map(&:to_f)

    allowedTypes = ["narray", "gsl", "ruby"]
    @inputType = ENV.has_key?('itype') ? ENV['itype'].downcase : 'narray'
    unless allowedTypes.include?(@inputType) then
      warn "Wrong inputtype #{@inputType}!"
      warn "Use one of #{allowedTypes.join(',')}."
      exit(1)
    end
    @data = case @inputType
    when 'narray' then
      {
        :x => NArray[*x],
        :y => NArray[*y],
      }
    when 'ruby' then
      {
        :x => x,
        :y => y,
      }
    when 'gsl' then
      {
        :x => GSL::Vector[*x],
        :y => GSL::Vector[*y],
      }
    end
  end
  def mathOp(op,input)
    case @inputType
    when 'gsl' then
      input.send(op)
    when 'narray' then
      NMath.send(op,input)
    when 'ruby' then
      input.map {|v| Math.send(op,v)}
    end
  end
  def showImage(file)
    system("sxiv #{file}")
  end
  def test_single_plot
    UnifiedPlot.linePlot([@data])
  end
  def test_single_plot_noX
    data = {
      :y => @data[:y],
      :title => 'noX',
    }
    UnifiedPlot.linePlot([data],title: 'noX')
  end
  def test_multi_plot_with_title
    data = [@data.merge({ :title => 'a' }),
            {
              :x => @data[:x],
              :y => mathOp(:sin,@data[:y]),
              :title => 'sin(a)',
            }]
    UnifiedPlot.linePlot(data)
  end
  def test_multi_plot_with_axes
    data = [{
      :x => @data[:x],
      :y => @data[:y],
      :axes => 'x2y1',
      :title => 'x2y1',
    },{
      :x => @data[:x],
      :y => mathOp(:sin,@data[:y]),
      :axes => 'x2y2',
      :title => 'x2y2',

    }]
    UnifiedPlot.linePlot(data)
  end
  def test_multi_plot_with_labels
    data = [{
      :x => @data[:x],
      :y => @data[:y],
      :axes => 'x1y2',
      :title => 'x1y2',
    },{
      :x => mathOp(:cos,@data[:x]),
      :y => mathOp(:sin,@data[:y]),
      :axes => 'x2y2',
      :title => 'x2y2',

    }]
    plotConf = {:y2label => 'y2label',:x2label => 'x2label'}
    UnifiedPlot.linePlot(data,plotConf: plotConf)
    oName = 'test_test_multi_plot_with_labels'
    UnifiedPlot.linePlot(data,plotConf: plotConf,oType: 'png',oName: oName)
    showImage("#{oName}.png")
  end
  def test_multi_plot_with_label_pos
    data = [{
      :x => @data[:x],
      :y => @data[:y],
      :axes => 'x1y2',
      :title => 'x1y2',
    },{
      :y => mathOp(:sin,@data[:y]),
      :title => 'sin',

    }]
    UnifiedPlot.linePlot(data,plotConf:  {:label_position => 'out left'})
    UnifiedPlot.linePlot(data,plotConf:  {:label_position => 'out right bottom'})
    UnifiedPlot.linePlot(data,plotConf:  {:label_position => 'out center bottom'})
    UnifiedPlot.linePlot(data,plotConf:  {:label_position => 'out center bottom horizontal'})
  end
  def test_heat_map
    @data[:y] = @data[:x]
    @data[:z] = mathOp(:sin,@data[:x])
    UnifiedPlot.linePlot([@data])
  end

  def test_field_plot
    Cdo.debug = true
    topo      = Cdo.topo(options: '-f nc',returnMaArray: 'topo')
    topoOcean = Cdo.setrtomiss(0,100000,input: "-topo", options: '-f nc',returnMaArray: 'topo')
    UnifiedPlot.fieldPlot(topo)
  end
end
