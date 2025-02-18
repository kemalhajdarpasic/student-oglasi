using System;
using System.Collections.Generic;

namespace StudentOglasi.Services.Database;

public class PrijavaDokumenti
{
    public int Id { get; set; }
    public int PrijavaStipendijaId { get; set; }
    public string Naziv { get; set; } = null!;
    public string OriginalniNaziv { get; set; } = null!;

    public virtual PrijaveStipendija PrijavaStipendija { get; set; } = null!;
}
