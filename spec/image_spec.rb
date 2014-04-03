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

end
