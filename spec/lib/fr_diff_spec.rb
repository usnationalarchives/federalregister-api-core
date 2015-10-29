require 'spec_helper'

describe FrDiff do
  include FileIoSpecHelperMethods

  after(:all) do
    delete_file("#{Rails.root}/tmp/original.xml")
    delete_file("#{Rails.root}/tmp/modified.xml")
  end

  describe "#diff" do
    it "returns an empty string if the files are the same" do
      original_xml = <<-XML
<XML>
  <item>content</item>
</XML>
      XML
      modified_xml = <<-XML
<XML>
  <item>content</item>
</XML>
      XML

      diff = generate_diff(original_xml, modified_xml, :diff)
      diff.should == ""
    end

    it "returns the proper diff if the files are different" do
      original_xml = <<-XML
<XML>
  <item>content</item>
</XML>
      XML
      modified_xml = <<-XML
<XML>
  <item>modified content</item>
</XML>
      XML

      # indentation matters here for the diff comparison
      # TODO: BB something similar to how we clean the xslt html before
      # comparison in tests
      expected_diff = <<-DIFF
2c2
<   <item>content</item>
---
>   <item>modified content</item>
      DIFF

      diff = generate_diff(original_xml, modified_xml, :diff)
      diff.should == expected_diff
    end

    describe "#html_diff" do
      it "returns an empty diff if the files are the same" do
        original_xml = "<XML><item>content</item></XML>"
        modified_xml = "<XML><item>content</item></XML>"

        expected_diff = '<div class="diff"></div>'

        diff = generate_diff(original_xml, modified_xml, :html_diff)
        diff.should == expected_diff
      end

      it "creates an html diff when files are different" do
        original_xml = <<-XML
<XML>
  <item>content</item>
</XML>
        XML
        modified_xml = <<-XML
<XML>
  <item>modified content</item>
</XML>
        XML

        expected_diff = <<-HTML
<div class="diff">
  <ul>
    <li class="del"><del><span class="symbol">-</span>  &lt;item&gt;content&lt;/item&gt;</del></li>
    <li class="ins"><ins><span class="symbol">+</span>  &lt;item&gt;<strong>modified </strong>content&lt;/item&gt;</ins></li>
  </ul>
</div>
        HTML

        diff = generate_diff(original_xml, modified_xml, :html_diff)
        diff.should == expected_diff
      end

      it "does not return unchanged lines in the diff" do
        original_xml = <<-XML
<XML>
  <item>content</item>
  <item>content 2</item>
</XML>
        XML
        modified_xml = <<-XML
<XML>
  <item>modified content</item>
  <item>content 2</item>
</XML>
        XML

        expected_diff = <<-HTML
<div class="diff">
  <ul>
    <li class="del"><del><span class="symbol">-</span>  &lt;item&gt;content&lt;/item&gt;</del></li>
    <li class="ins"><ins><span class="symbol">+</span>  &lt;item&gt;<strong>modified </strong>content&lt;/item&gt;</ins></li>
  </ul>
</div>
        HTML

        diff = generate_diff(original_xml, modified_xml, :html_diff)
        diff.should == expected_diff
      end

      it "removes lines when when passed as the :ignore option" do
        original_xml = <<-XML
<XML>
  <identifier id='1234' />
  <item>content</item>
</XML>
        XML
        modified_xml = <<-XML
<XML>
  <identifier id='5678' />
  <item>modified content</item>
</XML>
        XML

        expected_diff = <<-HTML
<div class="diff">
  <ul>
    <li class="del"><del><span class="symbol">-</span>  &lt;item&gt;content&lt;/item&gt;</del></li>
    <li class="ins"><ins><span class="symbol">+</span>  &lt;item&gt;<strong>modified </strong>content&lt;/item&gt;</ins></li>
  </ul>
</div>
        HTML

        diff = generate_diff(original_xml, modified_xml, :html_diff, :ignore => ["identifier"])
        diff.should == expected_diff
      end
    end
  end

  def generate_diff(original, modified, method, args=nil)
    create_file("#{Rails.root}/tmp/original.xml", original)
    create_file("#{Rails.root}/tmp/modified.xml", modified)

    fr_diff = FrDiff.new(
      "#{Rails.root}/tmp/original.xml",
      "#{Rails.root}/tmp/modified.xml"
    )

    if args
      fr_diff.send(method, args)
    else
      fr_diff.send(method)
    end
  end
end
