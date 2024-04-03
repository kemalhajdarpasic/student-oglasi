﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace StudentOglasi.Model.Requests
{
    public class ObjaveInsertRequest
    {
        public string Naslov { get; set; } = null!;

        public string Sadrzaj { get; set; } = null!;

        public string Slika { get; set; } = null!;

        public int KategorijaId { get; set; }
    }
}