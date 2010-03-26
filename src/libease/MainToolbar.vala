/*  Ease, a GTK presentation application
    Copyright (C) 2010 Nate Stedman

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

namespace Ease
{
	public class MainToolbar : Gtk.Toolbar
	{
		public Gtk.ToolButton new_slide;
		public Gtk.ToolButton play;
		public Gtk.ToolButton save;
		public Gtk.ToolButton new_presentation;
		public Gtk.ToolButton open;
		public Gtk.ToolButton inspector;
		public Gtk.ToolButton slides;
	
		public MainToolbar()
		{
			// tool buttons
			new_slide = new Gtk.ToolButton.from_stock("gtk-add");
			play = new Gtk.ToolButton.from_stock("gtk-media-play");
			new_presentation = new Gtk.ToolButton.from_stock("gtk-new");
			save = new Gtk.ToolButton.from_stock("gtk-save");
			open = new Gtk.ToolButton.from_stock("gtk-open");
			slides = new Gtk.ToolButton.from_stock("gtk-dnd-multiple");
			inspector = new Gtk.ToolButton.from_stock("gtk-info");
			
			// add buttons
			insert(new_slide, -1);
			insert(play, -1);
			insert(new Gtk.SeparatorToolItem(), -1);
			insert(new_presentation, -1);
			insert(open, -1);
			insert(save, -1);
			insert(new Gtk.SeparatorToolItem(), -1);
			insert(slides, -1);
			insert(inspector, -1);
			
			// format toolbar
			toolbar_style = Gtk.ToolbarStyle.ICONS;
		}
	}
}
