class DocumentPrototype < NSCollectionViewItem
  def loadView
    self.setView(DocumentView.alloc.initWithFrame(NSZeroRect))
  end

  def setRepresentedObject(object)
    super(object)
    self.view.setViewObject(object)
  end
end

class DocumentView < NSView

  FORMATTER = NSDateFormatter.alloc.init
  FORMATTER.dateFormat = "dd/MM/yy"

  LIGHT = NSColor.colorWithCalibratedWhite(168/255.0, alpha: 1.0)

  attr_accessor :box, :title, :avatar

  def initWithFrame(rect)
    super(NSMakeRect(rect.origin.x, rect.origin.y, 180, 180))

    @box = NSBox.alloc.initWithFrame(NSInsetRect(self.bounds, 5, 3))
    @box.titlePosition = NSNoTitle
    self.addSubview(@box)

    @title = NSTextField.alloc.initWithFrame(NSMakeRect(0, 120, 160, 40))
    @title.font = NSFont.boldSystemFontOfSize(14)
    @title.bezeled = false
    @title.drawsBackground = false
    @title.editable = false
    @title.selectable = true
    @box.addSubview(@title)

    @summary = NSTextField.alloc.initWithFrame(NSMakeRect(0, 0, 160, 120))
    @summary.bezeled = false
    @summary.drawsBackground = false
    @summary.editable = false
    @summary.selectable = false
    @summary.bezeled = true
    @box.addSubview(@summary)

    self
  end

  def update_title
    title = @object.name.lastPathComponent.stringByDeletingPathExtension
    heading = NSMutableParagraphStyle.defaultParagraphStyle.mutableCopy
    heading.lineBreakMode = NSLineBreakByWordWrapping
    attrs = {NSParagraphStyleAttributeName => heading}
    @title.attributedStringValue = NSAttributedString.alloc.initWithString(title, attributes: attrs)
  end

  def update_summary
    heading = NSMutableParagraphStyle.defaultParagraphStyle.mutableCopy
    heading.lineBreakMode = NSLineBreakByWordWrapping
    attrs = {NSParagraphStyleAttributeName => heading}
    date = "#{FORMATTER.stringFromDate(@object.modified)}"
    string = NSMutableAttributedString.alloc.initWithString("#{date} #{@object.summary}", attributes: attrs)
    string.addAttributes({NSForegroundColorAttributeName => LIGHT}, range: NSMakeRange(0, date.length))
    @summary.attributedStringValue = string
  end

  def setViewObject(object)
    return if object.nil?
    @object = object
    @object.addObserver(self, forKeyPath: "summary", options: NSKeyValueObservingOptionNew, context: nil)
    update_title
    update_summary
  end

  def observeValueForKeyPath(path, ofObject: object, change: change, context: context)
    update_summary
  end

  def mouseDown(event)
    NSApp.delegate.loadDocument(@object.name)
  end

end
