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

  def processEditing
    puts self.editedRange.inspect
    self.performReplacementsForRange(self.editedRange)
    super
  end

  def performReplacementsForRange(changedRange)
    extendedRange = NSUnionRange(changedRange, @backingStore.string.lineRangeForRange(NSMakeRange(changedRange.location, 0)))
    #extendedRange = NSUnionRange(changedRange, @backingStore.string.lineRangeForRange(NSMakeRange(NSMaxRange(changedRange), 0)))
    self.applyStylesToRange(extendedRange)
  end

  def applyStylesToRange(searchRange)
    boldFont = NSFontManager.sharedFontManager.fontWithFamily("Avenir Next", traits: NSBoldFontMask, weight: 0, size: 17)
    normalFont = NSFont.fontWithName("Avenir Next", size: 17)

    regexStr = "(\\*\\w+(\\s\\w+)*\\*)\\s"
    regex = NSRegularExpression.regularExpressionWithPattern(regexStr, options: 0, error: nil)

    boldAttributes = {NSFontAttributeName => boldFont}
    normalAttributes = {NSFontAttributeName => normalFont}

    regex.enumerateMatchesInString(@backingStore.string, options: 0, range: searchRange,
      usingBlock: lambda do |match, flags, stop|
        puts match.inspect
        matchRange = match.rangeAtIndex(1)
        self.addAttributes(boldAttributes, range: matchRange)
        if (NSMaxRange(matchRange) + 1 < self.length)
          self.addAttributes(normalAttributes, range: NSMakeRange(NSMaxRange(matchRange) + 1, 1))
        end
      end
    )
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
    attrs = {NSFontAttributeName => NSFont.fontWithName("Avenir Next", size: 17)}
    string = NSAttributedString.alloc.initWithString("Hello, world", attributes: attrs)

    bounds = @mainWindow.contentView.bounds

    containerSize = CGSizeMake(bounds.size.width, CGFLOAT_MAX)
    textContainer = NSTextContainer.alloc.initWithContainerSize(containerSize)
    textContainer.widthTracksTextView = true

    layoutManager = NSLayoutManager.alloc.init
    layoutManager.addTextContainer(textContainer)

    @textStorage = MarkdownTextStorage.alloc.init
    @textStorage.appendAttributedString(string)
    @textStorage.addLayoutManager(layoutManager)

    NSTextView.alloc.initWithFrame(bounds, textContainer: textContainer)
  end

end
