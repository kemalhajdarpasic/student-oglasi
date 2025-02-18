using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

#pragma warning disable CA1814 // Prefer jagged arrays over multidimensional

namespace StudentOglasi.Services.Migrations
{
    /// <inheritdoc />
    public partial class AddPrijaveDokumentiTable : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_PrijavaStipendija_Stipendija_StipendijaID",
                table: "PrijaveStipendija");

            migrationBuilder.DropForeignKey(
                name: "FK_PrijavaStipendija_Student_StudentId",
                table: "PrijaveStipendija");

            migrationBuilder.DropForeignKey(
                name: "FK_PrijaveStipendija_StatusPrijave",
                table: "PrijaveStipendija");

            migrationBuilder.DropPrimaryKey(
                name: "PK_PrijavaStipendija",
                table: "PrijaveStipendija");

            migrationBuilder.DeleteData(
                table: "PrijaveStipendija",
                keyColumns: new[] { "StipendijaID", "StudentId" },
                keyValues: new object[] { 3, 2 });

            migrationBuilder.DeleteData(
                table: "PrijaveStipendija",
                keyColumns: new[] { "StipendijaID", "StudentId" },
                keyValues: new object[] { 4, 3 });

            migrationBuilder.DeleteData(
                table: "PrijaveStipendija",
                keyColumns: new[] { "StipendijaID", "StudentId" },
                keyValues: new object[] { 12, 6 });

            migrationBuilder.DeleteData(
                table: "PrijaveStipendija",
                keyColumns: new[] { "StipendijaID", "StudentId" },
                keyValues: new object[] { 13, 7 });

            migrationBuilder.DeleteData(
                table: "PrijaveStipendija",
                keyColumns: new[] { "StipendijaID", "StudentId" },
                keyValues: new object[] { 3, 8 });

            migrationBuilder.DeleteData(
                table: "PrijaveStipendija",
                keyColumns: new[] { "StipendijaID", "StudentId" },
                keyValues: new object[] { 4, 9 });

            migrationBuilder.DropColumn(
                name: "Dokumentacija",
                table: "PrijaveStipendija");

            migrationBuilder.RenameColumn(
                name: "StatusID",
                table: "PrijaveStipendija",
                newName: "StatusId");

            migrationBuilder.AlterColumn<decimal>(
                name: "ProsjekOcjena",
                table: "PrijaveStipendija",
                type: "decimal(4,2)",
                nullable: true,
                oldClrType: typeof(decimal),
                oldType: "decimal(4,2)");

            migrationBuilder.AddColumn<int>(
                name: "Id",
                table: "PrijaveStipendija",
                type: "int",
                nullable: false,
                defaultValue: 0)
                .Annotation("SqlServer:Identity", "1, 1");

            migrationBuilder.AddPrimaryKey(
                name: "PK_PrijaveStipendija",
                table: "PrijaveStipendija",
                column: "Id");

            migrationBuilder.CreateTable(
                name: "PrijavaDokumenti",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    PrijavaStipendijaId = table.Column<int>(type: "int", nullable: false),
                    Naziv = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_PrijavaDokumenti", x => x.Id);
                    table.ForeignKey(
                        name: "FK_PrijavaDokumenti_PrijaveStipendija_PrijavaStipendijaId",
                        column: x => x.PrijavaStipendijaId,
                        principalTable: "PrijaveStipendija",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_PrijaveStipendija_StudentId",
                table: "PrijaveStipendija",
                column: "StudentId");

            migrationBuilder.CreateIndex(
                name: "IX_PrijavaDokumenti_PrijavaStipendijaId",
                table: "PrijavaDokumenti",
                column: "PrijavaStipendijaId");

            migrationBuilder.AddForeignKey(
                name: "FK_PrijaveStipendija_StatusPrijave_StatusId",
                table: "PrijaveStipendija",
                column: "StatusId",
                principalTable: "StatusPrijave",
                principalColumn: "ID");

            migrationBuilder.AddForeignKey(
                name: "FK_PrijaveStipendija_Stipendije_StipendijaID",
                table: "PrijaveStipendija",
                column: "StipendijaID",
                principalTable: "Stipendije",
                principalColumn: "ID");

            migrationBuilder.AddForeignKey(
                name: "FK_PrijaveStipendija_Studenti_StudentId",
                table: "PrijaveStipendija",
                column: "StudentId",
                principalTable: "Studenti",
                principalColumn: "ID");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_PrijaveStipendija_StatusPrijave_StatusId",
                table: "PrijaveStipendija");

            migrationBuilder.DropForeignKey(
                name: "FK_PrijaveStipendija_Stipendije_StipendijaID",
                table: "PrijaveStipendija");

            migrationBuilder.DropForeignKey(
                name: "FK_PrijaveStipendija_Studenti_StudentId",
                table: "PrijaveStipendija");

            migrationBuilder.DropTable(
                name: "PrijavaDokumenti");

            migrationBuilder.DropPrimaryKey(
                name: "PK_PrijaveStipendija",
                table: "PrijaveStipendija");

            migrationBuilder.DropIndex(
                name: "IX_PrijaveStipendija_StudentId",
                table: "PrijaveStipendija");

            migrationBuilder.DropColumn(
                name: "Id",
                table: "PrijaveStipendija");

            migrationBuilder.RenameColumn(
                name: "StatusId",
                table: "PrijaveStipendija",
                newName: "StatusID");

            migrationBuilder.AlterColumn<decimal>(
                name: "ProsjekOcjena",
                table: "PrijaveStipendija",
                type: "decimal(4,2)",
                nullable: false,
                defaultValue: 0m,
                oldClrType: typeof(decimal),
                oldType: "decimal(4,2)",
                oldNullable: true);

            migrationBuilder.AddColumn<string>(
                name: "Dokumentacija",
                table: "PrijaveStipendija",
                type: "nvarchar(100)",
                maxLength: 100,
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddPrimaryKey(
                name: "PK_PrijavaStipendija",
                table: "PrijaveStipendija",
                columns: new[] { "StudentId", "StipendijaID" });

            migrationBuilder.InsertData(
                table: "PrijaveStipendija",
                columns: new[] { "StipendijaID", "StudentId", "CV", "Dokumentacija", "ProsjekOcjena", "StatusID", "VrijemePrijave" },
                values: new object[,]
                {
                    { 3, 2, "CV_studenta_1.pdf", "Dokumentacija_studenta_1.pdf", 8.5m, 2, null },
                    { 4, 3, "CV_studenta_2.pdf", "Dokumentacija_studenta_2.pdf", 9.0m, 2, null },
                    { 12, 6, "CV_studenta.pdf", "Dokumentacija_studenta.pdf", 8.7m, 4, null },
                    { 13, 7, "CV_studenta.pdf", "Dokumentacija_studenta.pdf", 9.1m, 2, null },
                    { 3, 8, "CV_studenta.pdf", "Dokumentacija_studenta.pdf", 8.0m, 2, null },
                    { 4, 9, "CV_studenta.pdf", "Dokumentacija_studenta.pdf", 7.9m, 3, null }
                });

            migrationBuilder.AddForeignKey(
                name: "FK_PrijavaStipendija_Stipendija_StipendijaID",
                table: "PrijaveStipendija",
                column: "StipendijaID",
                principalTable: "Stipendije",
                principalColumn: "ID");

            migrationBuilder.AddForeignKey(
                name: "FK_PrijavaStipendija_Student_StudentId",
                table: "PrijaveStipendija",
                column: "StudentId",
                principalTable: "Studenti",
                principalColumn: "ID");

            migrationBuilder.AddForeignKey(
                name: "FK_PrijaveStipendija_StatusPrijave",
                table: "PrijaveStipendija",
                column: "StatusID",
                principalTable: "StatusPrijave",
                principalColumn: "ID");
        }
    }
}
