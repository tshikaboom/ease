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
	/**
	 * The main toolbar of an {@link EditorWindow}
	 *
	 * MainToolbar exists solely to be added to the top of an
	 * {@link EditorWindow}. Creating a subclass of Gtk.Toolbar keeps the
	 * {@link EditorWindow} source somewhat cleaner, and allows for easy
	 * changes to the toolbar.
	 */
	public class MainToolbar : Gtk.Toolbar
	{
		public Gtk.ToolButton new_slide;
		public Gtk.ToolButton play;
		public Gtk.ToolButton save;
		public Gtk.ToolButton new_presentation;
		public Gtk.ToolButton open;
		public Gtk.ToolButton inspector;
		public Gtk.ToolButton slides;
		public Gtk.ToolButton fonts;
		public Gtk.ToolButton colors;
		
		/**
		 * Builds the main toolbar of an {@link EditorWindow}.
		 * 
		 * All fields are public, allowing the {@link EditorWindow} to attach
		 * signal handlers.
		 * 
		 */
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
			colors = new Gtk.ToolButton.from_stock("gtk-select-color");
			fonts = new Gtk.ToolButton.from_stock("gtk-select-font");
			
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
			insert(new Gtk.SeparatorToolItem(), -1);
			insert(fonts, -1);
			insert(colors, -1);
			
			// format toolbar
			toolbar_style = Gtk.ToolbarStyle.ICONS;
		}
	}
}
