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
using static Microsoft.EntityFrameworkCore.DbLoggerCategory;

namespace StudentOglasi.Services.Services
{
    public class StudentiService:BaseCRUDService<Model.Studenti, Database.Studenti, StudentiSearchObject, StudentiInsertRequest,StudentiUpdateRequest>, IStudentiService
    {
        public readonly FileService _fileService;
        public readonly KorisniciService _korisniciService;
        public StudentiService(StudentoglasiContext context, IMapper mapper, FileService fileService, KorisniciService korisniciService) :base(context, mapper) 
        { 
            _fileService = fileService;
            _korisniciService = korisniciService;
        }

        public override IQueryable<Database.Studenti> AddInclude(IQueryable<Database.Studenti> query, StudentiSearchObject? search = null)
        {
            return base.AddInclude(query.Include(s=>s.IdNavigation)
                .Include(s=>s.NacinStudiranja)
                .Include(s=>s.Fakultet)
                .Include(s=>s.Smjer)
                , search);
        }
        private async Task LoadReferences(Database.Studenti entity)
        {
            _context.Entry(entity).Reference(e => e.IdNavigation).Load();
            _context.Entry(entity).Reference(e => e.Fakultet).Load();
            _context.Entry(entity).Reference(e => e.NacinStudiranja).Load();
            _context.Entry(entity).Reference(e => e.Smjer).Load();
        }

        public override async Task BeforeInsert(Database.Studenti entity, StudentiInsertRequest insert)
        {
            await LoadReferences(entity);
            if (insert.Slika != null)
            {
                var uploadResponse = await _fileService.UploadAsync(insert.Slika);
                if (!uploadResponse.Error)
                {
                    entity.IdNavigation.Slika = uploadResponse.Blob.Name;
                }
                else
                {
                    throw new Exception("Greška pri uploadu slike");
                }
            }
            await _korisniciService.BeforeInsert(entity.IdNavigation, insert.IdNavigation);
        }
        public override async Task BeforeUpdate(Database.Studenti entity, StudentiUpdateRequest update)
        {
            await LoadReferences(entity);
            if (update.Slika != null)
            {
                if (entity.IdNavigation.Slika != null)
                {
                    await _fileService.DeleteAsync(entity.IdNavigation.Slika);
                }

                var uploadResponse = await _fileService.UploadAsync(update.Slika);

                if (!uploadResponse.Error)
                {
                    entity.IdNavigation.Slika = uploadResponse.Blob.Name;
                }
                else
                {
                    throw new Exception("Greška pri uploadu slike");
                }
            }
        }
        public override async Task Delete(int id)
        {
            var query = _context.Set<Database.Studenti>().Include(s => s.IdNavigation);
            var entity = await query.FirstOrDefaultAsync(s => s.Id == id);

            if (entity != null )
            {
                if (entity.IdNavigation.Slika != null)
                {
                    try
                    {
                        await _fileService.DeleteAsync(entity.IdNavigation.Slika);
                    }
                    catch (Exception ex)
                    {
                        throw new Exception("Greška pri brisanju slike.", ex);
                    }
                }
                await _korisniciService.Delete(entity.IdNavigation.Id);
            }
        }
        public override IQueryable<Database.Studenti> AddFilter(IQueryable<Database.Studenti> query, StudentiSearchObject? search = null)
        {
            var filteredQuery = base.AddFilter(query, search);

            if (!string.IsNullOrWhiteSpace(search?.BrojIndeksa))
            {
                filteredQuery = filteredQuery.Where(x => x.BrojIndeksa.Contains(search.BrojIndeksa));
            }
            if (!string.IsNullOrWhiteSpace(search?.ImePrezime))
            {
                string[] parts = search.ImePrezime.Split(' ');
                if (parts.Length >= 2)
                {
                    string ime = parts[0];
                    string prezime = parts[1];
                    filteredQuery = filteredQuery.Where(x => x.IdNavigation.Ime.Contains(ime) && x.IdNavigation.Prezime.Contains(prezime));
                }
                else
                {
                    string imePrezime = parts[0];
                    filteredQuery = filteredQuery.Where(x => x.IdNavigation.Ime.Contains(imePrezime) || x.IdNavigation.Prezime.Contains(imePrezime));
                }
            }
            if (search?.GodinaStudija != null)
            {
                filteredQuery = filteredQuery.Where(x => x.GodinaStudija == search.GodinaStudija);
            }
            if (search?.FakuletID != null)
            {
                filteredQuery = filteredQuery.Where(x => x.FakultetId == search.FakuletID);
            }
            return filteredQuery;
        }
    }
}
