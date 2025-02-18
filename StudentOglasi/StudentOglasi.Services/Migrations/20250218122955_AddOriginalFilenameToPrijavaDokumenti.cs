using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace StudentOglasi.Services.Migrations
{
    /// <inheritdoc />
    public partial class AddOriginalFilenameToPrijavaDokumenti : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "OriginalniNaziv",
                table: "PrijavaDokumenti",
                type: "nvarchar(max)",
                nullable: false,
                defaultValue: "");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "OriginalniNaziv",
                table: "PrijavaDokumenti");
        }
    }
}
