require 'java'
require File.dirname(__FILE__) + "/swt.jar"

class Smirch
  import "org.eclipse.swt.SWT"
  import "org.eclipse.swt.layout.GridLayout"
  import "org.eclipse.swt.layout.GridData"
  include_package "org.eclipse.swt.widgets"

  def initialize
    @display = Display.new
    @shell = Shell.new(@display)
    @grid_layout = GridLayout.new(1, true)
    @shell.layout = @grid_layout

    black = @display.system_color(SWT::COLOR_BLACK)
    white = @display.system_color(SWT::COLOR_WHITE)
    @chat_area = Text.new(@shell, SWT::BORDER | SWT::MULTI | SWT::READ_ONLY)
    @chat_area.layout_data = GridData.new(GridData::FILL, GridData::FILL, true, true)
    @chat_area.background = black
    @chat_area.foreground = white

    @input_box = Text.new(@shell, SWT::BORDER)
    grid_data = GridData.new(GridData::FILL, GridData::FILL, true, false)
    grid_data.heightHint = 25
    @input_box.layout_data = grid_data
  end

  def main_loop
    @shell.open
    while (!@shell.disposed?) do
      @display.sleep   if !@display.read_and_dispatch
    end
    @display.dispose
  end
end
