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
    puts "edited: " + self.editedRange.inspect
    self.performReplacementsForRange(self.editedRange)
    super
  end

  def performReplacementsForRange(changedRange)
    lineRange = NSUnionRange(changedRange, @backingStore.string.lineRangeForRange(NSMakeRange(changedRange.location, 0)))
    #lineRange = NSUnionRange(changedRange, @backingStore.string.lineRangeForRange(NSMakeRange(NSMaxRange(changedRange), 0)))
    self.applyStylesToRange(lineRange)
  end

  def applyStylesToRange(searchRange)
    puts "search: " + searchRange.inspect
    normalFont = NSFont.fontWithName("Avenir Next", size: 17)

    replacements = {
      "(\\*\\w+(\\s\\w+)*\\*)\\s" => NSFontManager.sharedFontManager.fontWithFamily("Avenir Next", traits: NSBoldFontMask, weight: 0, size: 17),
      "(_\\w+(\\s\\w+)*_)\\s" => NSFontManager.sharedFontManager.fontWithFamily("Avenir Next", traits: NSItalicFontMask, weight: 0, size: 17),
      "(`\\w+(\\s\\w+)*`)\\s" => NSFontManager.sharedFontManager.fontWithFamily("Menlo", traits: 0, weight: 0, size: 17)
    }

    normalAttributes = {NSFontAttributeName => normalFont}

    replacements.each do |expression, font|
      regex = NSRegularExpression.regularExpressionWithPattern(expression, options: 0, error: nil)
      attributes = {NSFontAttributeName => font}
      regex.enumerateMatchesInString(@backingStore.string, options: 0, range: searchRange,
        usingBlock: lambda do |match, flags, stop|
          puts match.inspect
          matchRange = match.rangeAtIndex(1)
          self.addAttributes(attributes, range: matchRange)
          if NSMaxRange(matchRange) + 1 < self.length
            self.addAttributes(normalAttributes, range: NSMakeRange(NSMaxRange(matchRange) + 1, 1))
          end
        end
      )
    end

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
    string = NSAttributedString.alloc.initWithString("Hello, _world_ , say something *bold* and `quoted` .", attributes: attrs)

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
