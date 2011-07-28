module IsoCodes
  class Countries < EntityCollection
    DEFAULT_XML_PATHS = [
      "/usr/share/xml/iso-codes/iso_3166.xml",
      "/usr/local/share/xml/iso-codes/iso_3166.xml"
    ]

    def initialize(xml = nil)
      unless xml
        xml_file = DEFAULT_XML_PATHS.detect do |path|
          File.exists?(path)
        end
        xml = File.open(xml_file)
      end

      super(xml, Country, 'iso_3166_entry')
    end
  end

  class Country < Entity
    attribute :alpha2, :alpha_2_code
    attribute :alpha3, :alpha_3_code
    attribute :numeric_code
    attribute :common_name
    attribute :name
    attribute :official_name

    def to_s
      name
    end
  end
end
