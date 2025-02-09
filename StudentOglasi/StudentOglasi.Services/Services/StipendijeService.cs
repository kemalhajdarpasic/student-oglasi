using AutoMapper;
using Microsoft.EntityFrameworkCore;
using StudentOglasi.Model;
using StudentOglasi.Model.Requests;
using StudentOglasi.Model.SearchObjects;
using StudentOglasi.Services.Database;
using StudentOglasi.Services.Interfaces;
using StudentOglasi.Services.OglasiStateMachine;
using System.Collections.Concurrent;

namespace StudentOglasi.Services.Services
{
    public class StipendijeService : BaseCRUDService<Model.Stipendije, Database.Stipendije, StipendijeSearchObject, StipendijeInsertRequest, StipendijeUpdateRequest>, IStipendijeService
    {
        private readonly RecommenderSystem _recommenderSystem;
        public readonly FileService _fileService;
        private readonly ConcurrentDictionary<int, List<int>> _cachedRecommendations = new();
        public BaseStipendijeState _baseState { get; set; }
        public StipendijeService(StudentoglasiContext context, IMapper mapper, FileService fileService, RecommenderSystem recommenderSystem, BaseStipendijeState baseState) : base(context, mapper)
        {
            _recommenderSystem = recommenderSystem;
            _fileService = fileService;
            _baseState = baseState;
        }
        public override Task<Model.Stipendije> Insert(StipendijeInsertRequest insert)
        {
            var state = _baseState.CreateState("Kreiran");
            return state.Insert(insert);
        }
        public override IQueryable<Database.Stipendije> AddFilter(IQueryable<Database.Stipendije> query, StipendijeSearchObject? search = null)
        {
            var filteredQuery = base.AddFilter(query, search);

            if (!string.IsNullOrWhiteSpace(search?.Naslov))
            {
                filteredQuery = filteredQuery.Where(x => x.IdNavigation.Naslov.Contains(search.Naslov));
            }
            if (search?.StipenditorID != null)
            {
                filteredQuery = filteredQuery.Where(x => x.Stipenditor.Id == search.StipenditorID);
            }
            if (search?.GradID != null)
            {
                filteredQuery = filteredQuery.Where(x => x.Stipenditor.GradId == search.GradID);
            }
            if (search?.ProsjecneOcjene != null && search.ProsjecneOcjene.Any())
            {
                filteredQuery = filteredQuery.Where(x =>
                    search.ProsjecneOcjene.Any(ocjena =>
                        (ocjena == 5 &&
                         _context.Ocjenes.Where(o => o.PostId == x.Id && o.PostType == "scholarship")
                                         .Average(o => (decimal?)o.Ocjena) == 5) ||
                        (ocjena < 5 &&
                         _context.Ocjenes.Where(o => o.PostId == x.Id && o.PostType == "scholarship")
                                         .Average(o => (decimal?)o.Ocjena) >= ocjena &&
                         _context.Ocjenes.Where(o => o.PostId == x.Id && o.PostType == "scholarship")
                                         .Average(o => (decimal?)o.Ocjena) < ocjena + 1)
                    ));
            }
            if (search?.MinimalnaOcjena != null)
            {
                filteredQuery = filteredQuery.Where(x =>
                    _context.Ocjenes.Where(o => o.PostId == x.Id && o.PostType == "scholarship")
                                    .Average(o => (double?)o.Ocjena) >= search.MinimalnaOcjena);
            }
            return filteredQuery;
        }
        public override IQueryable<Database.Stipendije> AddInclude(IQueryable<Database.Stipendije> query, StipendijeSearchObject? search = null)
        {
            query = query.Include(p => p.IdNavigation).Include(p => p.Status).Include(p => p.Stipenditor).AsQueryable();

            return base.AddInclude(query, search);
        }

        private IQueryable<Database.Stipendije> ApplySorting(IQueryable<Database.Stipendije> query, string? sortOption)
        {
            if (string.IsNullOrWhiteSpace(sortOption))
                return query;

            return sortOption.ToLower() switch
            {
                "popularnost" => query
                    .Select(s => new
                    {
                        Stipendija = s,
                        Popularnost = _context.Likes.Count(l => l.ItemId == s.Id && l.ItemType == "scholarship")
                    })
                    .OrderByDescending(x => x.Popularnost)
                    .Select(x => x.Stipendija),

                "ocjena" => query
                    .GroupJoin(
                        _context.Ocjenes.Where(o => o.PostType == "scholarship"),
                        stipendija => stipendija.Id,
                        ocjena => ocjena.PostId,
                        (stipendija, ocjene) => new
                        {
                            Stipendija = stipendija,
                            ProsjecnaOcjena = ocjene.Any() ? ocjene.Average(o => o.Ocjena) : 0
                        }
                    )
                    .OrderByDescending(x => x.ProsjecnaOcjena)
                    .Select(x => x.Stipendija),

                "naziv a-z" => query.OrderBy(s => s.IdNavigation.Naslov),
                "naziv z-a" => query.OrderByDescending(s => s.IdNavigation.Naslov),

                "najnovije" => query.OrderByDescending(s => s.IdNavigation.VrijemeObjave),
                "najstarije" => query.OrderBy(s => s.IdNavigation.VrijemeObjave),
                _ => query
            };
        }
        public override async Task<Model.Stipendije> GetById(int id)
        {
            var entity = await _context.Set<Database.Stipendije>().Include(p => p.Stipenditor).Include(p => p.Status).FirstOrDefaultAsync(p => p.Id == id);

            return _mapper.Map<Model.Stipendije>(entity);
        }

