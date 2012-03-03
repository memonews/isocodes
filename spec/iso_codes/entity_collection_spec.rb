require 'spec_helper'
require 'pathname'

describe IsoCodes::EntityCollection do
  before(:each) do
    @xml = <<-XML
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
    @xml_io = StringIO.new(@xml)
  end

  describe "finding by attribute" do
    let(:entity_class) do
      Class.new(IsoCodes::Entity) do
        attribute :alpha2, :alpha_2_code
      end
    end

    let(:collection) { IsoCodes::EntityCollection.new(@xml_io, entity_class, 'iso_3166_entry') }

    it "should be able to find entries by xml attribute" do
      entity = collection.find_by_xml_attribute(:alpha_2_code, "AF")
      
      entity.should be_a(entity_class)
      entity.alpha2.should == "AF"
    end

    it "should be able to find entries by object attribute" do
      entity = collection.find_by_attribute(:alpha2, "AF")
      
      entity.should be_a(entity_class)
      entity.alpha2.should == "AF"
    end

    it "should be able to find entries with find_by_\#{attr}" do
      entity = collection.find_by_alpha2("AF")

      entity.should be_a(entity_class)
      entity.alpha2.should == "AF"
    end
  end

  describe "prefix detection" do
    include FakeFS::SpecHelpers

    before(:each) do
      IsoCodes::EntityCollection.isocodes_prefix = nil
    end

    describe "default prefixes" do
      %w(/usr /usr/local).each do |prefix|
        it "should use #{prefix} automatically if applicable" do
          xml_path = Pathname.new("#{prefix}/share/xml/iso-codes/iso_3166.xml")
          xml_path.dirname.mkpath
          FileUtils.touch(xml_path.to_s)

          IsoCodes::EntityCollection.isocodes_prefix.should == prefix
        end
      end
    end

    it "should use given prefix" do
      IsoCodes::EntityCollection.isocodes_prefix = "/foo"
      IsoCodes::EntityCollection.isocodes_prefix.should == "/foo"
    end
  end
end
