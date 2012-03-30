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

  let(:entity_class) do
    Class.new(IsoCodes::Entity) do
      attribute :alpha2, :alpha_2_code
    end
  end

  let(:collection) { IsoCodes::EntityCollection.new(@xml_io, entity_class, 'iso_3166_entry') }

  describe "#all" do
    it "should have correct amount of entries" do
      collection.all.size.should == 2
    end
  end

  describe "#each" do
    it "should enumerate #all" do
      collection.each.to_a.should == collection.all
    end
  end

  describe "finding by attribute" do
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
end
