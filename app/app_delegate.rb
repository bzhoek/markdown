class MarkdownTextStorage < NSTextStorage

  def init
    super
    @backingStore = NSMutableAttributedString.new
    self
  end

  def string
    @backingStore.string
  end

  def attributesAtIndex(location, effectiveRange: range)
    @backingStore.attributesAtIndex(location, effectiveRange: range)
  end

  def replaceCharactersInRange(range, withString: str)
    #NSLog(@"replaceCharactersInRange:%@ withString:%@", NSStringFromRange(range), str);

    self.beginEditing
    @backingStore.replaceCharactersInRange(range, withString: str)
    self.edited(NSTextStorageEditedCharacters | NSTextStorageEditedAttributes, range: range, changeInLength: str.length - range.length)
    self.endEditing
  end

  def setAttributes(attrs, range: range)
    #NSLog(@"setAttributes:%@ range:%@", attrs, NSStringFromRange(range));

    self.beginEditing
    @backingStore.setAttributes(attrs, range: range)
    self.edited(NSTextStorageEditedAttributes, range: range, changeInLength: 0)
    self.endEditing
  end

end

class AppDelegate

  def applicationDidFinishLaunching(notification)
    buildMenu
    buildWindow
  end

  def buildWindow
    @mainWindow = NSWindow.alloc.initWithContentRect([[240, 180], [480, 360]],
      styleMask: NSTitledWindowMask|NSClosableWindowMask|NSMiniaturizableWindowMask|NSResizableWindowMask,
      backing: NSBackingStoreBuffered,
      defer: false)
    @mainWindow.title = NSBundle.mainBundle.infoDictionary['CFBundleName']
    @mainWindow.orderFrontRegardless

    @textView = createTextView

    @mainWindow.contentView.addSubview(@textView)
  end

  def createTextView
    attrs = {NSFontAttributeName: NSFont.fontWithName("Helvetica", size: 12)}
    string = NSAttributedString.alloc.initWithString("Hello, world", attributes: attrs)

    bounds = @mainWindow.contentView.bounds

    containerSize = CGSizeMake(bounds.size.width, CGFLOAT_MAX)
    textContainer = NSTextContainer.alloc.initWithContainerSize(containerSize)
    textContainer.widthTracksTextView = true

    layoutManager = NSLayoutManager.alloc.init
    layoutManager.addTextContainer(textContainer)

    textStorage = MarkdownTextStorage.new
    textStorage.appendAttributedString(string)
    textStorage.addLayoutManager(layoutManager)

    textView = NSTextView.alloc.initWithFrame(bounds, textContainer: textContainer)
    textView.editable = true
    textView
  end

end
