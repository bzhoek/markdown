class AttributedString

  def initialize(string)
    attrs = {NSFontAttributeName => NSFont.fontWithName("Avenir Next", size: 17)}
    @string = NSMutableAttributedString.alloc.initWithString(string, attributes: attrs)
  end

  # http://stackoverflow.com/questions/5300427/nstextview-insert-image-in-between-text
  def insert_image(path, index)
    image = NSImage.alloc.initWithContentsOfFile(path)
    raise "File #{path} not found" if image.nil?

    attachment = NSTextAttachment.alloc.init
    attachment.setAttachmentCell(NSTextAttachmentCell.alloc.initImageCell(image))

    @string.insertAttributedString(NSAttributedString.attributedStringWithAttachment(attachment), atIndex: index)
  end

  def has_attachments
    (0..@string.length-1).each { |location|
      attributes = @string.attributesAtIndex(location, effectiveRange: nil)
      return true if attributes[:NSAttachment].class == NSTextAttachment
    }
    false
  end

end

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
