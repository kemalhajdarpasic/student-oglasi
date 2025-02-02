using AutoMapper;
using Microsoft.EntityFrameworkCore;
using StudentOglasi.Model;
using StudentOglasi.Model.Requests;
using StudentOglasi.Model.SearchObjects;
using StudentOglasi.Services.Database;
using StudentOglasi.Services.Interfaces;
using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace StudentOglasi.Services.Services
{
    public class SmjestajiService : BaseCRUDService<Model.Smjestaji, Database.Smjestaji, SmjestajiSearchObject, SmjestajiInsertRequest, SmjestajiUpdateRequest>, ISmjestajiService
    {
        private readonly RecommenderSystem _recommenderSystem;
        private readonly SlikeService _slikeService;

        public readonly ObavijestiService _obavijestiService;
        private readonly SmjestajnaJedinicaService _smjestajneJediniceService;
        private readonly ConcurrentDictionary<int, List<int>> _cachedRecommendations = new();
        public SmjestajiService(StudentoglasiContext context, IMapper mapper, SlikeService slikeService, SmjestajnaJedinicaService smjestajneJediniceService, ObavijestiService obavijestiService, RecommenderSystem recommenderSystem) : base(context, mapper)
        {
            _obavijestiService = obavijestiService;
            _recommenderSystem = recommenderSystem;
            _slikeService = slikeService;
            _smjestajneJediniceService = smjestajneJediniceService;
        }
        public override async Task<Model.Smjestaji> Insert(SmjestajiInsertRequest request)
        {
            var entity = await base.Insert(request);

            string title = entity.Naziv;
            await _obavijestiService.SendNotificationSmjestaj("Smještaj ", title, entity.Id,"success");

            return entity;
        }
        public override IQueryable<Database.Smjestaji> AddFilter(IQueryable<Database.Smjestaji> query, SmjestajiSearchObject? search = null)
        {
            var filteredQuery = base.AddFilter(query, search);

            if (!string.IsNullOrWhiteSpace(search?.Naziv))
            {
                filteredQuery = filteredQuery.Where(x => x.Naziv.Contains(search.Naziv));
            }

            if (search?.GradID != null)
            {
                filteredQuery = filteredQuery.Where(x => x.GradId == search.GradID);
            }

            if (search?.TipSmjestajaID != null)
            {
                filteredQuery = filteredQuery.Where(x => x.TipSmjestajaId == search.TipSmjestajaID);
            }

            if (search?.DodatneUsluge != null && search.DodatneUsluge.Any())
            {
                foreach (var usluga in search.DodatneUsluge)
                {
                    switch (usluga.ToLower())
                    {
                        case "wifi":
                            filteredQuery = filteredQuery.Where(x => x.WiFi == true);
                            break;
                        case "parking":
                            filteredQuery = filteredQuery.Where(x => x.Parking == true);
                            break;
                        case "fitness centar":
                            filteredQuery = filteredQuery.Where(x => x.FitnessCentar == true);
                            break;
                        case "restoran":
                            filteredQuery = filteredQuery.Where(x => x.Restoran == true);
                            break;
                        case "usluge prijevoza":
                            filteredQuery = filteredQuery.Where(x => x.UslugePrijevoza == true);
                            break;
                    }
                }
            }

            if (search?.ProsjecneOcjene != null && search.ProsjecneOcjene.Any())
            {
                filteredQuery = filteredQuery.Where(x =>
                    search.ProsjecneOcjene.Any(ocjena =>
                        (ocjena == 5 &&
                         _context.Ocjenes.Where(o => o.PostId == x.Id && o.PostType == "accommodation")
                                         .Average(o => (decimal?)o.Ocjena) == 5) ||
                        (ocjena < 5 &&
                         _context.Ocjenes.Where(o => o.PostId == x.Id && o.PostType == "accommodation")
                                         .Average(o => (decimal?)o.Ocjena) >= ocjena &&
                         _context.Ocjenes.Where(o => o.PostId == x.Id && o.PostType == "accommodation")
                                         .Average(o => (decimal?)o.Ocjena) < ocjena + 1)
                    ));
            }

            if (search?.MinimalnaOcjena != null)
            {
                filteredQuery = filteredQuery.Where(x =>
                    _context.Ocjenes.Where(o => o.PostId == x.Id && o.PostType == "accommodation")
                                    .Average(o => (double?)o.Ocjena) >= search.MinimalnaOcjena);
            }
            return filteredQuery;
        }
        public override IQueryable<Database.Smjestaji> AddInclude(IQueryable<Database.Smjestaji> query, SmjestajiSearchObject? search = null)
        {
            query = query.Include(s=> s.Grad)
                 .Include(s=>s.TipSmjestaja)
                 .Include(s=>s.Slikes)
                 .Include(s => s.SmjestajnaJedinicas)
                    .ThenInclude(sj => sj.Slikes);
            return base.AddInclude(query, search);
        }

        private IQueryable<Database.Smjestaji> ApplySorting(IQueryable<Database.Smjestaji> query, string? sortOption)
        {
            if (string.IsNullOrWhiteSpace(sortOption))
                return query;

            return sortOption.ToLower() switch
            {
                "popularnost" => query
                    .Select(s => new
                    {
                        Smjestaj = s,
                        Popularnost = _context.Likes.Count(l => l.ItemId == s.Id && l.ItemType == "accommodation")
                    })
                    .OrderByDescending(x => x.Popularnost)
                    .Select(x => x.Smjestaj),

                "ocjena" => query
                    .GroupJoin(
                        _context.Ocjenes.Where(o => o.PostType == "accommodation"),
                        smjestaj => smjestaj.Id,
                        ocjena => ocjena.PostId,
                        (smjestaj, ocjene) => new
                        {
                            Smjestaj = smjestaj,
                            ProsjecnaOcjena = ocjene.Any() ? ocjene.Average(o => o.Ocjena) : 0
                        }
                    )
                    .OrderByDescending(x => x.ProsjecnaOcjena)
                    .Select(x => x.Smjestaj),

                "naziv a-z" => query.OrderBy(s => s.Naziv),
                "naziv z-a" => query.OrderByDescending(s => s.Naziv),
                _ => query
            };
        }

        public override async Task<Model.Smjestaji> GetById(int id)
        {
            var query = _context.Set<Database.Smjestaji>().AsQueryable();
            query = AddInclude(query);
            var entity = await query.FirstOrDefaultAsync(s => s.Id == id);

            return _mapper.Map<Model.Smjestaji>(entity);
        }

        public override async Task BeforeDelete(Database.Smjestaji smjestaj)
        {
            var smjestajWithRelations = await _context.Smjestajis
           .Include(s => s.Slikes)
           .Include(s=>s.SmjestajnaJedinicas)
           .ThenInclude(sj => sj.Slikes)
           .FirstOrDefaultAsync(s => s.Id == smjestaj.Id);

            if (smjestajWithRelations != null)
            {
                if (smjestajWithRelations != null)
                {
                    var relatedObavijesti = _context.Obavijestis.Where(o => o.SmjestajiId == smjestajWithRelations.Id);
                    _context.Obavijestis.RemoveRange(relatedObavijesti);

                }
                var slike = smjestajWithRelations.Slikes.ToList();
                if (slike != null)
                {
                    foreach (var slika in slike)
                    {
                        await _context.Slikes.FindAsync(slika.SlikaId);
                        _context.Slikes.Remove(slika);
                        await _context.SaveChangesAsync();
                    }
                }
                var smjestajneJedinice = smjestajWithRelations.SmjestajnaJedinicas.ToList();

                if(smjestajneJedinice!= null) { 
                foreach (var jedinica in smjestajneJedinice)
                {
                    await _smjestajneJediniceService.Delete(jedinica.Id);
                }
                }
               
            }
        }
        public async Task<List<Model.Smjestaji>> GetRecommendedSmjestaji(int studentId)
        {
            var recommendedPostIds = await _recommenderSystem.GetRecommendedPostIds(studentId, "accommodation");

            var recommendedSmjestaji = await _context.Smjestajis
                .Where(p => recommendedPostIds.Contains(p.Id))
                .Include(p => p.Slikes)
                .ToListAsync();

            return _mapper.Map<List<Model.Smjestaji>>(recommendedSmjestaji);
        }

        public async Task<PagedResult<Model.Smjestaji>> GetSmjestajiWithRecommendations(SmjestajiSearchObject? search = null, int studentId = 0)
        {
            List<int> recommendedIds = new List<int>();
            if (studentId > 0)
            {
                if (!_cachedRecommendations.TryGetValue(studentId, out recommendedIds))
                {
                    recommendedIds = await _recommenderSystem.GetRecommendedPostIds(studentId, "accommodation");
                    _cachedRecommendations[studentId] = recommendedIds;
                }
            }
            var query = _context.Smjestajis.AsQueryable();

            query = AddFilter(query, search);
            query = AddInclude(query, search);
            query = ApplySorting(query, search?.Sort);

            int totalCount = await query.CountAsync();

            if (search?.Page.HasValue == true && search?.PageSize.HasValue == true)
            {
                query = query.Skip((search.Page.Value - 1) * search.PageSize.Value)
                             .Take(search.PageSize.Value);
            }

            var smjestaji = await query.ToListAsync();

            var mappedSmjestaji = smjestaji.Select(s =>
            {
                var smjestaj = _mapper.Map<Model.Smjestaji>(s);
                smjestaj.IsRecommended = recommendedIds.Contains(s.Id);
                return smjestaj;
            });

            if (string.IsNullOrWhiteSpace(search?.Sort))
            {
                mappedSmjestaji = mappedSmjestaji.OrderByDescending(s => s.IsRecommended);
            }

            return new PagedResult<Model.Smjestaji>
            {
                Count = totalCount,
                Result = mappedSmjestaji.ToList()
            };
        }
    }
}