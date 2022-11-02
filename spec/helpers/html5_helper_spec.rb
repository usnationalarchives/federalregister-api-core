require 'spec_helper'

describe Html5Helper, type: :helper do
  describe "html5_tag" do
    context "with a tag name" do
      it "creates the html5 tag and child div" do
        output = html5_tag(:section)
        output.strip.should == '<section><div class="section"></div></section>'
      end
    end

    context "with a tag name and some content" do
      it "creates the html5 tag and child div with the content inside" do
        output = html5_tag(:section, "hi")
        output.strip.should == '<section><div class="section">hi</div></section>'
      end
    end

    context "with a tag name and a class" do
      it "creates the html5 tag and a div with the class" do
        output = html5_tag(:section, :class => "primary")
        output.strip.should == '<section><div class="section primary"></div></section>'
      end
    end

    context "with a tag name and a class and an id" do
      it "creates the html5 tag and a div with the class and an id" do
        output = html5_tag(:section, :class => "primary", :id => "footer")
        output.strip.should == '<section><div class="section primary" id="footer"></div></section>'
      end
    end

    context "with a tag name and an arbitrary attribute" do
      it "creates the html5 tag with the attribute and a div with the attribute and the class" do
        output = html5_tag(:section, :class => "primary", :foo => "bar")
        output.strip.should == '<section foo="bar"><div class="section primary" foo="bar"></div></section>'
      end
    end

    context "with a block" do
      it "creates the html5 tag, the inner div, and the yielded content" do
        output = eval_erb <<-ERB
          <% html5_tag(:section) do %><p>Hi there</p><% end %>
        ERB
        expect(output.strip).to eq("<section><div class=\"section\">&lt;p&gt;Hi there&lt;/p&gt;</div></section>")
      end
    end

    context "with nested blocks" do
      it "creates the html5 tag, the inner div, and the yielded content" do
        output = eval_erb <<-ERB
          <% html5_tag(:article) do %><% html5_tag(:section) do %><% html5_tag :hgroup do %><h1>Hi there</h1><% end %><% end %><% end %>
        ERB
        output.strip.should == "<article><div class=\"article\"><section><div class=\"section\"><hgroup><div class=\"hgroup\">&lt;h1&gt;Hi there&lt;/h1&gt;</div></hgroup></div></section></div></article>"
      end
    end
  end

  describe "section_tag" do
    it "should work like html5_tag(:section)" do
      section_tag_output = section_tag("Hi", :class => "start")
      html5_tag_output   = html5_tag(:section, "Hi", :class => "start")

      section_tag_output.strip.should == html5_tag_output.strip
    end

    it "should work like html5_tag(:section) with a block" do
      section_tag_output = eval_erb <<-ERB
        <% section_tag(:class => "start") do %>Hi<% end %>
      ERB

      html5_tag_output = eval_erb <<-ERB
        <% html5_tag(:section, :class => "start") do %>Hi<% end %>
      ERB

      section_tag_output.strip.should == html5_tag_output.strip
    end
  end

  describe "inline tags" do
    describe "date_tag" do
      it "outputs a span instead of a div" do
        output = eval_erb <<-ERB
          <% date_tag(:class => "start") do %>10/15/2010<% end %>
        ERB
        output.strip.should == '<date><span class="date start">10/15/2010</span></date>'
      end
    end
  end
end
