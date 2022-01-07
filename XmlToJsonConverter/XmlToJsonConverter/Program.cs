// See https://aka.ms/new-console-template for more information
using System.Text.Json;
using XmlToJsonConverter.Models;

Console.WriteLine("Hello, World!");

var configRoot = ConfigRoot.Load("AxeFxIIIDevice.xml");
var options = new JsonSerializerOptions { WriteIndented = true };
var configAsJson = JsonSerializer.Serialize(configRoot, options);
File.WriteAllText("devicesConfiguration.json", configAsJson);

