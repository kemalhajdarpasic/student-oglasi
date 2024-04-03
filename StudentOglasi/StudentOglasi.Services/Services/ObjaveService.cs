﻿using AutoMapper;
using Microsoft.EntityFrameworkCore;
using StudentOglasi.Model;
using StudentOglasi.Model.Requests;
using StudentOglasi.Model.SearchObjects;
using StudentOglasi.Services.Database;
using StudentOglasi.Services.Interfaces;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace StudentOglasi.Services.Services
{
    public class ObjaveService : BaseCRUDService<Model.Objave, Database.Objave, ObjaveSearchObject, ObjaveInsertRequest, ObjaveUpdateRequest>, IObjaveService
    {
        public ObjaveService(StudentoglasiContext context, IMapper mapper): base(context, mapper)
        {
        }
        public override async Task BeforeInsert(Database.Objave entity, ObjaveInsertRequest insert)
        {
            entity.VrijemeObjave = DateTime.Now;
        }
        public override IQueryable<Database.Objave> AddFilter(IQueryable<Database.Objave> query, ObjaveSearchObject? search = null)
        {
            var filteredQuery = base.AddFilter(query, search);

            if (!string.IsNullOrWhiteSpace(search?.Naslov))
            {
                filteredQuery = filteredQuery.Where(x => x.Naslov.Contains(search.Naslov));
            }
            if(search?.KategorijaID!= null)
            {
                filteredQuery = filteredQuery.Where(x => x.KategorijaId == search.KategorijaID);
            }

            return filteredQuery;
        }
        public override IQueryable<Database.Objave> AddInclude(IQueryable<Database.Objave> query, ObjaveSearchObject? search = null)
        {
            return base.AddInclude(query.Include("Kategorija"), search);
        }
    }
}