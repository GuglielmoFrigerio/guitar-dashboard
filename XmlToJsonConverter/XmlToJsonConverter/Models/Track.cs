using System;
using System.Xml.Linq;

namespace XmlToJsonConverter.Models
{
	public class Track
	{
		public Track(XElement trackElement)
		{
			name = trackElement.Attribute("name").Value;
			markers = (from el in trackElement.Elements("Marker") select new Marker(el)).ToArray();

		}

		public string name { get; set; }

		public Marker[] markers { get; set; }
	}
}

