class MarkdownTextStorage < NSTextStorage

  include Styles

  def init
    super.tap do
      @backingStore = NSMutableAttributedString.new
      @file = "/Users/bas/sample.md"
      createStyles
    end
  end

  def file
    @file
  end

  def string
    @backingStore.string
  end

  def length
    @backingStore.length
  end

  def attributesAtIndex(location, effectiveRange: range)
    @backingStore.attributesAtIndex(location, effectiveRange: range)
  end

  def replaceCharactersInRange(range, withString: str)
    NSLog("replaceCharactersInRange: #{range.inspect} #{NSStringFromRange(range)} withString: #{str} length #{str.length}")

    groupEdits do
      @backingStore.replaceCharactersInRange(range, withString: str)
      self.edited(NSTextStorageEditedCharacters | NSTextStorageEditedAttributes, range: range, changeInLength: str.length - range.length)
    end
  end

  def setAttributes(attrs, range: range)
    NSLog("setAttributes: #{attrs} line:#{NSStringFromRange(range)}")

    groupEdits do
      @backingStore.setAttributes(attrs, range: range)
      self.edited(NSTextStorageEditedAttributes, range: range, changeInLength: 0)
    end
  end

  def processEditing
    processEditingRange(self.editedRange)
    super
  end

  def processEditingRange(range)
    NSLog("processEditingRange 1: #{range.inspect}")
    if range.length == 1 && stringForRange(range) == "\n"
      line = lineRangeForLocation(range.location+1)
      NSLog("next: #{stringForRange(line).dump}")
      self.applyStylesToLine(line)
    end

    line = lineRangeForLocation(range.location)
    NSLog("processEditingRange 2: #{line.inspect}")
    self.applyStylesToLine(line)

    index = line.length
    while index < range.length
      line = lineRangeForLocation(range.location + index)
      NSLog("processEditingRange 3: #{line.inspect}")
      self.applyStylesToLine(line)
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

  def applyStylesToLine(line)
    NSLog("applyStylesToLine: #{line.inspect}: #{stringForRange(line)}")

    self.addAttributes(@normal, range: line)

    applyParagraphStyles(line)
    applyImageCommands(line)
    applyCharacterStyles(line)
  end

  def applyImageCommands(line)
    regex = NSRegularExpression.regularExpressionWithPattern("\\!\\((.+?)\\)", options: 0, error: nil)
    regex.enumerateMatchesInString(@backingStore.string, options: 0, range: line,
      usingBlock: lambda do |match, flags, stop|
        range_at_index = match.rangeAtIndex(1)
        NSLog(range_at_index.inspect)
        path = stringForRange(range_at_index)
        image = NSImage.alloc.initWithContentsOfFile(path)
        attachment = NSTextAttachment.alloc.init
        attachment.setAttachmentCell(NSTextAttachmentCell.alloc.initImageCell(image))
        string = NSAttributedString.attributedStringWithAttachment(attachment)
        NSLog("#{@backingStore.length}")
        @backingStore.insertAttributedString(string, atIndex: line.location)
        NSLog("#{@backingStore.length}")
      end
    )
  end

  def applyParagraphStyles(range)
    @paragraphs.each do |expression, hash|
      regex = NSRegularExpression.regularExpressionWithPattern(expression, options: 0, error: nil)
      regex.enumerateMatchesInString(@backingStore.string, options: 0, range: range,
        usingBlock: lambda do |match, flags, stop|
          if match.numberOfRanges > 1
            slice = stringForRange(match.rangeAtIndex(1))
            paragraph = NSMutableParagraphStyle.defaultParagraphStyle.mutableCopy
            paragraph.lineHeightMultiple = 1.2
            paragraph.headIndent = slice.sizeWithAttributes(hash[1]).width
            self.addAttributes(hash[0].merge({NSParagraphStyleAttributeName => paragraph}), range: range)

            self.addAttributes(hash[1], range: match.rangeAtIndex(1))
          else
            self.addAttributes(hash[0], range: range)
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

  def loadFromFile(file)
    @file = file
    string = NSString.alloc.initWithContentsOfFile(file)
    self.setAttributedString(NSAttributedString.alloc.initWithString(string))
  end

  def saveToFile
    @backingStore.string.writeToFile(@file, atomically: true)
  end

end
