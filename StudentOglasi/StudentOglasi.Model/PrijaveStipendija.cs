﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace StudentOglasi.Model
{
    public class PrijaveStipendija
    {
        public int StudentId { get; set; }

        public int StipendijaId { get; set; }

        public string? Cv { get; set; }

        public decimal ProsjekOcjena { get; set; }

        public DateTime? VrijemePrijave { get; set; }
        public List<PrijavaDokumenti> Dokumenti { get; set; } = new List<PrijavaDokumenti>();

        public int StatusId { get; set; }

        public virtual StatusPrijave Status { get; set; } = null!;

        public virtual Stipendije Stipendija { get; set; } = null!;

        public virtual Studenti Student { get; set; } = null!;
    }
}
