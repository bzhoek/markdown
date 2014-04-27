class AttributedString

  def initialize(string)
    attrs = {NSFontAttributeName => NSFont.fontWithName("Avenir Next", size: 17)}
    @string = NSMutableAttributedString.alloc.initWithString(string, attributes: attrs)
  end

  def insert_image(path, index)
    image = NSImage.alloc.initWithContentsOfFile(path)
    raise "File #{path} not found" if image.nil?
    attachment = NSTextAttachment.alloc.init
    attachment.setAttachmentCell(NSTextAttachmentCell.alloc.initImageCell(image))
    string = NSAttributedString.attributedStringWithAttachment(attachment)
    @string.insertAttributedString(string, atIndex: index)
  end

  def has_attachments
    rangeLimit = NSMakeRange(0, @string.length)
    range = Pointer.new(NSRange.type)
    location = 0
    attributes = @string.attributesAtIndex(location, longestEffectiveRange: range, inRange: rangeLimit)
    attributes[:NSAttachment].class == NSTextAttachment
  end

end

describe "image" do

  before do
    @app = NSApplication.sharedApplication
  end

  # http://stackoverflow.com/questions/5300427/nstextview-insert-image-in-between-text

  it "should load an image" do
    pic = NSImage.alloc.initWithContentsOfFile("spec/bas.png")
    pic.should.not == nil

    attachmentCell = NSTextAttachmentCell.alloc.initImageCell(pic)
    attachment = NSTextAttachment.alloc.init
    attachment.setAttachmentCell(attachmentCell)
    attributedString = NSAttributedString.attributedStringWithAttachment(attachment)

    rangeLimit = NSMakeRange(0, attributedString.length)
    range = Pointer.new(NSRange.type)
    location = 0
    attributes = attributedString.attributesAtIndex(location, longestEffectiveRange: range, inRange: rangeLimit)
    attributes[:NSAttachment].class.should == NSTextAttachment
  end

  it "should find an attachment" do
    subject = AttributedString.new("bla")
    subject.has_attachments.should == false
    subject.insert_image("spec/bas.png", 0)
    subject.has_attachments.should == true
  end

  it "should raise an exception for missing image" do
    subject = AttributedString.new("bla")
    lambda { subject.insert_image("spec/404.png", 0) }.should.raise(RuntimeError)
  end

end
