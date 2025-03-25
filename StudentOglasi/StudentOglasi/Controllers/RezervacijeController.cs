using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using StudentOglasi.Model;
using StudentOglasi.Model.Requests;
using StudentOglasi.Model.SearchObjects;
using StudentOglasi.Services.Interfaces;
using StudentOglasi.Services.Services;

namespace StudentOglasi.Controllers
{
    [Route("[controller]")]
    [ApiController]
    public class RezervacijeController : BaseController<Rezervacije, RezervacijeSearchObject>
    {
        public RezervacijeController(ILogger<BaseController<Rezervacije, RezervacijeSearchObject>> logger, IRezervacijeService rezervacijeService) : base(logger, rezervacijeService)
        {
        }

        [HttpPost]
        public async Task<Model.Rezervacije> Insert([FromBody] RezervacijaInsertRequest request)
        {
            return await (_service as IRezervacijeService).Insert(request);
        }

        [HttpDelete("{id}")]
        [Authorize]
        public virtual async Task Delete(int id)
        {
            await (_service as IRezervacijeService).Delete(id);
        }

        [HttpGet("booked-dates/{smjestajnaJedinicaId}")]
        public async Task<List<ZauzetiTermin>> GetZauzetiTermini(int smjestajnaJedinicaId)
        {
            return await (_service as IRezervacijeService).GetBooked(smjestajnaJedinicaId);
        }

        [HttpPut("{rezervacijaId}/approve")]
        public virtual async Task<Model.Rezervacije> Approve(int rezervacijaId)
        {
            return await (_service as IRezervacijeService).Approve(rezervacijaId);
        }

        [HttpPut("{rezervacijaId}/cancel")]
        public virtual async Task<Model.Rezervacije> Cancel(int rezervacijaId)
        {
            return await (_service as IRezervacijeService).Cancel(rezervacijaId);
        }

        [HttpGet("{studentId}/{smjestajnaJedinicaId}/allowedActions")]
        public async Task<List<string>> AllowedActions(int studentId, int smjestajnaJedinicaId)
        {
            return await (_service as IRezervacijeService).AllowedActions(studentId, smjestajnaJedinicaId);
        }

        [HttpGet("student/{studentId}")]
        public async Task<List<Rezervacije>> GetByStudentId(int studentId)
        {
            return await (_service as IRezervacijeService).GetByStudentIdAsync(studentId);
        }

        [HttpGet("report/download/{smjestajId}")]
        public async Task<IActionResult> DownloadReport(int smjestajId, int? smjestajnaJedinicaId, DateTime? pocetniDatum, DateTime? krajnjiDatum)
        {
            try
            {
                var pdfReport = await (_service as IRezervacijeService).DownloadReportAsync(smjestajId, smjestajnaJedinicaId, pocetniDatum, krajnjiDatum);

                var contentType = "application/pdf";
                var fileName = $"ReservationReport_{smjestajId}.pdf";
                Response.Headers.Add("Content-Disposition", $"attachment; filename={fileName}");

                return File(pdfReport, contentType, fileName);
            }
            catch (Exception ex)
            {
                return NotFound(ex.Message);
            }
        }
    }
}
