using AutoMapper;
using Microsoft.EntityFrameworkCore;
using StudentOglasi.Model;
using StudentOglasi.Model.Requests;
using StudentOglasi.Model.SearchObjects;
using StudentOglasi.Services.Database;
using StudentOglasi.Services.Interfaces;
using StudentOglasi.Services.StateMachines.PrakseStateMachine;
using System.Collections.Concurrent;

namespace StudentOglasi.Services.Services
{
    public class PrakseService : BaseCRUDService<Model.Prakse, Database.Prakse, PrakseSearchObject, PrakseInsertRequest, PrakseUpdateRequest>, IPrakseService
    {
        private readonly RecommenderSystem _recommenderSystem;
        public readonly FileService _fileService;
        private readonly ConcurrentDictionary<int, List<int>> _cachedRecommendations = new();
        public BasePrakseState _baseState { get; set; }
        public PrakseService(StudentoglasiContext context, IMapper mapper, FileService fileService, RecommenderSystem recommenderSystem, BasePrakseState baseState) : base(context, mapper)
        {
            _recommenderSystem = recommenderSystem;
            _fileService = fileService;
            _baseState = baseState;
        }

        public async Task<List<Model.Prakse>> GetRecommendedPrakse(int studentId)
        {
            var recommendedPostIds = await _recommenderSystem.GetRecommendedPostIds(studentId, "internship");

            var recommendedPrakse = await _context.Prakses
                .Include(p => p.IdNavigation)
                .Where(p => recommendedPostIds.Contains(p.Id))
                .ToListAsync();

            return _mapper.Map<List<Model.Prakse>>(recommendedPrakse);
        }

        public override Task<Model.Prakse> Insert(PrakseInsertRequest insert)
        {
            var state = _baseState.CreateState("Kreiran");
            return state.Insert(insert);
        }
        public override IQueryable<Database.Prakse> AddFilter(IQueryable<Database.Prakse> query, PrakseSearchObject? search = null)
        {
            var filteredQuery = base.AddFilter(query, search);

            if (!string.IsNullOrWhiteSpace(search?.Naslov))
            {
                filteredQuery = filteredQuery.Where(x => x.IdNavigation.Naslov.Contains(search.Naslov));
            }
            if (search?.Organizacija!=null)
            {
                filteredQuery = filteredQuery.Where(x=>x.Organizacija.Id == search.Organizacija);
            }
            if (search?.Status != null)
            {
                filteredQuery = filteredQuery.Where(x => x.StatusId == search.Status);
            }
            if (search?.GradID != null)
            {
                filteredQuery = filteredQuery.Where(x => x.Organizacija.GradId == search.GradID);
            }
            if (search?.OrganizacijaID != null)
            {
                filteredQuery = filteredQuery.Where(x => x.OrganizacijaId == search.OrganizacijaID);
            }
            if (search?.ProsjecneOcjene != null && search.ProsjecneOcjene.Any())
            {
                filteredQuery = filteredQuery.Where(x =>
                    search.ProsjecneOcjene.Any(ocjena =>
                        (ocjena == 5 &&
                         _context.Ocjenes.Where(o => o.PostId == x.Id && o.PostType == "internship")
                                         .Average(o => (decimal?)o.Ocjena) == 5) ||
                        (ocjena < 5 &&
                         _context.Ocjenes.Where(o => o.PostId == x.Id && o.PostType == "internship")
                                         .Average(o => (decimal?)o.Ocjena) >= ocjena &&
                         _context.Ocjenes.Where(o => o.PostId == x.Id && o.PostType == "internship")
                                         .Average(o => (decimal?)o.Ocjena) < ocjena + 1)
                    ));
            }
            if (search?.MinimalnaOcjena != null)
            {
                filteredQuery = filteredQuery.Where(x =>
                    _context.Ocjenes.Where(o => o.PostId == x.Id && o.PostType == "internship")
                                    .Average(o => (double?)o.Ocjena) >= search.MinimalnaOcjena);
            }
            return filteredQuery;
        }
        public override IQueryable<Database.Prakse> AddInclude(IQueryable<Database.Prakse> query, PrakseSearchObject? search = null)
        {
            query = query.Include(p => p.IdNavigation).Include(p => p.Organizacija).Include(p => p.Status).AsQueryable();

            return base.AddInclude(query, search);
        }

