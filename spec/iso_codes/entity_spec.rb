require 'spec_helper'

describe IsoCodes::Entity do
  before(:each) do
    xml = <<-XML
      <iso_3166_entries>
          <!-- First entry from iso_3166.xml -->
          <iso_3166_entry
              alpha_2_code="AF"
              alpha_3_code="AFG"                                                                   
              numeric_code="004"
              name="Afghanistan"
              official_name="Islamic Republic of Afghanistan" />

          <!-- First entry with common_name from iso_3166.xml -->
          <iso_3166_entry
              alpha_2_code="BO"
              alpha_3_code="BOL"
              numeric_code="068"
              common_name="Bolivia"                                                                
              name="Bolivia, Plurinational State of"
              official_name="Plurinational State of Bolivia" />
        </iso_3166_entries>
    XML
    @document = Nokogiri::XML.parse(xml)
    @afghanistan = @document.css('iso_3166_entry[alpha_2_code="AF"]')[0]
    @bolivia = @document.css('iso_3166_entry[alpha_2_code="BO"]')[0]
  end

  let(:entity) do
    Class.new(IsoCodes::Entity) do
      attribute :alpha2, "alpha_2_code"
      attribute :common_name, "common_name"
      attribute :name, :localizable => true

      bindtextdomain "iso_3166", :path => "#{IsoCodes.isocodes_prefix}/share/locale"
    end
  end

  describe "attributes" do
    it "should fetch the defined XML attribute" do
      entity.new(@bolivia).alpha2.should == "BO"
    end

    it "should accept symbols as XML attribute" do
      instance = entity.new(@bolivia)
      instance.alpha2.should == "BO"
    end

    it "should return nil on undefined XML attribute" do
      entity.new(@afghanistan).common_name.should be_nil
      entity.new(@bolivia).common_name.should == "Bolivia"
    end

    it "should default XML attribute name to object attribute name" do
      entity.new(@afghanistan).name.should == "Afghanistan"
    end

    it "should add defined attributes to .attributes" do
      entity.attributes.should have_key(:name)
      entity.attributes[:name].should == "name"
    end

    it "should ask the Nokogiri node only once" do
      mock_node = mock("mock-node")
      mock_node.should_receive(:"[]").once.and_return("foo")

      instance = entity.new(mock_node)

      3.times do
        instance.alpha2
      end
    end

    describe "localization" do
      before(:each) do
        ::GetText.locale = 'de'
      end
      subject { entity.new(@bolivia) }

      it "should add localized accessor for localizable attributes" do
        subject.should respond_to(:localized_name)
      end

      it "should not add localized accessor for non-localizable attribute" do
        subject.should_not respond_to(:localized_alpha2)
      end

      it "should return localized entry" do
        subject.localized_name.should == "Bolivien, Plurinationaler Staat"
      end
    end
  end
end
