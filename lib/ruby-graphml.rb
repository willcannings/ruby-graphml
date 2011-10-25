require 'nokogiri'

module GraphML
  VERSION = "0.0.1"
  
  class Key
    attr_accessor :id, :for, :name, :type, :desc, :default
    def initialize(attrs)
      attrs.each do |key, val|
        case key
        when 'id'
          @id = val
        when 'for'
          @for = val
        when 'attr.name'
          @name = val
        when 'attr.type'
          @type = val
        end
      end      
      @desc = ''
      @default = ''
    end
    
    def append(key, val)
      if key == 'desc'
        @desc += val
      elsif key == 'default'
        @default += val
      end
    end
  end

  class Edge
    def initialize(attrs, graph)
      attrs.each do |key, val|
        if key == 'source'
          @source = val
        elsif key == 'target'
          @target = val
        end
      end
      @graph = graph
      source.out_edges << self
      target.in_edges << self
    end
    
    def source
      @graph.nodes[@source]
    end
    
    def target
      @graph.nodes[@target]
    end
  end

  class Node
    attr_accessor :id, :data, :in_edges, :out_edges
    def initialize(attrs, graph)
      attrs.each do |key, val|
        if key == 'id'
          @id = val
        end
      end
      @data = {}
      @in_edges = []
      @out_edges = []
      @graph = graph
    end
    
    def key(name)
      key_obj = @graph.key_names[name]
      val = @data[key_obj.id]
      return key_obj.default if val.nil?
      val
    end
  end
  
  class Graph
    attr_accessor :keys, :key_names, :nodes, :edges

    def initialize
      @keys = {}
      @key_names = {}
      @nodes = {}
      @edges = []
    end
  end
  
  class Parser < Nokogiri::XML::SAX::Document
    attr_reader :graph
    
    def self.parse!(path)
      parser = self.new
      graph  = parser.graph
      parser = Nokogiri::XML::SAX::Parser.new(parser).parse(File.open(path, 'rb'))
      graph
    end
    
    def initialize
      @current_node = nil
      @current_key = nil
      @current_edge = nil
      @state = nil
      @sub_state = nil
      @graph = Graph.new
    end
    
    def start_element(name, attrs=[])
      case @state
      # creating a new key, node or edge
      when nil
        case name
        when 'key'
          @current_key = Key.new(attrs)
          @graph.keys[@current_key.id] = @current_key
          @graph.key_names[@current_key.name] = @current_key
        when 'node'
          @current_node = Node.new(attrs, @graph)
          @graph.nodes[@current_node.id] = @current_node
        when 'edge'
          @current_edge = Edge.new(attrs, @graph)
          @graph.edges << @current_edge
        else
          return
        end
        @state = name
        @sub_state = nil
        
      # adding to a key
      when 'key'
        raise 'Missing key object' if @current_key.nil?
        @sub_state = name
      
      # adding a key value to a node
      when 'node'
        raise 'Missing node object' if @current_node.nil?
        raise 'Unexpected attribute' if attrs[0][0] != 'key'
        @sub_state = attrs[0][1]
      end
    end
    
    def characters(string)
      return if @sub_state.nil?
      case @state
      when 'key'
        raise 'Missing key object' if @current_key.nil?
        @current_key.append(@sub_state, string)
      when 'node'
        raise 'Missing node object' if @current_node.nil?
        @current_node.data[@sub_state] ||= ''
        @current_node.data[@sub_state] += string
      end
    end
    
    def end_element(name)
      case @state
      when 'node'
        if name == 'node'
          @current_node = nil
          @state = nil
        else
          @sub_state = nil
        end
      when 'edge'
        if name == 'edge'
          @current_edge = nil
          @state = nil
        else
          @sub_state = nil
        end        
      when 'key'
        if name == 'key'
          @current_key = nil
          @state = nil
        else
          @sub_state = nil
        end
      end
    end
  end
  
end
