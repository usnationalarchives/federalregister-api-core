describe TextHelper do
  include TextHelper
  describe 'truncate_words' do
    it "returns nil if nil" do
      truncate_words(nil, :length => 40).should == nil
    end

    it "does nothing if string is less than the number of characters" do
      truncate_words("Howdy partner", :length => 40).should == "Howdy partner"
    end

    it "does nothing if string is equal to the number of characters" do
      truncate_words("Howdy partner", :length => 13).should == "Howdy partner"
    end

    it "limits to the specified number of characters, including omission text" do
      truncate_words("The cow jumped over the moon", :length => 23).should == "The cow jumped over..."
      truncate_words("The cow jumped over the moon", :length => 19).should == "The cow jumped..."
    end

    it "limits to the specified number of characters, ending early to prevent truncating a word" do
      truncate_words("The cow jumped over the moon", :length => 25).should == "The cow jumped over..."
      truncate_words("The cow jumped over the moon", :length => 18).should == "The cow jumped..."
    end
  end
end