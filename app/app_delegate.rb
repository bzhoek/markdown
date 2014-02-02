class AppDelegate

  BACKGROUND = NSColor.colorWithCalibratedRed(239/255.0, green: 239/255.0, blue: 239/255.0, alpha: 1.0)

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

    @scrollView = buildScrollView
    @mainWindow.contentView= @scrollView
    @mainWindow.makeFirstResponder(@scrollView)
  end


  def buildScrollView
    scrollView = NSScrollView.alloc.initWithFrame(@mainWindow.contentView.frame)
    contentSize = scrollView.contentSize
    scrollView.borderType = NSNoBorder
    scrollView.hasVerticalScroller = true
    scrollView.hasHorizontalScroller= false
    scrollView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable
    scrollView.documentView = buildTextView(contentSize)
    scrollView
  end

  def buildTextView(contentSize)
    attrs = {NSFontAttributeName => NSFont.fontWithName("Avenir Next", size: 17)}
    string = NSAttributedString.alloc.initWithString("# Start\nHello, _world_ , -strike- that, but say something *bold* and `quoted` .\n\n* You would expect multi-line bullets to indent\n\tThis is code\n\tAnd this too", attributes: attrs)

    containerSize = CGSizeMake(contentSize.width, CGFLOAT_MAX)
    textContainer = NSTextContainer.alloc.initWithContainerSize(containerSize)
    textContainer.widthTracksTextView = true

    layoutManager = NSLayoutManager.alloc.init
    layoutManager.addTextContainer(textContainer)

    @textStorage = MarkdownTextStorage.alloc.init
    @textStorage.appendAttributedString(string)
    @textStorage.addLayoutManager(layoutManager)

    textView = NSTextView.alloc.initWithFrame(NSMakeRect(0, 0, contentSize.width, contentSize.height), textContainer: textContainer)
    textView.allowsUndo = true
    textView.setSelectedRange(NSMakeRange(2, 0))
    textView.minSize = NSMakeSize(0, contentSize.height)
    textView.maxSize = NSMakeSize(CGFLOAT_MAX, CGFLOAT_MAX)
    textView.verticallyResizable = true
    textView.horizontallyResizable = false
    textView.autoresizingMask = NSViewWidthSizable
    textView.backgroundColor = BACKGROUND
    textView
  end

  def saveDocument(sender)
    puts sender
  end

  def openDocument(sender)
    panel = NSOpenPanel.openPanel
    panel.allowsMultipleSelection = false
    if panel.runModalForDirectory(NSHomeDirectory(), file: nil, types: nil) == NSOKButton
      puts panel.filenames
    end
  end

end
