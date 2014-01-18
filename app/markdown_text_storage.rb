class MarkdownTextStorage < NSTextStorage

  BACKGROUND = NSColor.colorWithCalibratedRed(239/255.0, green: 239/255.0, blue: 239/255.0, alpha: 1.0)
  TEXT = NSColor.colorWithCalibratedWhite(46/255.0, alpha: 1.0)
  LIGHT = NSColor.colorWithCalibratedWhite(168/255.0, alpha: 1.0)

  def init
    super
    @backingStore = NSMutableAttributedString.new
    createStyles
    self
  end

  def createStyles
    normal = NSMutableParagraphStyle.defaultParagraphStyle.mutableCopy
    normal.lineHeightMultiple = 1.2
    normal.headIndent = 30
    normal.tailIndent = -25
    normal.firstLineHeadIndent = 30

    @normal = {NSFontAttributeName => NSFont.fontWithName("Avenir Next", size: 17),
      NSForegroundColorAttributeName => TEXT,
      NSBackgroundColorAttributeName => BACKGROUND,
      NSStrikethroughStyleAttributeName => NSUnderlineStyleNone,
      NSParagraphStyleAttributeName => normal}

    heading = NSMutableParagraphStyle.defaultParagraphStyle.mutableCopy
    heading.lineHeightMultiple = 1.2
    heading.headIndent = 12
    heading.tailIndent = -25
    heading.firstLineHeadIndent = 12

    bullet = NSMutableParagraphStyle.defaultParagraphStyle.mutableCopy
    bullet.lineHeightMultiple = 1.2
    bullet.headIndent = 42
    bullet.tailIndent = -25
    bullet.firstLineHeadIndent = 30

    font_manager = NSFontManager.sharedFontManager
    @paragraphs = {
      "^(#)\\s" => [{NSFontAttributeName => font_manager.fontWithFamily("Avenir Next", traits: NSBoldFontMask, weight: 0, size: 23),
        NSParagraphStyleAttributeName => heading},
        {NSFontAttributeName => font_manager.fontWithFamily("Avenir Next", traits: NSUnboldFontMask, weight: 5, size: 23),
          NSForegroundColorAttributeName => LIGHT}],
      "^(##)\\s" => [{NSFontAttributeName => font_manager.fontWithFamily("Avenir Next", traits: NSBoldFontMask, weight: 0, size: 21)},
        {NSFontAttributeName => font_manager.fontWithFamily("Avenir Next", traits: NSUnboldFontMask, weight: 5, size: 21),
          NSForegroundColorAttributeName => LIGHT}],
      "^(###)\\s" => [{NSFontAttributeName => font_manager.fontWithFamily("Avenir Next", traits: NSBoldFontMask, weight: 0, size: 19)},
        {NSFontAttributeName => font_manager.fontWithFamily("Avenir Next", traits: NSUnboldFontMask, weight: 5, size: 19),
          NSForegroundColorAttributeName => LIGHT}],
      "^(####)\\s" => [{NSFontAttributeName => font_manager.fontWithFamily("Avenir Next", traits: NSBoldFontMask, weight: 0, size: 17)},
        {NSFontAttributeName => font_manager.fontWithFamily("Avenir Next", traits: NSUnboldFontMask, weight: 5, size: 17),
          NSForegroundColorAttributeName => LIGHT}],
      "^(\\*)\\s" => [
        {NSFontAttributeName => font_manager.fontWithFamily("Avenir Next", traits: NSUnboldFontMask, weight: 5, size: 17),
          NSParagraphStyleAttributeName => bullet},
        {NSFontAttributeName => font_manager.fontWithFamily("Avenir Next", traits: NSUnboldFontMask, weight: 5, size: 17),
          NSForegroundColorAttributeName => LIGHT}
      ],
      "^\\t" => [{NSFontAttributeName => font_manager.fontWithFamily("Menlo", traits: 0, weight: 0, size: 15),
        NSBackgroundColorAttributeName => NSColor.lightGrayColor}]
    }

    @replacements = {
      "(\\*)(\\w+(?:\\s\\w+)*)(\\*)\\s" => [
        {NSFontAttributeName => font_manager.fontWithFamily("Avenir Next", traits: NSUnboldFontMask, weight: 5, size: 17),
          NSForegroundColorAttributeName => LIGHT},
        {NSFontAttributeName => font_manager.fontWithFamily("Avenir Next", traits: NSBoldFontMask, weight: 0, size: 17)},
        {NSFontAttributeName => font_manager.fontWithFamily("Avenir Next", traits: NSUnboldFontMask, weight: 5, size: 17),
          NSForegroundColorAttributeName => LIGHT}
      ],
      "(_)(\\w+(?:\\s\\w+)*)(_)\\s" => [
        {NSFontAttributeName => font_manager.fontWithFamily("Avenir Next", traits: NSUnboldFontMask, weight: 5, size: 17),
          NSForegroundColorAttributeName => LIGHT},
        {NSFontAttributeName => font_manager.fontWithFamily("Avenir Next", traits: NSItalicFontMask, weight: 5, size: 17)},
        {NSFontAttributeName => font_manager.fontWithFamily("Avenir Next", traits: NSUnboldFontMask, weight: 5, size: 17),
          NSForegroundColorAttributeName => LIGHT}],
      "(-)(\\w+(?:\\s\\w+)*)(-)\\s" => [
        {NSFontAttributeName => font_manager.fontWithFamily("Avenir Next", traits: NSUnboldFontMask, weight: 5, size: 17),
          NSForegroundColorAttributeName => LIGHT},
        {NSFontAttributeName => font_manager.fontWithFamily("Avenir Next", traits: NSItalicFontMask, weight: 5, size: 17),
          NSStrikethroughStyleAttributeName => NSUnderlineStyleSingle},
        {NSFontAttributeName => font_manager.fontWithFamily("Avenir Next", traits: NSUnboldFontMask, weight: 5, size: 17),
          NSForegroundColorAttributeName => LIGHT}
      ],
      "(`)(\\w+(?:\\s\\w+)*)(`)\\s" => [
        {NSFontAttributeName => font_manager.fontWithFamily("Avenir Next", traits: NSUnboldFontMask, weight: 5, size: 17),
          NSForegroundColorAttributeName => LIGHT},
        {NSFontAttributeName => font_manager.fontWithFamily("Menlo", traits: 0, weight: 5, size: 15),
          NSBackgroundColorAttributeName => LIGHT},
        {NSFontAttributeName => font_manager.fontWithFamily("Avenir Next", traits: NSUnboldFontMask, weight: 5, size: 17),
          NSForegroundColorAttributeName => LIGHT}
      ]
    }
  end

  def string
    @backingStore.string
  end

  def attributesAtIndex(location, effectiveRange: range)
    @backingStore.attributesAtIndex(location, effectiveRange: range)
  end

  def replaceCharactersInRange(range, withString: str)
    puts "replaceCharactersInRange: #{NSStringFromRange(range)} withString: #{str}"

    groupEdits do
      @backingStore.replaceCharactersInRange(range, withString: str)
      self.edited(NSTextStorageEditedCharacters | NSTextStorageEditedAttributes, range: range, changeInLength: str.length - range.length)
    end
  end

  def setAttributes(attrs, range: range)
    #puts "setAttributes: #{attrs} range:#{NSStringFromRange(range)}"

    groupEdits do
      @backingStore.setAttributes(attrs, range: range)
      self.edited(NSTextStorageEditedAttributes, range: range, changeInLength: 0)
    end
  end

  def processEditing
    super
    processEditingRange(self.editedRange)
  end

  def processEditingRange(range)
    puts "editedRange: #{range.inspect}"
    if range.length == 1 && stringForRange(range) == "\n"
      line = lineRangeForLocation(range.location+1)
      puts "next: #{stringForRange(line).dump}"
      self.applyStylesToRange(line)
    end

    line = lineRangeForLocation(range.location)
    self.applyStylesToRange(line)

    index = line.length
    while index < range.length
      line = lineRangeForLocation(range.location + index)
      self.applyStylesToRange(line)
      index += line.length
    end
  end

  def lineRangeForLocation(location)
    @backingStore.string.lineRangeForRange(NSMakeRange(location, 0))
  end

  def stringForRange(range)
    @backingStore.string.substringWithRange(range)
  end

  def groupEdits
    self.beginEditing
    yield if block_given?
    self.endEditing
  end

  def applyStylesToRange(range)
    puts "applyStylesToRange: #{range.inspect}: #{stringForRange(range)}"

    self.addAttributes(@normal, range: range)

    applyParagraphStyles(range)
    applyCharacterStyles(range)
  end

  def applyParagraphStyles(range)
    @paragraphs.each do |expression, hash|
      regex = NSRegularExpression.regularExpressionWithPattern(expression, options: 0, error: nil)
      regex.enumerateMatchesInString(@backingStore.string, options: 0, range: range,
        usingBlock: lambda do |match, flags, stop|
          self.addAttributes(hash[0], range: range)
          if match.numberOfRanges > 1
            self.addAttributes(hash[1], range: match.rangeAtIndex(1))
          end
        end
      )
    end
  end

  def applyCharacterStyles(range)
    @replacements.each do |expression, hash|
      regex = NSRegularExpression.regularExpressionWithPattern(expression, options: 0, error: nil)
      regex.enumerateMatchesInString(@backingStore.string, options: 0, range: range,
        usingBlock: lambda do |match, flags, stop|
          raise "#{match.numberOfRanges} matches, but only #{hash.length} formats for #{expression}" if hash.length != match.numberOfRanges - 1
          hash.each_with_index do |format, i|
            self.addAttributes(format, range: match.rangeAtIndex(i+1))
          end
        end
      )
    end
  end

end
