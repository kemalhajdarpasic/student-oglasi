using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace StudentOglasi.Model.SearchObjects
{
    public class StipendijeSearchObject:BaseSearchObject
    {
        public string? Naslov { get; set; }
        public int? StipenditorID { get; set; }
        public int? GradID { get; set; }
        public List<int>? ProsjecneOcjene { get; set; } = new List<int>();
        public double MinimalnaOcjena { get; set; }
        public string? Sort { get; set; }
    }
}