        public async Task<PagedResult<Model.Stipendije>> GetStipendijeWithRecommendations(StipendijeSearchObject? search = null, int studentId = 0)
        {
            List<int> recommendedIds = new List<int>();
            if (studentId > 0)
            {
                if (!_cachedRecommendations.TryGetValue(studentId, out recommendedIds))
                {
                    recommendedIds = await _recommenderSystem.GetRecommendedPostIds(studentId, "scholarship");
                    _cachedRecommendations[studentId] = recommendedIds;
                }
            }
            var query = _context.Stipendijes
               .Include(p => p.Status)
               .Where(p => p.Status.Naziv == "Aktivan")
               .AsQueryable();

            query = AddFilter(query, search);
            query = AddInclude(query, search);
            query = ApplySorting(query, search?.Sort);

            int totalCount = await query.CountAsync();

            if (search?.Page.HasValue == true && search?.PageSize.HasValue == true)
            {
                query = query.Skip((search.Page.Value - 1) * search.PageSize.Value)
                             .Take(search.PageSize.Value);
            }

            var stipendije = await query.ToListAsync();

            var mappedStipendije = stipendije.Select(s =>
            {
                var stipendija = _mapper.Map<Model.Stipendije>(s);
                stipendija.IsRecommended = recommendedIds.Contains(s.Id);
                return stipendija;
            });

            if (string.IsNullOrWhiteSpace(search?.Sort))
            {
                mappedStipendije = mappedStipendije.OrderByDescending(s => s.IsRecommended);
            }

            return new PagedResult<Model.Stipendije>
            {
                Count = totalCount,
                Result = mappedStipendije.ToList()
            };
        }

        public override async Task<Model.Stipendije> Update(int id, StipendijeUpdateRequest update)
        {
            var set = _context.Set<Database.Stipendije>();

            var entity = await set.Include(p => p.IdNavigation).FirstOrDefaultAsync(e => e.Id == id);
            entity.Status = await _context.StatusOglasis.FindAsync(entity.StatusId);
            var state = _baseState.CreateState(entity.Status.Naziv);

            if (!entity.Status.Naziv.Contains("Skica"))
            {
                await state.Hide(id);

                state = _baseState.CreateState(entity.Status.Naziv);
                return await state.Update(id, update);
            }

            return await state.Update(id, update);
        }
        public override async Task Delete(int id)
        {
            var query = _context.Set<Database.Stipendije>().Include(s => s.IdNavigation);
            var entity = await query.FirstOrDefaultAsync(s => s.Id == id);

            if (entity == null)
                throw new Exception("Objekat nije pronađen");

            var oglasi = entity.IdNavigation;
            if (oglasi != null)
            {
                var relatedObavijesti = _context.Obavijestis.Where(o => o.OglasiId == oglasi.Id);
                _context.Obavijestis.RemoveRange(relatedObavijesti);

                _context.Oglasis.Remove(oglasi);
            }

            _context.Stipendijes.Remove(entity);
            await _context.SaveChangesAsync();
        }
        public async Task<Model.Stipendije> Hide(int id)
        {
            var set = _context.Set<Database.Stipendije>();

            var entity = await set.FindAsync(id);
            entity.Status = await _context.StatusOglasis.FindAsync(entity.StatusId);
            var state = _baseState.CreateState(entity.Status.Naziv);

            return await state.Hide(id);
        }
        public async Task<List<string>> AllowedActions(int id)
        {
            var set = _context.Set<Database.Stipendije>();

            var entity = await set.FindAsync(id);
            entity.Status = await _context.StatusOglasis.FindAsync(entity.StatusId);
            var state = _baseState.CreateState(entity.Status.Naziv ?? "Kreiran");
            return await state.AllowedActions();
        }
        public async Task<List<Model.Stipendije>> GetRecommendedStipendije(int studentId)
        {
            var recommendedPostIds = await _recommenderSystem.GetRecommendedPostIds(studentId, "scholarship");

            var recommendedStipendije = await _context.Stipendijes
                .Include(p => p.IdNavigation)
                .Where(p => recommendedPostIds.Contains(p.Id))
                .ToListAsync();

            return _mapper.Map<List<Model.Stipendije>>(recommendedStipendije);
        }

        public async Task MarkExpiredStipendije()
        {
            var expiredStatus = await _context.StatusOglasis
                .FirstOrDefaultAsync(e => e.Naziv == "Istekao");

            if (expiredStatus == null)
            {
                return;
            }

            var expiredStipendije = await _context.Stipendijes
                .Include(p => p.Status)
                .Where(p => p.IdNavigation.RokPrijave < DateTime.UtcNow && p.Status.Naziv != "Istekao")
                .ToListAsync();

            if (expiredStipendije.Any())
            {
                foreach (var stipendija in expiredStipendije)
                {
                    stipendija.Status = expiredStatus;
                }
                await _context.SaveChangesAsync();
            }
        }
    }
}