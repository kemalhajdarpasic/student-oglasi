﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace StudentOglasi.Model
{
    public partial class Smjerovi
    {
        public int Id { get; set; }

        public string Naziv { get; set; } = null!;

        public string? Opis { get; set; }
    }
}
