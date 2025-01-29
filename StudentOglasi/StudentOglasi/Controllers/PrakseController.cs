﻿using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using StudentOglasi.Model;
using StudentOglasi.Model.Requests;
using StudentOglasi.Model.SearchObjects;
using StudentOglasi.Services.Interfaces;
using StudentOglasi.Services.Services;

namespace StudentOglasi.Controllers
{
    [Route("[controller]")]
    [ApiController]
    public class PrakseController : BaseCRUDController<Prakse, PrakseSearchObject, PrakseInsertRequest, PrakseUpdateRequest>
    {
        public PrakseController(ILogger<BaseCRUDController<Prakse, PrakseSearchObject, PrakseInsertRequest, PrakseUpdateRequest>> logger, IPrakseService prakseService)
            : base(logger, prakseService)
        {

        }

        public override Task<IActionResult> Insert([FromForm] PrakseInsertRequest insert)
        {
            return base.Insert(insert);
        }

        public override Task<IActionResult> Update(int id, [FromForm] PrakseUpdateRequest update)
        {
            return base.Update(id, update);
        }

        [HttpPut("{id}/hide")]
        public virtual async Task<Model.Prakse> Hide(int id)
        {
            return await (_service as IPrakseService).Hide(id);
        }

        [HttpGet("{id}/allowedActions")]
        public async Task<List<string>> AllowedActions(int id)
        {
            return await (_service as IPrakseService).AllowedActions(id);
        }

        [HttpGet("recommendations/{studentId}")]
        public async Task<IActionResult> GetRecommendations(int studentId)
        {
            var prakse = await (_service as IPrakseService).GetRecommendedPrakse(studentId);

            if (prakse == null || !prakse.Any())
            {
                return NotFound("No recommendations available.");
            }

            return Ok(prakse);
        }

        [HttpGet("with-recommendations/{studentId}")]
        public async Task<IActionResult> GetPrakseWithRecommendations([FromQuery] PrakseSearchObject? search, int studentId)
        {
            var prakse = await (_service as IPrakseService).GetPrakseWithRecommendations(search, studentId);

            return Ok(prakse);
        }
    }
}
