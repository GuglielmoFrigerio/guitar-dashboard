using System;
using System.Xml.Linq;

namespace XmlToJsonConverter.Models
{
	public class Library
	{
		public Library(XElement libraryElement)
		{
			name = libraryElement.Attribute("name").Value;
			songs = (from el in libraryElement.Elements("Patches") select new Song(el)).ToArray();
		}

		public string name { get; set; }
		public Song[] songs { get; set; }
	}
}

