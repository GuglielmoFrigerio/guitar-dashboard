using System;
using System.Xml.Linq;

namespace XmlToJsonConverter.Models
{
	public class Program
	{
		public Program(XElement patchElement)
		{
			number = int.Parse(patchElement.Value);
			var sceneAttribute = patchElement.Attribute("scene");
			scene = (sceneAttribute != null) ? int.Parse(sceneAttribute.Value) : 0;
		}

		public int number { get; set; }
		public int scene { get; set; }
	}
}

