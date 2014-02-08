class MarkdownTextStorage < NSTextStorage

  include Styles

  def init
    super
    @backingStore = NSMutableAttributedString.new
    @file = "/Users/bas/sample.md"
    createStyles
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
    astring = NSAttributedString.alloc.initWithString(string)
    self.setAttributedString(astring)
  end

  def saveToFile
    @backingStore.string.writeToFile(@file, atomically: true)
  end

end
