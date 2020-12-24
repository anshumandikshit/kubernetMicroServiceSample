using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Threading.Tasks;

namespace ClientApp.UI.Controllers
{
    public class DisplayController : Controller
    {
        private readonly IConfiguration _config;

        public DisplayController(IConfiguration config)
        {
            _config = config;
        }
        // GET: DisplayController
        public async Task<ActionResult> GetResults()
        {
            //Add some comment to test the applications dev branch //check squashing //changing in the master branch 
            HttpClient client2 = new HttpClient();
            var baseAddress2 = Environment.GetEnvironmentVariable("apiRoutePath__service2Endpoint") ?? _config["apiRoutePath:service2Endpoint"];
            client2.BaseAddress = new Uri(baseAddress2);
            HttpResponseMessage response2 = await client2.GetAsync("api/Service2/getFromService2api");
            var responseBody2 = await response2.Content.ReadAsStringAsync();

            HttpClient client = new HttpClient();
            var baseAddress1 = Environment.GetEnvironmentVariable("apiRoutePath__service1Endpoint") ?? _config["apiRoutePath:service1Endpoint"];
            client.BaseAddress = new Uri(baseAddress1);
            HttpResponseMessage response1 = await client.GetAsync("api/Service1/getFromService1api");
            var responseBody1 = await response1.Content.ReadAsStringAsync();

           

            ViewBag.service1message = responseBody1;
            ViewBag.service2message = responseBody2;
            return View();
        }


        // GET: DisplayController/Details/5
        public ActionResult Details(int id)
        {
            return View();
        }

        // GET: DisplayController/Create
        public ActionResult Create()
        {
            return View();
        }

        // POST: DisplayController/Create
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Create(IFormCollection collection)
        {
            try
            {
                return RedirectToAction(nameof(Index));
            }
            catch
            {
                return View();
            }
        }

        // GET: DisplayController/Edit/5
        public ActionResult Edit(int id)
        {
            return View();
        }

        // POST: DisplayController/Edit/5
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Edit(int id, IFormCollection collection)
        {
            try
            {
                return RedirectToAction(nameof(Index));
            }
            catch
            {
                return View();
            }
        }

        // GET: DisplayController/Delete/5
        public ActionResult Delete(int id)
        {
            return View();
        }

        // POST: DisplayController/Delete/5
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Delete(int id, IFormCollection collection)
        {
            try
            {
                return RedirectToAction(nameof(Index));
            }
            catch
            {
                return View();
            }
        }
    }
}
