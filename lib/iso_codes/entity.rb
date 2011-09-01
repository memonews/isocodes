module IsoCodes
  class EntityCollection
    include Enumerable

    class <<self
      DEFAULT_PREFIXES = [
        "/usr",
        "/usr/local"
      ]

      def isocodes_prefix
        @prefix ||= DEFAULT_PREFIXES.detect do |prefix|
          File.exists?("#{prefix}/share/xml/iso-codes/iso_3166.xml")
        end
      end

      def isocodes_prefix=(prefix)
        @prefix = prefix
      end

      def xml_path
        "#{isocodes_prefix}/share/xml/iso-codes"
      end
    end

    attr_reader :xml_doc

    def initialize(file, entity_class, xml_element_name)
      input = file.is_a?(IO) || file.is_a?(StringIO) ? file : File.open(file)
      @xml_doc = Nokogiri::XML.parse(input)
      @entity_class = entity_class
      @xml_element_name = xml_element_name
    end

    def method_missing(method, *args)
      value = args[0]
      if method.to_s =~ /^find_by_(.+)$/
        find_by_attribute($1, value)
      else
        super
      end
    end

    def find_by_xml_attribute(xml_attribute, value)
      selector = "#{@xml_element_name}[#{xml_attribute}=\"#{value}\"]"
      node = @xml_doc.css(selector)[0]

      if node
        @entity_class.new(node)
      end
    end

    def find_by_attribute(attribute, value)
      xml_attr = @entity_class.attributes[attribute.to_sym]
      if xml_attr
        find_by_xml_attribute(xml_attr, value)
      end
    end

    def each(&block)
      enum = Enumerator.new do |yielder|
        @xml_doc.css(@xml_element_name).each do |node|
          yielder << @entity_class.new(node)
        end
      end

      if block_given?
        enum.each(&block)
      else
        enum
      end
    end
  end

  class Entity
    class <<self
      def attributes
        @attributes ||= {}
      end

      def attribute(object_attribute, xml_attribute = nil)
        xml_attribute ||= object_attribute
        self.attributes[object_attribute] = xml_attribute.to_s

        define_method(object_attribute) do
          @attribute_cache[object_attribute] ||= @node[xml_attribute.to_s]
        end
      end
    end

    def initialize(node)
      @node = node
      @attribute_cache = {}
    end

    def <=>(other)
      self.to_s <=> other.to_s
    end
  end
end
