﻿using System;
using System.Collections.Generic;

namespace StudentOglasi.Services.Database;

public partial class Oglasi
{
    public int Id { get; set; }

    public string Naslov { get; set; } = null!;

    public DateTime RokPrijave { get; set; }

    public string Opis { get; set; } = null!;

    public DateTime VrijemeObjave { get; set; }

    public string Slika { get; set; } = null!;

    public virtual ICollection<Komentari> Komentaris { get; set; } = new List<Komentari>();

    public virtual Prakse? Prakse { get; set; }

    public virtual Smjestaji? Smjestaji { get; set; }

    public virtual Stipendije? Stipendije { get; set; }
}