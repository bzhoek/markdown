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

    @textView = buildTextView
    @mainWindow.contentView.addSubview(@textView)
    @mainWindow.makeFirstResponder(@textView)
  end


  def buildTextView
    attrs = {NSFontAttributeName => NSFont.fontWithName("Avenir Next", size: 17)}
    string = NSAttributedString.alloc.initWithString("# Start\nHello, _world_ , -strike- that, but say something *bold* and `quoted` .", attributes: attrs)

    bounds = @mainWindow.contentView.bounds

    containerSize = CGSizeMake(bounds.size.width, CGFLOAT_MAX)
    textContainer = NSTextContainer.alloc.initWithContainerSize(containerSize)
    textContainer.widthTracksTextView = true

    layoutManager = NSLayoutManager.alloc.init
    layoutManager.addTextContainer(textContainer)

    @textStorage = MarkdownTextStorage.alloc.init
    @textStorage.appendAttributedString(string)
    @textStorage.addLayoutManager(layoutManager)

    textView = NSTextView.alloc.initWithFrame(bounds, textContainer: textContainer)
    textView.allowsUndo = true
    textView.setSelectedRange(NSMakeRange(2, 0))
    textView
  end

end
