$:.unshift File.join(File.dirname(__FILE__),"..","lib")
require 'minitest/autorun'
require "unifiedPlot"
require 'narray'
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
#    when 'gsl' then
#     {
#       :x => GSL::Vector[*x],
#       :y => GSL::Vector[*y],
#     }
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
    UnifiedPlot.linePlot(data,plotConf:  {:key => 'out left'})
    UnifiedPlot.linePlot(data,plotConf:  {:key => 'out right bottom'})
    UnifiedPlot.linePlot(data,plotConf:  {:key => 'out center bottom'})
    UnifiedPlot.linePlot(data,plotConf:  {:key => 'out center bottom horizontal'})
  end
  def test_heat_map
    @data[:y] = @data[:x]
    @data[:z] = mathOp(:sin,@data[:x])
    inputs = []

    10.times { inputs << (rand*@data[:z] + rand + rand).to_a }

    UnifiedPlot.pm3d(inputs,plotConf: {:key => 'out bot',:xrange => '[-0.5:9.5]',:yrange => '[-0.5:9.5]'},title: 'test_heat_map')
    oName='test_heat_map'
    UnifiedPlot.pm3d(inputs,plotConf: {:key => 'out bot', 
                                       :xrange => '[-0.5:9.5]',:yrange => '[-0.5:9.5]'},title: 'test_heat_map',oType: 'png',oName: oName)
    showImage("#{oName}.png")
  end

  def test_field_plot
    Cdo.debug = true
    topo      = Cdo.topo(options: '-f nc',returnMaArray: 'topo')
    topoOcean = Cdo.setrtomiss(0,100000,input: "-topo", options: '-f nc',returnMaArray: 'topo')
    UnifiedPlot.fieldPlot(topo)
  end
  def test_xlog
    myData = []
    @data[:y].each {|v|
      myData << v*rand*Math.exp(rand(50))
    }
    data = {
      :x => @data[:x],
      :y => myData,
    }
    UnifiedPlot.linePlot(data,plotConf:  {:key => 'out left'                   })
    UnifiedPlot.linePlot(data,plotConf:  {:key => 'out left',:logscale => 'y'})
  end
  def test_m
    data = {:x=>
      [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24], :y=>
      [0.0, -215427956736.0, -205305561088.0, -196051189760.0, -187469692928.0, -179452936192.0, -171930812416.0, -164852547584.0, -158178361344.0, -151875371008.0, -145915314176.0, -140273369088.0, -134927319040.0, -129857044480.0, -125044203520.0, -120471986176.0, -116124925952.0, -111988744192.0, -108050259968.0, -104297291776.0, -100718526464.0, -97303511040.0, -94042546176.0, -90926612480.0, -62281179136.0],
        :style=>"lines"}

      UnifiedPlot.linePlot(data,oName: "test_m",oType: 'png',
                           plotConf: {xsize: 300, ysize: 200})
      assert_equal('PNG',`identify test_m.png | cut -d ' ' -f 2`.chomp)
      assert_equal('300x200',`identify test_m.png | cut -d ' ' -f 3`.chomp)
  end
end
