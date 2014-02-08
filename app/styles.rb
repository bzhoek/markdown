module Styles

  BACKGROUND = NSColor.colorWithCalibratedRed(239/255.0, green: 239/255.0, blue: 239/255.0, alpha: 1.0)
  TEXT = NSColor.colorWithCalibratedWhite(46/255.0, alpha: 1.0)
  LIGHT = NSColor.colorWithCalibratedWhite(168/255.0, alpha: 1.0)

  def createStyles
    normal = NSMutableParagraphStyle.defaultParagraphStyle.mutableCopy
    normal.lineHeightMultiple = 1.2

    @normal = {NSFontAttributeName => NSFont.fontWithName("Avenir Next", size: 17),
      NSForegroundColorAttributeName => TEXT,
      NSBackgroundColorAttributeName => BACKGROUND,
      NSStrikethroughStyleAttributeName => NSUnderlineStyleNone,
      NSParagraphStyleAttributeName => normal}

    heading = NSMutableParagraphStyle.defaultParagraphStyle.mutableCopy
    heading.lineHeightMultiple = 1.2
    heading.headIndent = 12

    bullet = NSMutableParagraphStyle.defaultParagraphStyle.mutableCopy
    bullet.lineHeightMultiple = 1.2
    bullet.headIndent = 12

    font_manager = NSFontManager.sharedFontManager
    @paragraphs = {
      "^(#\\s+)\\w" => [
        {NSFontAttributeName => font_manager.fontWithFamily("Avenir Next", traits: NSBoldFontMask, weight: 0, size: 23),
          NSParagraphStyleAttributeName => heading},
        {NSFontAttributeName => font_manager.fontWithFamily("Avenir Next", traits: NSUnboldFontMask, weight: 5, size: 23),
          NSForegroundColorAttributeName => LIGHT}
      ],
      "^(##\\s+)\\w" => [
        {NSFontAttributeName => font_manager.fontWithFamily("Avenir Next", traits: NSBoldFontMask, weight: 0, size: 21)},
        {NSFontAttributeName => font_manager.fontWithFamily("Avenir Next", traits: NSUnboldFontMask, weight: 5, size: 21),
          NSForegroundColorAttributeName => LIGHT}
      ],
      "^(###\\s+)\\w" => [
        {NSFontAttributeName => font_manager.fontWithFamily("Avenir Next", traits: NSBoldFontMask, weight: 0, size: 19)},
        {NSFontAttributeName => font_manager.fontWithFamily("Avenir Next", traits: NSUnboldFontMask, weight: 5, size: 19),
          NSForegroundColorAttributeName => LIGHT}
      ],
      "^(####\\s+)\\w" => [
        {NSFontAttributeName => font_manager.fontWithFamily("Avenir Next", traits: NSBoldFontMask, weight: 0, size: 17)},
        {NSFontAttributeName => font_manager.fontWithFamily("Avenir Next", traits: NSUnboldFontMask, weight: 5, size: 17),
          NSForegroundColorAttributeName => LIGHT}
      ],
      "^(\\s*\\*\\s+)\\w" => [
        {NSFontAttributeName => font_manager.fontWithFamily("Avenir Next", traits: NSUnboldFontMask, weight: 5, size: 17),
          NSParagraphStyleAttributeName => bullet},
        {NSFontAttributeName => font_manager.fontWithFamily("Avenir Next", traits: NSUnboldFontMask, weight: 5, size: 17),
          NSForegroundColorAttributeName => LIGHT}
      ],
      "^(\\t)" => [
        {NSFontAttributeName => font_manager.fontWithFamily("Menlo", traits: 0, weight: 0, size: 15),
          NSBackgroundColorAttributeName => NSColor.lightGrayColor},
        {NSFontAttributeName => font_manager.fontWithFamily("Menlo", traits: 0, weight: 0, size: 15),
          NSBackgroundColorAttributeName => BACKGROUND}
      ]
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

end