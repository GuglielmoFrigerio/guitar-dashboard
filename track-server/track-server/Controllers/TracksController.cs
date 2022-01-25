using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;


namespace track_server.Controllers
{

    [Route("api/[controller]")]
    [ApiController]
    public class TracksController : ControllerBase
    {
        private static string test()
        {
            return System.IO.File.ReadAllText("/Users/guglielmofrigerio/Projects/Guglielmo/guitar-dashboard/track-server/track-server/Tracks/EmptyTextFile.txt");

        }

        [HttpGet("{trackName}", Name = "Get1")]
        public IActionResult Get(string trackName)
        {
            var bla = test();

            var stream = new System.IO.FileStream($"/Users/guglielmofrigerio/Projects/Guglielmo/guitar-dashboard/track-server/track-server/Tracks/{trackName}", System.IO.FileMode.Open);
            return File(stream, "application/mpeg");
        }

    }
}