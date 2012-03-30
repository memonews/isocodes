require 'spec_helper'

describe IsoCodes do
  describe "prefix detection" do
    include FakeFS::SpecHelpers

    before(:each) do
      IsoCodes.isocodes_prefix = nil
    end

    describe "default prefixes" do
      %w(/usr /usr/local).each do |prefix|
        it "should use #{prefix} automatically if applicable" do
          xml_path = Pathname.new("#{prefix}/share/xml/iso-codes/iso_3166.xml")
          xml_path.dirname.mkpath
          FileUtils.touch(xml_path.to_s)

          IsoCodes.isocodes_prefix.should == prefix
        end
      end
    end

    it "should use given prefix" do
      IsoCodes.isocodes_prefix = "/foo"
      IsoCodes.isocodes_prefix.should == "/foo"
    end
  end
end
