using System;
using System.Collections.Generic;

namespace StudentOglasi.Services.Database;

public partial class PrijaveStipendija
{
    public int Id { get; set; }
    public int StudentId { get; set; }

    public int StipendijaID { get; set; }

    public virtual ICollection<PrijavaDokumenti> Dokumenti { get; set; } = new List<PrijavaDokumenti>();

    public string? Cv { get; set; }

    public decimal? ProsjekOcjena { get; set; }

    public DateTime? VrijemePrijave { get; set; }

    public int StatusId { get; set; }

    public virtual StatusPrijave Status { get; set; } = null!;

    public virtual Stipendije Stipendija { get; set; } = null!;

    public virtual Studenti Student { get; set; } = null!;
}
