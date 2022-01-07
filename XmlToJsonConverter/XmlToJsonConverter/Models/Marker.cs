using System;
using System.Xml.Linq;

namespace XmlToJsonConverter.Models
{
	public class Marker
	{
        public Marker(XElement markerElement)
        {
			name = markerElement.Attribute("name")?.Value;
			position = markerElement.Value;
        }

        public string name { get; set; }
		public string position { get; set; }
	}
}

