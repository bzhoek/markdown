describe "image" do

  before do
    @subject = AttributedString.new("bla")
  end

  it "should find an attachment" do
    @subject.has_attachments.should == false
    @subject.insert_image("spec/bas.png", 1)
    @subject.has_attachments.should == true
  end

  it "should raise an exception for missing image" do
    lambda { @subject.insert_image("spec/404.png", 0) }.should.raise(RuntimeError)
  end

end
