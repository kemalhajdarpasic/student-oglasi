using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace StudentOglasi.Model.SearchObjects
{
    public class SmjestajiSearchObject:BaseSearchObject
    {
        public string? Naziv { get; set; }
        public int? GradID { get; set; }
        public int? TipSmjestajaID { get; set; }
        public List<string>? DodatneUsluge { get; set; } = new List<string>();
        public List<int>? ProsjecneOcjene { get; set; } = new List<int>();
        public string? Sort { get; set; }
    }
}