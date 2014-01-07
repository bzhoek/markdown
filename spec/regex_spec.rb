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

end
