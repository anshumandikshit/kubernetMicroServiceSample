using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Threading.Tasks;

// For more information on enabling Web API for empty projects, visit https://go.microsoft.com/fwlink/?LinkID=397860

namespace Service2.API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class Service2Controller : ControllerBase
    {
        private readonly IConfiguration _config;

        public Service2Controller(IConfiguration config)
        {
            _config = config;
        }

        // GET: api/<Service2Controller>
        [HttpGet]
        public IEnumerable<string> Get()
        {
            return new string[] { "value1", "value2" };
        }

        // GET api/<Service2Controller>/5
        [HttpGet("{id}")]
        public string Get(int id)
        {
            return "value";
        }

        // POST api/<Service2Controller>
        [HttpPost]
        public void Post([FromBody] string value)
        {
        }

        // PUT api/<Service2Controller>/5
        [HttpPut("{id}")]
        public void Put(int id, [FromBody] string value)
        {
        }

        // DELETE api/<Service2Controller>/5
        [HttpDelete("{id}")]
        public void Delete(int id)
        {
        }

        [HttpGet]
        [Route("getFromService2api")]
        public async Task<IActionResult> GetFromService2api()
        {
            HttpClient client = new HttpClient();
            var baseAddress = Environment.GetEnvironmentVariable("apiRoutePath__workerServiceEndPoint") ?? _config["apiRoutePath:workerServiceEndPoint"];
            client.BaseAddress = new Uri(baseAddress);
            HttpResponseMessage response = await client.GetAsync("api/WorkerService/getFromWorkerService");
            var responseBody = await response.Content.ReadAsStringAsync();

            return Ok($"From service2 api with {responseBody}");

        }

    }
}
