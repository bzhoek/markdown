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
    puts "replaceCharactersInRange: #{NSStringFromRange(range)} withString: #{str}"

    self.beginEditing
    @backingStore.replaceCharactersInRange(range, withString: str)
    self.edited(NSTextStorageEditedCharacters | NSTextStorageEditedAttributes, range: range, changeInLength: str.length - range.length)
    self.endEditing
  end

  def setAttributes(attrs, range: range)
    puts "setAttributes: #{attrs} range:#{NSStringFromRange(range)}"

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
    attrs = {NSFontAttributeName: NSFont.fontWithName("Helvetica", size: 15)}
    string = NSAttributedString.alloc.initWithString("Hello, world", attributes: attrs)
    @textStorage = MarkdownTextStorage.alloc.init
    @textStorage.appendAttributedString(string)

    bounds = @mainWindow.contentView.bounds

    layoutManager = NSLayoutManager.alloc.init
    @textStorage.addLayoutManager(layoutManager)

    containerSize = CGSizeMake(bounds.size.width, CGFLOAT_MAX)
    textContainer = NSTextContainer.alloc.initWithContainerSize(containerSize)
    textContainer.widthTracksTextView = true

    layoutManager.addTextContainer(textContainer)
    layoutManager.replaceTextStorage(@textStorage)

    NSTextView.alloc.initWithFrame(bounds, textContainer: textContainer)
  end

end
