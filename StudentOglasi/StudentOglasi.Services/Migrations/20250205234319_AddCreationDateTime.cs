using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace StudentOglasi.Services.Migrations
{
    /// <inheritdoc />
    public partial class AddCreationDateTime : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<DateTime>(
                name: "VrijemeKreiranja",
                table: "Rezervacije",
                type: "datetime2",
                nullable: true);

            migrationBuilder.AddColumn<DateTime>(
                name: "VrijemePrijave",
                table: "PrijaveStipendija",
                type: "datetime2",
                nullable: true);

            migrationBuilder.AddColumn<DateTime>(
                name: "VrijemePrijave",
                table: "PrijavePraksa",
                type: "datetime2",
                nullable: true);

            migrationBuilder.UpdateData(
                table: "PrijavePraksa",
                keyColumns: new[] { "PraksaId", "StudentId" },
                keyValues: new object[] { 1, 2 },
                column: "VrijemePrijave",
                value: null);

            migrationBuilder.UpdateData(
                table: "PrijavePraksa",
                keyColumns: new[] { "PraksaId", "StudentId" },
                keyValues: new object[] { 2, 3 },
                column: "VrijemePrijave",
                value: null);

            migrationBuilder.UpdateData(
                table: "PrijavePraksa",
                keyColumns: new[] { "PraksaId", "StudentId" },
                keyValues: new object[] { 6, 5 },
                column: "VrijemePrijave",
                value: null);

            migrationBuilder.UpdateData(
                table: "PrijavePraksa",
                keyColumns: new[] { "PraksaId", "StudentId" },
                keyValues: new object[] { 7, 6 },
                column: "VrijemePrijave",
                value: null);

            migrationBuilder.UpdateData(
                table: "PrijavePraksa",
                keyColumns: new[] { "PraksaId", "StudentId" },
                keyValues: new object[] { 8, 7 },
                column: "VrijemePrijave",
                value: null);

            migrationBuilder.UpdateData(
                table: "PrijavePraksa",
                keyColumns: new[] { "PraksaId", "StudentId" },
                keyValues: new object[] { 1, 8 },
                column: "VrijemePrijave",
                value: null);

            migrationBuilder.UpdateData(
                table: "PrijavePraksa",
                keyColumns: new[] { "PraksaId", "StudentId" },
                keyValues: new object[] { 2, 9 },
                column: "VrijemePrijave",
                value: null);

            migrationBuilder.UpdateData(
                table: "PrijaveStipendija",
                keyColumns: new[] { "StipendijaID", "StudentId" },
                keyValues: new object[] { 3, 2 },
                column: "VrijemePrijave",
                value: null);

            migrationBuilder.UpdateData(
                table: "PrijaveStipendija",
                keyColumns: new[] { "StipendijaID", "StudentId" },
                keyValues: new object[] { 4, 3 },
                column: "VrijemePrijave",
                value: null);

            migrationBuilder.UpdateData(
                table: "PrijaveStipendija",
                keyColumns: new[] { "StipendijaID", "StudentId" },
                keyValues: new object[] { 12, 6 },
                column: "VrijemePrijave",
                value: null);

            migrationBuilder.UpdateData(
                table: "PrijaveStipendija",
                keyColumns: new[] { "StipendijaID", "StudentId" },
                keyValues: new object[] { 13, 7 },
                column: "VrijemePrijave",
                value: null);

            migrationBuilder.UpdateData(
                table: "PrijaveStipendija",
                keyColumns: new[] { "StipendijaID", "StudentId" },
                keyValues: new object[] { 3, 8 },
                column: "VrijemePrijave",
                value: null);

            migrationBuilder.UpdateData(
                table: "PrijaveStipendija",
                keyColumns: new[] { "StipendijaID", "StudentId" },
                keyValues: new object[] { 4, 9 },
                column: "VrijemePrijave",
                value: null);

            migrationBuilder.UpdateData(
                table: "Rezervacije",
                keyColumn: "Id",
                keyValue: 1,
                column: "VrijemeKreiranja",
                value: null);

            migrationBuilder.UpdateData(
                table: "Rezervacije",
                keyColumn: "Id",
                keyValue: 2,
                column: "VrijemeKreiranja",
                value: null);

            migrationBuilder.UpdateData(
                table: "Rezervacije",
                keyColumn: "Id",
                keyValue: 3,
                column: "VrijemeKreiranja",
                value: null);

            migrationBuilder.UpdateData(
                table: "Rezervacije",
                keyColumn: "Id",
                keyValue: 4,
                column: "VrijemeKreiranja",
                value: null);

            migrationBuilder.UpdateData(
                table: "Rezervacije",
                keyColumn: "Id",
                keyValue: 5,
                column: "VrijemeKreiranja",
                value: null);

            migrationBuilder.UpdateData(
                table: "Rezervacije",
                keyColumn: "Id",
                keyValue: 6,
                column: "VrijemeKreiranja",
                value: null);

            migrationBuilder.UpdateData(
                table: "Rezervacije",
                keyColumn: "Id",
                keyValue: 7,
                column: "VrijemeKreiranja",
                value: null);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "VrijemeKreiranja",
                table: "Rezervacije");

            migrationBuilder.DropColumn(
                name: "VrijemePrijave",
                table: "PrijaveStipendija");

            migrationBuilder.DropColumn(
                name: "VrijemePrijave",
                table: "PrijavePraksa");
        }
    }
}
