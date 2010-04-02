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
	public class Slide
	{
		public Gee.ArrayList<Element> elements { get; set; }
		public string transition { get; set; }
		public string variant { get; set; }
		public Clutter.Color background_color;
		public string background_image { get; set; }
		public Document parent { get; set; }
		
		public Slide(Document owner)
		{
			parent = owner;
		}
		
		public string to_xml()
		{
			string output = "\t\t<slide " +
			                "transition=\"" + transition + "\" " +
			                "variant=\"" + variant + "\" " +
			                (background_image != null ?
			                                        ("background_image=\"" + background_image + "\" ") :
			                                        ("background_color=\"" + background_color.to_string() + "\" ")) +
			                ">\n";
			
			foreach (var e in elements)
			{
				output += e.to_xml();
			}
			
			output += "</slide>\n";
			return output;
		}
	}
}