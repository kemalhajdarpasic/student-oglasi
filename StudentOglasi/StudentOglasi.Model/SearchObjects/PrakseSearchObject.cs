using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace StudentOglasi.Model.SearchObjects
{
    public class PrakseSearchObject:BaseSearchObject
    {
        public string? Naslov { get; set; }
        public int? Organizacija { get; set; }
        public int? Status { get; set; }
        public int? GradID { get; set; }
        public int? OrganizacijaID { get; set; }
        public List<int>? ProsjecneOcjene { get; set; } = new List<int>();
        public string? Sort { get; set; }
    }
}