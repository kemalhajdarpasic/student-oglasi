using StudentOglasi.Model;
using StudentOglasi.Model.Requests;
using StudentOglasi.Model.SearchObjects;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace StudentOglasi.Services.Interfaces
{
    public interface IRezervacijeService : IService<Rezervacije, RezervacijeSearchObject>
    {
        Task<Model.Rezervacije> Approve(int rezervacijaId);
        Task<Model.Rezervacije> Cancel(int rezervacijaId);
        Task<List<string>> AllowedActions(int studentId, int smjestajnaJedinicaId);
        Task<List<Rezervacije>> GetByStudentIdAsync(int studentId);
        Task<List<ZauzetiTermin>> GetBooked(int smjestajnaJedinicaId);
        Task<Model.Rezervacije> Insert(RezervacijaInsertRequest request);
        Task Delete(int id);
        byte[] GeneratePDFReport(List<Rezervacije> prijave, Model.Smjestaji smjestaj, int? smjestajnaJedinicaId, DateTime? pocetniDatum, DateTime? krajnjiDatum);
        Task<byte[]> DownloadReportAsync(int smjestajId, int? smjestajnaJedinicaId, DateTime? pocetniDatum, DateTime? krajnjiDatum);
    }
}
