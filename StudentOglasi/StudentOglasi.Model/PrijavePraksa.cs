﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace StudentOglasi.Model
{
    public class PrijavePraksa
    {
        public int StudentId { get; set; }

        public int PraksaId { get; set; }

        public string? PropratnoPismo { get; set; }

        public string? Cv { get; set; }

        public string? Certifikati { get; set; }
        public DateTime? VrijemePrijave { get; set; }

        public int StatusId { get; set; }

        public virtual Prakse Praksa { get; set; } = null!;

        public virtual StatusPrijave Status { get; set; } = null!;

        public virtual Studenti Student { get; set; } = null!;
    }
}
