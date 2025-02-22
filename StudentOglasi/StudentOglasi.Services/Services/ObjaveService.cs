using AutoMapper;
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
        public readonly FileService _fileService;
        public readonly ObavijestiService _obavijestiService;
        public ObjaveService(StudentoglasiContext context, IMapper mapper, FileService fileService, ObavijestiService obavijestiService) : base(context, mapper)
        {
            _fileService = fileService;
            _obavijestiService = obavijestiService;
        }
        public override async Task BeforeInsert(Database.Objave entity, ObjaveInsertRequest insert)
        {
            entity.VrijemeObjave = DateTime.Now;
            if (insert.Slika != null)
            {
                var uploadResponse = await _fileService.UploadAsync(insert.Slika);
                if (!uploadResponse.Error)
                {
                    entity.Slika = uploadResponse.Blob.Name;
                }
                else
                {
                    throw new Exception("Greška pri uploadu slike");
                }
            }
        }

        public override async Task<PagedResult<Model.Objave>> Get(ObjaveSearchObject? search = null)
        {
            var query = _context.Objaves.AsQueryable();

            query = AddFilter(query, search);
            query = AddInclude(query, search);
            query = ApplySorting(query, search?.Sort);

            PagedResult<Model.Objave> result = new PagedResult<Model.Objave>
            {
                Count = await query.CountAsync()
            };

            if (search?.Page.HasValue == true && search?.PageSize.HasValue == true)
            {
                query = query.Skip((search.Page.Value - 1) * search.PageSize.Value).Take(search.PageSize.Value);
            }

            var list = await query.ToListAsync();
            var tmp = _mapper.Map<List<Model.Objave>>(list);

            foreach (var objava in tmp)
            {
                objava.BrojKomentara = await _context.Komentaris
                    .CountAsync(k => k.PostId == objava.Id && k.PostType == "news");
            }

            result.Result = tmp;
            return result;
        }


        public override async Task<Model.Objave> Insert(ObjaveInsertRequest insert)
        {
            var entity = await base.Insert(insert);

            string title = entity.Naslov;
            await _obavijestiService.SendNotificationObjave("Novosti", title, entity.Id, "success");
            return entity;
        }
        public override async Task Delete(int id)
        {
            var entity = await _context.Objaves.FindAsync(id);

            if (entity == null)
                throw new Exception("Objekat nije pronađen");

            var relatedObavijesti = _context.Obavijestis.Where(o => o.ObjaveId == id);
            _context.Obavijestis.RemoveRange(relatedObavijesti);

            _context.Objaves.Remove(entity);

            await _context.SaveChangesAsync();
        }
        public override async Task BeforeUpdate(Database.Objave entity, ObjaveUpdateRequest update)
        {
            if(update.Slika != null)
            {
                if (entity.Slika != null)
                {
                    await _fileService.DeleteAsync(entity.Slika);
                }

                var uploadResponse = await _fileService.UploadAsync(update.Slika);

                if (!uploadResponse.Error)
                {
                    entity.Slika = uploadResponse.Blob.Name;
                }
                else
                {
                    throw new Exception("Greška pri uploadu slike");
                }
            }
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

        private IQueryable<Database.Objave> ApplySorting(IQueryable<Database.Objave> query, string? sortOption)
        {
            if (string.IsNullOrWhiteSpace(sortOption))
                return query;

            return sortOption.ToLower() switch
            {
                "popularnost" => query
                    .Select(p => new
                    {
                        Objava = p,
                        Popularnost = _context.Likes.Count(l => l.ItemId == p.Id && l.ItemType == "news")
                    })
                    .OrderByDescending(x => x.Popularnost)
                    .Select(x => x.Objava),

                "naziv a-z" => query.OrderBy(p => p.Naslov),
                "naziv z-a" => query.OrderByDescending(p => p.Naslov),

                "najnovije" => query.OrderByDescending(p => p.VrijemeObjave),
                "najstarije" => query.OrderBy(p => p.VrijemeObjave),
                _ => query
            };
        }
    }
}
