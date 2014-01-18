describe "regular expressions" do

  it "recognizes headers" do
    str = "## Heading"
    regex = NSRegularExpression.regularExpressionWithPattern("^(#+)\\s", options: 0, error: nil)
    regex.enumerateMatchesInString(str, options: 0, range: NSMakeRange(0, str.length),
      usingBlock: lambda do |match, flags, stop|
        str.substringWithRange(match.rangeAtIndex(1)).length.should == 2
      end
    )
  end

  it "captures nested groups" do
    str = "Sample `code` format."
    regex = NSRegularExpression.regularExpressionWithPattern("(`)(\\w+(?:\\s\\w+)*)(`)\\s", options: 0, error: nil)
    regex.enumerateMatchesInString(str, options: 0, range: NSMakeRange(0, str.length),
      usingBlock: lambda do |match, flags, stop|
        match.numberOfRanges.should == 4
        str.substringWithRange(match.rangeAtIndex(2)).should == "code"
      end
    )
  end

  it "counts lines in a string" do
    str = "# Start\nHello, _world_ , -strike- that, but say something *bold* and `quoted` ."
    lines = 0
    index = 0
    while index < str.length
      lines += 1
      index = NSMaxRange(str.lineRangeForRange(NSMakeRange(index, 0)))
    end
    lines.should == 2
  end

end