        private IQueryable<Database.Prakse> ApplySorting(IQueryable<Database.Prakse> query, string? sortOption)
        {
            if (string.IsNullOrWhiteSpace(sortOption))
                return query;

            return sortOption.ToLower() switch
            {
                "popularnost" => query
                    .Select(p => new
                    {
                        Praksa = p,
                        Popularnost = _context.Likes.Count(l => l.ItemId == p.Id && l.ItemType == "internship")
                    })
                    .OrderByDescending(x => x.Popularnost)
                    .Select(x => x.Praksa),

                "ocjena" => query
                    .GroupJoin(
                        _context.Ocjenes.Where(o => o.PostType == "internship"),
                        praksa => praksa.Id,
                        ocjena => ocjena.PostId,
                        (praksa, ocjene) => new
                        {
                            Praksa = praksa,
                            ProsjecnaOcjena = ocjene.Any() ? ocjene.Average(o => o.Ocjena) : 0
                        }
                    )
                    .OrderByDescending(x => x.ProsjecnaOcjena)
                    .Select(x => x.Praksa),

                "naziv a-z" => query.OrderBy(p => p.IdNavigation.Naslov),
                "naziv z-a" => query.OrderByDescending(p => p.IdNavigation.Naslov),

                "najnovije" => query.OrderByDescending(p => p.IdNavigation.VrijemeObjave),
                "najstarije" => query.OrderBy(p => p.IdNavigation.VrijemeObjave),
                _ => query
            };
        }

        public override async Task<Model.Prakse> GetById(int id)
        {
            var entity = await _context.Set<Database.Prakse>().Include(p => p.Organizacija).Include(p => p.Status).FirstOrDefaultAsync(p => p.Id == id);

            return _mapper.Map<Model.Prakse>(entity);
        }

        public async Task<PagedResult<Model.Prakse>> GetPrakseWithRecommendations(PrakseSearchObject? search = null, int studentId = 0)
        {
            List<int> recommendedIds = new List<int>();
            if (studentId > 0)
            {
                if (!_cachedRecommendations.TryGetValue(studentId, out recommendedIds))
                {
                    recommendedIds = await _recommenderSystem.GetRecommendedPostIds(studentId, "internship");
                    _cachedRecommendations[studentId] = recommendedIds;
                }
            }
            var query = _context.Prakses.AsQueryable();

            query = AddFilter(query, search);
            query = AddInclude(query, search);
            query = ApplySorting(query, search?.Sort);

            int totalCount = await query.CountAsync();

            if (search?.Page.HasValue == true && search?.PageSize.HasValue == true)
            {
                query = query.Skip((search.Page.Value - 1) * search.PageSize.Value)
                             .Take(search.PageSize.Value);
            }

            var prakse = await query.ToListAsync();

            var mappedPrakse = prakse.Select(s =>
            {
                var praksa = _mapper.Map<Model.Prakse>(s);
                praksa.IsRecommended = recommendedIds.Contains(s.Id);
                return praksa;
            });

            if (string.IsNullOrWhiteSpace(search?.Sort))
            {
                mappedPrakse = mappedPrakse.OrderByDescending(s => s.IsRecommended);
            }

            return new PagedResult<Model.Prakse>
            {
                Count = totalCount,
                Result = mappedPrakse.ToList()
            };
        }

        public override async Task Delete(int id)
        {
            var query = _context.Set<Database.Prakse>().Include(p => p.IdNavigation);
            var entity = await query.FirstOrDefaultAsync(p => p.Id == id);

            if (entity == null)
                throw new Exception("Objekat nije pronađen");

            var oglasi = entity.IdNavigation;
            if (oglasi != null)
            {
                var relatedObavijesti = _context.Obavijestis.Where(o => o.OglasiId == oglasi.Id);
                _context.Obavijestis.RemoveRange(relatedObavijesti);

                _context.Oglasis.Remove(oglasi);
            }

            _context.Prakses.Remove(entity);

            await _context.SaveChangesAsync();
        }

        public override async Task<Model.Prakse> Update(int id, PrakseUpdateRequest update)
        {
            var set = _context.Set<Database.Prakse>();

            var entity = await set.Include(p => p.IdNavigation).FirstOrDefaultAsync(e => e.Id == id);
            entity.Status = await _context.StatusOglasis.FindAsync(entity.StatusId);
            var state = _baseState.CreateState(entity.Status.Naziv);

            if(!entity.Status.Naziv.Contains("Skica"))
            {
                await state.Hide(id);

                state = _baseState.CreateState(entity.Status.Naziv);
                return await state.Update(id, update);
            }

           return await state.Update(id, update);
        }

        public async Task<Model.Prakse> Hide(int id)
        {
            var set = _context.Set<Database.Prakse>();

            var entity = await set.FindAsync(id);
            entity.Status = await _context.StatusOglasis.FindAsync(entity.StatusId);
            var state = _baseState.CreateState(entity.Status.Naziv);

            return await state.Hide(id);
        }
        public async Task<List<string>> AllowedActions(int id)
        {
            var set = _context.Set<Database.Prakse>();

            var entity = await set.FindAsync(id);
            entity.Status = await _context.StatusOglasis.FindAsync(entity.StatusId);
            var state = _baseState.CreateState(entity.Status.Naziv??"Initial");
            return await state.AllowedActions();
        }
    }
}