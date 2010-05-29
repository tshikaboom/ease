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

/**
 * The internal representation of a slide
 *
 * A Slide is owned by a {@link Document} and has {@link Element}
 * children. The currently selected Slide is often acted upon by an
 * {@link EditorWindow}.
 */
public class Ease.Slide
{
	/**
	 * The {@link Element}s contained by this Slide
	 */
	public Gee.ArrayList<Element> elements = new Gee.ArrayList<Element>();
	
	/**
	 * The Slide's transition
	 */
	public TransitionType transition { get; set; }
	
	/**
	 * The variant (if any) of the Slide's transition
	 */
	public TransitionVariant variant { get; set; }
	
	/**
	 * The duration of this Slide's transition
	 */
	public double transition_time { get; set; }
	
	/**
	 * The background color, if there is no background image
	 */
	public Clutter.Color background_color;
	
	/**
	 * The background image, if one is set
	 */
	public string background_image { get; set; }
	
	/**
	 * The {@link Document} that this Slide is part of
	 */
	public Document parent { get; set; }
	
	/**
	 * The number of {@link Element}s on this Slide
	 */
	public int count { get { return elements.size; } }
	
	/**
	 * Create a new Slide.
	 */
	public Slide() {}
	
	/**
	 * Create a new Slide assigned to a {@link Document}.
	 * 
	 * Used for loading previously saved files. 
	 *
	 * @param owner The {@link Document} this slide is a part of.
	 */
	public Slide.with_owner(Document owner)
	{
		parent = owner;
	}
	
	public void add_element(int index, Element e)
	{
		e.parent = this;
		elements.insert(index, e);
	}
	
	/**
	 * Outputs this Slide to XML.
	 * 
	 * This returns a <slide> tag containing information soecific to the
	 * Slide and a tag for each {@link Element}.
	 */
	public string to_xml()
	{
		string output = "\t\t<slide " +
		                "transition=\"" + transition + "\" " +
		                "variant=\"" + variant + "\" " +
		                "time=\"" + transition_time.to_string() + "\" " +
		                (background_image != null ?
                                ("background_image=\"" +
                                 background_image + "\" ") :
                                ("background_color=\"" +
                                 background_color.to_string()
                                 + "\" ")) + ">\n";
		
		foreach (var e in elements)
		{
			output += e.to_xml();
		}
		
		output += "</slide>\n";
		return output;
	}
	
	/**
	 * Creates HTML markup for this Slide.
	 * 
	 * The <div> tag for this Slide is appended to the "HTML" parameter.
	 *
	 * @param html The HTML string in its current state.
	 * @param exporter The {@link HTMLExporter}, for the path and progress.
	 * @param amount The amount progress should increase by when done.
	 * @param index The index of this slide.
	 */
	public void to_html(ref string html,
	                    HTMLExporter exporter,
	                    double amount,
	                    int index)
	{
		// create the slide opening tag
		html += "<div class=\"slide\" id=\"slide" +
		        index.to_string() + "\" ";
		
		if (background_image == null)
		{
			// give the slide a background color
			html += "style=\"background-color: " +
			        background_color.to_string().substring(0, 7) + "\">";
		}
		else
		{
			// close the tag
			html += ">";
			
			// add the background image
			html += "<img src=\"" + exporter.path + " " + background_image +
			        "\" alt=\"Background\" width=\"" +
			        parent.width.to_string() + "\" height=\"" +
			        parent.height.to_string() + "\"/>";

			// copy the image file
			exporter.copy_file(background_image, parent.path);
		}
		
		// add tags for each Element
		foreach (var e in elements)
		{
			e.to_html(ref html, exporter, amount / elements.size);
		}
		
		html += "</div>\n";
	}
}
