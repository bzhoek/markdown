class MarkdownTextStorage < NSTextStorage

  def init
    super
    @backingStore = NSMutableAttributedString.new
    createStyles
    self
  end

  def createStyles
    @normal = {NSFontAttributeName => NSFont.fontWithName("Avenir Next", size: 17),
      NSBackgroundColorAttributeName => NSColor.whiteColor,
      NSStrikethroughStyleAttributeName => NSUnderlineStyleNone}

    font_manager = NSFontManager.sharedFontManager
    @paragraphs = {
      "^(#)\\s" => {NSFontAttributeName => font_manager.fontWithFamily("Avenir Next", traits: NSBoldFontMask, weight: 0, size: 38)},
      "^(##)\\s" => {NSFontAttributeName => font_manager.fontWithFamily("Avenir Next", traits: NSBoldFontMask, weight: 0, size: 30)},
      "^(###)\\s" => {NSFontAttributeName => font_manager.fontWithFamily("Avenir Next", traits: NSBoldFontMask, weight: 0, size: 23)},
      "^(####)\\s" => {NSFontAttributeName => font_manager.fontWithFamily("Avenir Next", traits: NSBoldFontMask, weight: 0, size: 17)},
      "^\\t" => {NSFontAttributeName => font_manager.fontWithFamily("Menlo", traits: 0, weight: 0, size: 15),
        NSBackgroundColorAttributeName => NSColor.lightGrayColor}
    }

    @replacements = {
      "(\\*\\w+(\\s\\w+)*\\*)\\s" => {NSFontAttributeName => font_manager.fontWithFamily("Avenir Next", traits: NSBoldFontMask, weight: 0, size: 17)},
      "(_\\w+(\\s\\w+)*_)\\s" => {NSFontAttributeName => font_manager.fontWithFamily("Avenir Next", traits: NSItalicFontMask, weight: 5, size: 17)},
      "(-\\w+(\\s\\w+)*-)\\s" => {NSFontAttributeName => font_manager.fontWithFamily("Avenir Next", traits: NSItalicFontMask, weight: 5, size: 17),
        NSStrikethroughStyleAttributeName => NSUnderlineStyleSingle},
      "(`\\w+(\\s\\w+)*`)\\s" => {NSFontAttributeName => font_manager.fontWithFamily("Menlo", traits: 0, weight: 5, size: 15),
        NSBackgroundColorAttributeName => NSColor.lightGrayColor}
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
    puts "editedRange: #{self.editedRange.inspect}"
    if self.editedRange.length == 1 && stringForRange(self.editedRange) == "\n"
      line = lineRangeForLocation(self.editedRange.location+1)
      puts "next: #{stringForRange(line).dump}"
      self.applyStylesToRange(line)
    end

    index = 0
    while index <= self.editedRange.length
      line = lineRangeForLocation(self.editedRange.location + index)
      puts "line: #{line.inspect}"
      puts "current: #{stringForRange(line).dump}"
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

  def applyStylesToRange(searchRange)
    puts "applyStylesToRange: #{searchRange.inspect}: #{stringForRange(searchRange)}"

    self.addAttributes(@normal, range: searchRange)
    @paragraphs.each do |expression, hash|
      regex = NSRegularExpression.regularExpressionWithPattern(expression, options: 0, error: nil)
      regex.enumerateMatchesInString(@backingStore.string, options: 0, range: searchRange,
        usingBlock: lambda do |match, flags, stop|
          self.addAttributes(hash, range: searchRange)
          if match.numberOfRanges > 1
            self.addAttributes({NSForegroundColorAttributeName => NSColor.lightGrayColor}, range: match.rangeAtIndex(1))
          end
        end
      )
    end

    @replacements.each do |expression, hash|
      regex = NSRegularExpression.regularExpressionWithPattern(expression, options: 0, error: nil)
      regex.enumerateMatchesInString(@backingStore.string, options: 0, range: searchRange,
        usingBlock: lambda do |match, flags, stop|
          matchRange = match.rangeAtIndex(1)
          self.addAttributes(hash, range: matchRange)
          if NSMaxRange(matchRange) + 1 < self.length
            self.addAttributes(@normal, range: NSMakeRange(NSMaxRange(matchRange) + 1, 1))
          end
        end
      )
    end

  end

end
