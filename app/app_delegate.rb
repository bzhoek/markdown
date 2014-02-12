class AppDelegate

  BACKGROUND = NSColor.colorWithCalibratedRed(239/255.0, green: 239/255.0, blue: 239/255.0, alpha: 1.0)

  Document = Struct.new(:name, :modified, :message, :avatar, :url)

  def applicationDidFinishLaunching(notification)
    buildMenu
    buildWindow
  end

  def buildWindow
    @window = NSWindow.alloc.initWithContentRect([[240, 180], [600, 800]],
      styleMask: NSTitledWindowMask|NSClosableWindowMask|NSMiniaturizableWindowMask|NSResizableWindowMask,
      backing: NSBackingStoreBuffered,
      defer: false)
    @window.title = NSBundle.mainBundle.infoDictionary['CFBundleName']
    @window.orderFrontRegardless

    @scrollView = buildSplitView
    @window.contentView= @scrollView
    @window.makeFirstResponder(@scrollView)
  end

  def buildSplitView
    splitView = NSSplitView.alloc.initWithFrame(@window.contentView.bounds)
    splitView.addSubview(buildCollectionView)
    splitView.addSubview(buildMarkdownView)
    splitView.vertical = true
    splitView.delegate = self
    splitView.setPosition(200, ofDividerAtIndex: 0)
    splitView.adjustSubviews
    splitView
  end

  def splitView(sender, resizeSubviewsWithOldSize: size)
    puts sender.inspect
    leftView = sender.subviews.objectAtIndex(0)
    rightView = sender.subviews.objectAtIndex(1)

    splitRect = sender.frame
    dividerThickness = sender.dividerThickness

    leftRect = leftView.frame
    rightRect = rightView.frame

    leftRect.size.height = splitRect.size.height
    leftRect.origin = NSMakePoint(0, 0)
    rightRect.size.width = splitRect.size.width - leftRect.size.width - dividerThickness
    rightRect.size.height = splitRect.size.height
    rightRect.origin.x = leftRect.size.width + dividerThickness

    leftView.frame = leftRect
    rightView.frame = rightRect
  end

  def buildCollectionView
    scroll_view = NSScrollView.alloc.initWithFrame(@window.contentView.frame)
    scroll_view.hasVerticalScroller = true

    @collection_view = NSCollectionView.alloc.initWithFrame(scroll_view.frame)
    @collection_view.setItemPrototype(DocumentPrototype.new)

    scroll_view.documentView = @collection_view
    @data = []
    @data << Document.new("Registration keys for software", Date.of(2014, 2, 2), "message", "avatar", "url")
    #@data << Document.new("Cone of uncertainty", Date.new(2014, 1, 3), "message", "avatar", "url")
    #@data << Document.new("Laura", Date.new(2013, 12, 25), "message", "avatar", "url")
    #@data << Document.new("OS X Shortcuts", Date.new(2013, 12, 24), "message", "avatar", "url")
    #@data << Document.new("Angular promise", Date.new(2013, 12, 24), "message", "avatar", "url")
    #@data << Document.new("Agile Atlas", Date.new(2013, 12, 11), "message", "avatar", "url")
    @collection_view.setContent(@data)

    #@window.contentView.addSubview(scroll_view)
    scroll_view
  end

  def buildMarkdownView
    scrollView = NSScrollView.alloc.initWithFrame(@window.contentView.frame)
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
    string = NSAttributedString.alloc.initWithString("# Start\nHello, _world_ , -strike- that, but say something *bold* and `quoted` .\n\n *  You would expect multi-line bullets to indent over multple lines\n\tThis is code\n\tAnd this too", attributes: attrs)

    containerSize = CGSizeMake(contentSize.width, CGFLOAT_MAX)
    textContainer = NSTextContainer.alloc.initWithContainerSize(containerSize)
    textContainer.widthTracksTextView = true

    layoutManager = NSLayoutManager.alloc.init
    layoutManager.addTextContainer(textContainer)

    @textStorage = MarkdownTextStorage.alloc.init
    @textStorage.setAttributedString(string)
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
    textView.textContainerInset = CGSizeMake(12, 12)
    textView
  end

  def saveDocument(sender)
    @textStorage.saveToFile()
  end

  def openDocument(sender)
    panel = NSOpenPanel.openPanel
    panel.allowsMultipleSelection = false
    if panel.runModalForDirectory(NSHomeDirectory(), file: nil, types: nil) == NSOKButton
      filename = panel.filenames[0]
      @textStorage.loadFromFile(filename)
      @window.title = NSFileManager.defaultManager.displayNameAtPath(filename)
      #  http://www.cocoabuilder.com/archive/cocoa/44759-programatically-opening-an-nsdocument-subclass.html
    end
  end

end

class Date
  FORMATTER = NSDateFormatter.alloc.init
  FORMATTER.dateFormat = "yyyy-MM-dd"

  def self.parse(string)
    FORMATTER.dateFromString(string)
  end

  def self.of(year, month, day)
    parse("#{year}-#{month}-#{day}")
  end

end