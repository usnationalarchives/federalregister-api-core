describe HtmlHelper do
  include HtmlHelper
  
  describe "modify_text_not_inside_anchor" do
    it "replaces text in a <p>" do
      result = modify_text_not_inside_anchor('<p>Hello world</p>') do |text|
        text.gsub(/Hello/, 'Hi')
      end
      
      result.should == '<p>Hi world</p>'
    end
    
    it "adds anchors in a <p>" do
      result = modify_text_not_inside_anchor('<p>Hello world</p>') do |text|
        text.gsub(/world/, '<a href="/">world</a>')
      end
      
      result.should == '<p>Hello <a href="/">world</a></p>'
    end
    
    it "doesn't adds anchors inside an <a>" do
      result = modify_text_not_inside_anchor('<p>Hello <a href="#">worldly folks</a></p>') do |text|
        text.gsub(/world/, '<a href="#">world</a>')
      end
      
      result.should == '<p>Hello <a href="#">worldly folks</a></p>'
    end
    
    it "adds anchors outside of an <a>" do
      result = modify_text_not_inside_anchor('<p>Hello <span>world</span> <a href="#">hello worldly folks</a> hello world</p>') do |text|
        text.gsub(/hello world/, '<a href="#">hello world</a>')
      end
      
      result.should == '<p>Hello <span>world</span> <a href="#">hello worldly folks</a> <a href="#">hello world</a></p>'
    end
    
  end
end