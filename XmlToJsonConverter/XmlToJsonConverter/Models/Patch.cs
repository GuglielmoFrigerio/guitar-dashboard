using System;
using System.Xml.Linq;

namespace XmlToJsonConverter.Models
{
	public class Patch
	{
		public Patch(XElement patchElement)
		{
			name = patchElement.Attribute("name")?.Value;
			axeFx3 = new Program(patchElement);
		}

		public string name { get; set; }

		public Program axeFx2 { get; set; }

		public Program axeFx3 { get; set; }
	}
}

