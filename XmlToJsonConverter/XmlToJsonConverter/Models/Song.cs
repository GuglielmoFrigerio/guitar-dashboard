using System;
using System.Xml.Linq;

namespace XmlToJsonConverter.Models
{
	public class Song
	{
		public Song(XElement patchesElement)
		{
			name = patchesElement.Attribute("name").Value;
			track = new Track(patchesElement.Element("Track"));
			patches = (from el in patchesElement.Elements("Patch") select new Patch(el)).ToArray();
		}

		public string name { get; set; }

		public Track track { get; set; }

		public Patch[] patches { get; set; }
	}
}

