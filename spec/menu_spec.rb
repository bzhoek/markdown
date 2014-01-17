describe "menu" do

  before do
    @app = NSApplication.sharedApplication
  end

  it "should get a menu item" do
    @app.mainMenu.class.should == NSMenu
    file = @app.mainMenu.itemWithTitle('File')
    save = file.submenu.itemWithTitle('Save…')
    save.class.should == NSMenuItem
  end

end
