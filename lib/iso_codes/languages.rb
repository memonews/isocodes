module IsoCodes
  class Languages < EntityCollection
    def initialize(xml = nil)
      unless xml
        xml = "#{self.class.xml_path}/iso_639.xml"
      end

      super(xml, Language, 'iso_639_entry')
    end

    def with_alpha2
      self.reject { |lang| lang.alpha2.nil? }
    end
  end

  class Language < Entity
    attribute :alpha2, :iso_639_1_code
    attribute :alpha3, :iso_639_2B_code
    attribute :name, :localizable => true

    bindtextdomain "iso_639", :path => "#{IsoCodes.isocodes_prefix}/share/locale"

    def to_s
      name
    end

    def <=>(other)
      self.alpha2 <=> other.alpha2
    end
  end
end

