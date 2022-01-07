using System;
using System.Xml.Linq;

namespace XmlToJsonConverter.Models
{
	public class ConfigRoot
	{
		public ConfigRoot(XElement rootElement)
		{
			libraries = (from el in rootElement.Elements("Library") select new Library(el)).ToArray();
			name = rootElement.Attribute("name")?.Value;
		}

		public string name { get; set; }

		public Library[] libraries { get; set; }

		public static ConfigRoot Load(string xmlSource)
        {
			var dom = XDocument.Load(xmlSource);
			return new ConfigRoot(dom.Root);
        }
	}
}

