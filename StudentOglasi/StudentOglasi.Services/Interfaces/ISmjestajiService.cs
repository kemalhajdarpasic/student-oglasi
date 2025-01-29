﻿using StudentOglasi.Model;
using StudentOglasi.Model.Requests;
using StudentOglasi.Model.SearchObjects;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace StudentOglasi.Services.Interfaces
{
    public interface ISmjestajiService : ICRUDService<Smjestaji, SmjestajiSearchObject, SmjestajiInsertRequest, SmjestajiUpdateRequest>
    {
        Task<List<Model.Smjestaji>> GetRecommendedSmjestaji(int studentId);
        Task<PagedResult<Model.Smjestaji>> GetSmjestajiWithRecommendations(SmjestajiSearchObject? search, int studentId);
    }
}
