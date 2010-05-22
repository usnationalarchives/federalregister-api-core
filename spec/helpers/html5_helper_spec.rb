describe Html5Helper do
  describe "html5_tag" do
    context "with a tag name" do
      it "creates the html5 tag and child div" do
        output = eval_erb <<-ERB
          <%= html5_tag(:section) %>
        ERB
        output.strip.should == '<section><div class="section"></div></section>'
      end
    end
    
    context "with a tag name and some content" do
      it "creates the html5 tag and child div with the content inside" do
        output = eval_erb <<-ERB
          <%= html5_tag(:section, "hi") %>
        ERB
        output.strip.should == '<section><div class="section">hi</div></section>'
      end
    end
    
    context "with a tag name and a class" do
      it "creates the html5 tag and a div with the class" do
        output = eval_erb <<-ERB
          <%= html5_tag(:section, :class => "primary") %>
        ERB
        output.strip.should == '<section><div class="section primary"></div></section>'
      end
    end
    
    context "with a tag name and a class and an id" do
      it "creates the html5 tag and a div with the class and an id" do
        output = eval_erb <<-ERB
          <%= html5_tag(:section, :class => "primary", :id => "footer") %>
        ERB
        output.strip.should == '<section><div class="section primary" id="footer"></div></section>'
      end
    end
    
    context "with a tag name and an arbitrary attribute" do
      it "creates the html5 tag with the attribute and a div with the attribute and the class" do
        output = eval_erb <<-ERB
          <%= html5_tag(:section, :class => "primary", :foo => "bar") %>
        ERB
        output.strip.should == '<section foo="bar"><div class="section primary" foo="bar"></div></section>'
      end
    end
    
    context "with a block" do
      it "creates the html5 tag, the inner div, and the yielded content" do
        output = eval_erb <<-ERB
          <% html5_tag(:section) do %><p>Hi there</p><% end %>
        ERB
        output.strip.should == '<section><div class="section"><p>Hi there</p></div></section>'
      end
    end
    
    context "with nested blocks" do
      it "creates the html5 tag, the inner div, and the yielded content" do
        output = eval_erb <<-ERB
          <% html5_tag(:article) do %><% html5_tag(:section) do %><% html5_tag :hgroup do %><h1>Hi there</h1><% end %><% end %><% end %>
        ERB
        output.strip.should == '<article><div class="article"><section><div class="section"><hgroup><div class="hgroup"><h1>Hi there</h1></div></hgroup></div></section></div></article>'
      end
    end
  end
  
  describe "section_tag" do
    it "should work like html5_tag(:section)" do
      section_tag_output = eval_erb <<-ERB
        <%= section_tag("Hi", :class => "start") %>
      ERB
      
      html5_tag_output = eval_erb <<-ERB
        <%= html5_tag(:section, "Hi", :class => "start") %>
      ERB
      
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
end