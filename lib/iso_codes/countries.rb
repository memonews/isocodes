module IsoCodes
  class Countries < EntityCollection
    def initialize(xml = nil)
      unless xml
        xml = "#{self.class.xml_path}/iso_3166.xml"
      end

      super(xml, Country, 'iso_3166_entry')
    end
  end

  class Country < Entity
    attribute :alpha2, :alpha_2_code
    attribute :alpha3, :alpha_3_code
    attribute :numeric, :numeric_code
    attribute :common_name
    attribute :name
    attribute :official_name

    def to_s
      name
    end
  end
end
